/// Pure consumption maths for MeterPulse.
///
/// Every function here is a top-level pure function over plain numbers/value
/// objects — no Isar, no Flutter, no `DateTime.now()` — so the whole engine is
/// deterministic and trivially unit-testable. Functions return `null` (or an
/// explicit outcome) rather than throwing or guessing when a value is undefined
/// (no previous reading, zero-length span, meter reset without config).
library;

import 'models/cycle_consumption.dart';

/// How a consumption value was derived — or why it could not be.
enum ConsumptionOutcome {
  /// current >= previous: a normal forward difference.
  normal,

  /// current < previous but a rollover max is configured: the meter wrapped.
  rollover,

  /// current < previous with no rollover configured: cannot compute. The caller
  /// must ask the user whether the meter reset or the entry is wrong — the
  /// engine never silently guesses.
  anomaly,

  /// No previous reading in the cycle yet: consumption is undefined.
  noPrevious,
}

/// Result of [unitsConsumed]: the computed [units] (null for anomaly/noPrevious)
/// plus the [outcome] describing how it was derived.
class ConsumptionResult {
  const ConsumptionResult._(this.units, this.outcome);

  const ConsumptionResult.normal(double units)
      : this._(units, ConsumptionOutcome.normal);
  const ConsumptionResult.rollover(double units)
      : this._(units, ConsumptionOutcome.rollover);
  const ConsumptionResult.anomaly() : this._(null, ConsumptionOutcome.anomaly);
  const ConsumptionResult.noPrevious()
      : this._(null, ConsumptionOutcome.noPrevious);

  final double? units;
  final ConsumptionOutcome outcome;

  bool get hasUnits => units != null;
  bool get isAnomaly => outcome == ConsumptionOutcome.anomaly;
}

/// Cycle-over-cycle comparison produced by [compareCycles].
class CycleComparison {
  const CycleComparison({
    required this.absoluteDelta,
    required this.percentDelta,
  });

  /// currentUnits − previousUnits (negative means consumption fell).
  final double absoluteDelta;

  /// Percentage change vs. the previous cycle (e.g. `45.0` == +45%).
  final double percentDelta;

  bool get isIncrease => absoluteDelta > 0;
}

/// Units consumed between a [previous] and [current] reading.
///
/// See [ConsumptionOutcome] for the four cases. Wrapped consumption when a
/// physical meter rolls past its maximum is `(rolloverMax − previous) + current`.
ConsumptionResult unitsConsumed(
  double current,
  double? previous, {
  double? rolloverMax,
}) {
  if (previous == null) return const ConsumptionResult.noPrevious();
  if (current >= previous) {
    return ConsumptionResult.normal(current - previous);
  }
  // current < previous: either the meter wrapped or the entry is wrong.
  if (rolloverMax != null && rolloverMax >= previous) {
    return ConsumptionResult.rollover((rolloverMax - previous) + current);
  }
  return const ConsumptionResult.anomaly();
}

/// Average units per day over [days]. Returns `null` for a non-positive span
/// (e.g. two readings on the same calendar day) rather than dividing by zero.
double? averagePerDay(double units, int days) {
  if (days <= 0) return null;
  return units / days;
}

/// Average units per week, derived from a daily average. Null-safe passthrough.
double? averagePerWeek(double? perDay) => perDay == null ? null : perDay * 7;

/// Projects total units by the end of a window.
///
/// Used twice: with days remaining in the calendar month (projected month-end)
/// and with days remaining in the billing cycle (projected bill units). Returns
/// `null` when [perDay] is unknown; returns [unitsSoFar] unchanged when the
/// window has already ended.
double? projectedUnits({
  required double unitsSoFar,
  required double? perDay,
  required int remainingDays,
}) {
  if (perDay == null) return null;
  if (remainingDays <= 0) return unitsSoFar;
  return unitsSoFar + perDay * remainingDays;
}

/// Highest value in [values], or `null` if empty.
double? highestReading(List<double> values) =>
    values.isEmpty ? null : values.reduce((a, b) => a > b ? a : b);

/// Lowest value in [values], or `null` if empty.
double? lowestReading(List<double> values) =>
    values.isEmpty ? null : values.reduce((a, b) => a < b ? a : b);

/// Average monthly consumption (normalised to a 30-day month) across completed
/// [cycles]. Returns `null` when there are no cycles with a positive span.
double? averageMonthlyConsumption(List<CycleConsumption> cycles) {
  final rate = _averageDailyRate(cycles);
  return rate == null ? null : rate * 30;
}

/// Average yearly consumption (normalised to 365 days) across completed
/// [cycles]. Returns `null` when there are no cycles with a positive span.
double? averageYearlyConsumption(List<CycleConsumption> cycles) {
  final rate = _averageDailyRate(cycles);
  return rate == null ? null : rate * 365;
}

/// Mean of each cycle's daily rate (units/day), giving every cycle equal weight
/// regardless of length. Ignores cycles with a non-positive span.
double? _averageDailyRate(List<CycleConsumption> cycles) {
  final valid = cycles.where((c) => c.days > 0).toList();
  if (valid.isEmpty) return null;
  final total = valid.fold<double>(0, (sum, c) => sum + c.totalUnits / c.days);
  return total / valid.length;
}

/// Compares this cycle's usage against the previous cycle. Returns `null` when
/// there is no previous cycle or its usage was zero (no divide-by-zero).
CycleComparison? compareCycles(double currentUnits, double? previousUnits) {
  if (previousUnits == null || previousUnits == 0) return null;
  final delta = currentUnits - previousUnits;
  return CycleComparison(
    absoluteDelta: delta,
    percentDelta: delta / previousUnits * 100,
  );
}
