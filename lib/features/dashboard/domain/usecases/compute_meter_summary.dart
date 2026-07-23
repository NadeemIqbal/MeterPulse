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
  }) {
    final readingCount = cycleReadings.length;
    final baseline = cycleReadings.isNotEmpty ? cycleReadings.first : null;
    final current = cycleReadings.isNotEmpty ? cycleReadings.last : null;
    final previous =
        readingCount >= 2 ? cycleReadings[readingCount - 2] : null;

    final unitsUsed = _unitsUsed(baseline, current, meter.rolloverValue);
    final avgPerDay = _averagePerDay(baseline, current, unitsUsed);
    final projected = projectedUnits(
      unitsSoFar: unitsUsed ?? 0,
      perDay: avgPerDay,
      remainingDays: daysRemainingInMonth(now),
    );

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

  double? _averagePerDay(Reading? baseline, Reading? current, double? units) {
    if (baseline == null || current == null || units == null) return null;
    return averagePerDay(units, daysBetween(baseline.readingDate, current.readingDate));
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
