import 'package:equatable/equatable.dart';

import '../../../analytics/domain/entities/usage_alert.dart';
import '../../../bills/domain/entities/bill.dart';
import '../../../billing_cycles/domain/entities/billing_cycle.dart';
import '../../../meters/domain/entities/meter.dart';
import '../../../readings/domain/entities/reading.dart';

/// Where the meter stands on taking its next reading.
enum ReadingStatus { noReadings, upToDate, dueSoon, overdue }

/// Where the meter stands on its latest bill.
enum BillStatus { noBill, paid, dueSoon, overdue, unpaid }

/// Everything the dashboard card needs for one meter, precomputed by
/// [ComputeMeterSummary] so the widget layer only formats and renders.
class MeterSummary extends Equatable {
  const MeterSummary({
    required this.meter,
    this.cycle,
    this.currentReading,
    this.previousReading,
    this.latestBill,
    this.unitsUsed,
    this.averagePerDay,
    this.projectedMonthEndUnits,
    this.daysUntilReading,
    this.daysUntilBill,
    required this.readingCount,
    required this.readingStatus,
    required this.billStatus,
    this.highUsageExceeded = false,
    this.alerts = const [],
  });

  final Meter meter;
  final BillingCycle? cycle;

  /// Latest and prior reading in the current cycle.
  final Reading? currentReading;
  final Reading? previousReading;

  final Bill? latestBill;

  /// Units used so far this cycle (current − cycle baseline). Null when there
  /// are no readings yet.
  final double? unitsUsed;
  final double? averagePerDay;
  final double? projectedMonthEndUnits;

  /// Negative means overdue.
  final int? daysUntilReading;
  final int? daysUntilBill;

  final int readingCount;
  final ReadingStatus readingStatus;
  final BillStatus billStatus;

  /// True when usage or the projection has crossed the configured threshold.
  final bool highUsageExceeded;

  /// Rule-based alerts for this meter's current cycle (threshold / spike).
  final List<UsageAlert> alerts;

  UsageAlert? get topAlert => alerts.isEmpty ? null : alerts.first;

  DateTime? get lastReadingDate => currentReading?.readingDate;
  DateTime? get lastBillDate => latestBill?.billDate;

  @override
  List<Object?> get props => [
        meter,
        cycle,
        currentReading,
        previousReading,
        latestBill,
        unitsUsed,
        averagePerDay,
        projectedMonthEndUnits,
        daysUntilReading,
        daysUntilBill,
        readingCount,
        readingStatus,
        billStatus,
        highUsageExceeded,
        alerts,
      ];
}
