import '../../../../core/calculation_engine/consumption_calculator.dart';
import '../../../../core/calculation_engine/date_math.dart';
import '../../../analytics/domain/detect_usage_alerts.dart';
import '../../../bills/domain/entities/bill.dart';
import '../../../billing_cycles/domain/entities/billing_cycle.dart';
import '../../../meters/domain/entities/meter.dart';
import '../../../readings/domain/entities/reading.dart';
import '../entities/meter_summary.dart';

/// Pure composition of a meter's raw data into a [MeterSummary].
///
/// Takes already-fetched data plus [now] (injected, never `DateTime.now()`
/// internally) so it is deterministic and unit-testable. Delegates all maths to
/// the calculation engine.
class ComputeMeterSummary {
  const ComputeMeterSummary();

  /// [cycleReadings] must be the current cycle's readings ordered oldest-first.
  MeterSummary call({
    required Meter meter,
    required BillingCycle? cycle,
    required List<Reading> cycleReadings,
    required Bill? latestBill,
    required DateTime now,
    Reading? previousReadingOverride,
  }) {
    final readingCount = cycleReadings.length;
    final baseline = cycleReadings.isNotEmpty ? cycleReadings.first : null;
    final current = cycleReadings.isNotEmpty
        ? cycleReadings.last
        : previousReadingOverride;
    final previous = readingCount >= 2
        ? cycleReadings[readingCount - 2]
        : previousReadingOverride;

    // [unitsUsed] and the date it is measured *from* must stay in step. When the
    // figure comes from a fallback — a reading in the previous cycle, or the
    // last bill — the elapsed span has to start there too. Measuring from
    // [baseline] regardless meant a cycle holding a single reading spanned zero
    // days, so avg/day, the month-end projection and the pace forecast all
    // silently collapsed to null even though unitsUsed was known.
    var unitsUsed = _unitsUsed(baseline, current, meter.rolloverValue);
    DateTime? measuredFrom =
        (unitsUsed != null && unitsUsed > 0) ? baseline?.readingDate : null;

    if ((unitsUsed == null || unitsUsed == 0) &&
        current != null &&
        previous != null &&
        (current.id != previous.id || current.readingValue != previous.readingValue)) {
      unitsUsed = unitsConsumed(
        current.readingValue,
        previous.readingValue,
        rolloverMax: meter.rolloverValue,
      ).units;
      measuredFrom = previous.readingDate;
    }
    // Falls back to the meter reading printed on the last bill as this cycle's
    // opening value. This must be `meterReading` (an absolute meter total), not
    // `unitsBilled` (the consumption the provider charged) — the two were once
    // the same field, so feeding billed units in here as an opening reading
    // produced anomalies or a flat zero for every derived figure.
    if ((unitsUsed == null || unitsUsed == 0) &&
        current != null &&
        latestBill?.meterReading != null &&
        current.readingValue != latestBill!.meterReading) {
      unitsUsed = unitsConsumed(
        current.readingValue,
        latestBill.meterReading!,
        rolloverMax: meter.rolloverValue,
      ).units;
      // The billed figure is this cycle's opening reading, but nothing records
      // when it was taken: `billDate` is when the bill was keyed in, and
      // `cycleStartDate` is when the *current* reading opened the cycle (often
      // the same day, giving a zero span). The meter's scheduled reading day is
      // the best available estimate, so fall back to its previous occurrence.
      measuredFrom = previousReadingDate(
        meter.expectedReadingDayOfMonth,
        from: current.readingDate,
      );
    }
    measuredFrom ??= baseline?.readingDate;

    final elapsedDays = (measuredFrom != null && current != null)
        ? daysBetween(measuredFrom, current.readingDate)
        : null;

    final avgPerDay = (unitsUsed != null && elapsedDays != null)
        ? averagePerDay(unitsUsed, elapsedDays)
        : null;

    final projected = projectedUnits(
      unitsSoFar: unitsUsed ?? 0,
      perDay: avgPerDay,
      remainingDays: daysRemainingInMonth(now),
    );

    final paceForecast = (current != null &&
            unitsUsed != null &&
            unitsUsed > 0 &&
            elapsedDays != null)
        ? calculatePaceForecast(
            unitsSoFar: unitsUsed,
            daysElapsed: elapsedDays,
            remainingDays: cycle?.expectedReadingDate != null
                ? daysUntil(cycle!.expectedReadingDate!, from: current.readingDate)
                : daysRemainingInMonth(now),
            currentReadingDate: current.readingDate,
            targetLimit: meter.highUsageThreshold ?? meter.expectedMonthlyUnits,
          )
        : null;

    final daysUntilReading = cycle?.expectedReadingDate == null
        ? null
        : daysUntil(cycle!.expectedReadingDate!, from: now);

    final daysUntilBill =
        (latestBill?.dueDate == null || (latestBill?.isPaid ?? false))
            ? null
            : daysUntil(latestBill!.dueDate!, from: now);

    final alerts = detectUsageAlerts(
      meter: meter,
      cycleReadings: cycleReadings,
      unitsUsed: unitsUsed,
      projectedMonthEnd: projected,
      now: now,
    );

    return MeterSummary(
      meter: meter,
      cycle: cycle,
      currentReading: current,
      previousReading: previous,
      latestBill: latestBill,
      unitsUsed: unitsUsed,
      averagePerDay: avgPerDay,
      projectedMonthEndUnits: projected,
      paceForecast: paceForecast,
      daysUntilReading: daysUntilReading,
      daysUntilBill: daysUntilBill,
      readingCount: readingCount,
      readingStatus: _readingStatus(meter, readingCount, daysUntilReading),
      billStatus: _billStatus(latestBill, daysUntilBill),
      highUsageExceeded: alerts.any((a) => a.isHigh),
      alerts: alerts,
    );
  }

  double? _unitsUsed(Reading? baseline, Reading? current, double? rolloverMax) {
    if (baseline == null || current == null) return null;
    if (identical(baseline, current)) return 0; // only the baseline so far
    final result = unitsConsumed(
      current.readingValue,
      baseline.readingValue,
      rolloverMax: rolloverMax,
    );
    return result.units; // null on anomaly — surfaces as "—" in the UI
  }

  ReadingStatus _readingStatus(Meter meter, int readingCount, int? daysUntil) {
    if (readingCount == 0 || daysUntil == null) return ReadingStatus.noReadings;
    if (daysUntil < 0) return ReadingStatus.overdue;
    final lead = meter.reminderStartDaysBefore ?? 3;
    if (daysUntil <= lead) return ReadingStatus.dueSoon;
    return ReadingStatus.upToDate;
  }

  BillStatus _billStatus(Bill? bill, int? daysUntil) {
    if (bill == null) return BillStatus.noBill;
    if (bill.isPaid) return BillStatus.paid;
    if (daysUntil == null) return BillStatus.unpaid;
    if (daysUntil < 0) return BillStatus.overdue;
    if (daysUntil <= 3) return BillStatus.dueSoon;
    return BillStatus.unpaid;
  }

}
