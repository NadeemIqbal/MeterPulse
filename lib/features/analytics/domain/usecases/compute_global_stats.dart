import '../../../../core/calculation_engine/consumption_calculator.dart';
import '../../../../core/calculation_engine/date_math.dart';
import '../../../meters/domain/entities/meter.dart';
import '../../../meters/domain/entities/meter_type.dart';
import '../../../readings/domain/entities/reading.dart';
import '../entities/global_stats.dart';

/// One meter's readings, oldest first, as fetched by the cubit.
typedef MeterReadings = ({Meter meter, List<Reading> readings});

/// Aggregates every meter of one [MeterType] into a single [GlobalStats].
///
/// Consumption is derived from consecutive reading deltas (not raw odometer
/// values) and attributed to the calendar month of the later reading, so a
/// meter read on the 3rd credits its usage to that month.
class ComputeGlobalStats {
  const ComputeGlobalStats();

  GlobalStats call({
    required MeterType type,
    required List<MeterReadings> meterReadings,
    required DateTime now,
  }) {
    final contributing =
        meterReadings.where((m) => m.meter.type == type).toList();
    if (contributing.isEmpty) return GlobalStats.empty(type);

    final byMonth = <DateTime, double>{};
    var totalUnits = 0.0;
    var readingCount = 0;

    for (final entry in contributing) {
      readingCount += entry.readings.length;

      for (var i = 1; i < entry.readings.length; i++) {
        final previous = entry.readings[i - 1];
        final current = entry.readings[i];
        final units = unitsConsumed(
          current.readingValue,
          previous.readingValue,
          rolloverMax: entry.meter.rolloverValue,
        ).units;

        // Anomalies (a reading below its predecessor with no rollover
        // configured) yield null and are skipped rather than counted as zero.
        if (units == null) continue;

        totalUnits += units;
        final month = _monthOf(current.readingDate);
        byMonth[month] = (byMonth[month] ?? 0) + units;
      }
    }

    final monthlyUsage = byMonth.entries
        .map((e) => MonthlyUsage(month: e.key, units: e.value))
        .toList()
      ..sort((a, b) => a.month.compareTo(b.month));

    final peak = _peak(monthlyUsage);

    return GlobalStats(
      type: type,
      unit: contributing.first.meter.unit,
      meterCount: contributing.length,
      readingCount: readingCount,
      totalUnits: totalUnits,
      averageMonthlyUnits:
          monthlyUsage.isEmpty ? null : totalUnits / monthlyUsage.length,
      peakMonthlyUnits: peak?.units,
      peakMonth: peak?.month,
      previousPeriodChangePercent: _changeVsPriorMonth(monthlyUsage, now),
      paceForecast: _paceForecast(monthlyUsage, contributing, now),
      currentCycleUnits: _unitsIn(monthlyUsage, _monthOf(now)),
      targetLimit: _combinedLimit(contributing),
      monthlyUsage: monthlyUsage,
    );
  }

  DateTime _monthOf(DateTime date) => DateTime(date.year, date.month);

  MonthlyUsage? _peak(List<MonthlyUsage> months) {
    if (months.isEmpty) return null;
    return months.reduce((a, b) => b.units > a.units ? b : a);
  }

  double? _unitsIn(List<MonthlyUsage> months, DateTime month) {
    for (final m in months) {
      if (m.month == month) return m.units;
    }
    return null;
  }

  /// Compares the last two *complete* months, so a partially elapsed current
  /// month never reads as a spurious drop.
  double? _changeVsPriorMonth(List<MonthlyUsage> months, DateTime now) {
    final currentMonth = _monthOf(now);
    final complete = months.where((m) => m.month.isBefore(currentMonth)).toList();
    if (complete.length < 2) return null;

    final latest = complete[complete.length - 1].units;
    final prior = complete[complete.length - 2].units;
    if (prior == 0) return null;

    return ((latest - prior) / prior) * 100;
  }

  /// Aggregate pace for the month in progress. Days elapsed is measured from
  /// the first of the month so a portfolio read on different days still gets a
  /// comparable daily rate.
  PaceForecast? _paceForecast(
    List<MonthlyUsage> months,
    List<MeterReadings> contributing,
    DateTime now,
  ) {
    final unitsSoFar = _unitsIn(months, _monthOf(now));
    if (unitsSoFar == null || unitsSoFar <= 0) return null;

    final daysElapsed = daysBetween(_monthOf(now), now);
    if (daysElapsed <= 0) return null;

    return calculatePaceForecast(
      unitsSoFar: unitsSoFar,
      daysElapsed: daysElapsed,
      remainingDays: daysRemainingInMonth(now),
      currentReadingDate: now,
      targetLimit: _combinedLimit(contributing),
    );
  }

  /// Sums per-meter thresholds. Returns null unless every contributing meter
  /// sets one — a partial total would understate the real budget.
  double? _combinedLimit(List<MeterReadings> contributing) {
    var total = 0.0;
    for (final entry in contributing) {
      final limit =
          entry.meter.highUsageThreshold ?? entry.meter.expectedMonthlyUnits;
      if (limit == null) return null;
      total += limit;
    }
    return total == 0 ? null : total;
  }
}
