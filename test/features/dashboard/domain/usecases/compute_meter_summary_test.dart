import 'package:flutter_test/flutter_test.dart';
import 'package:meter_pulse/features/billing_cycles/domain/entities/billing_cycle.dart';
import 'package:meter_pulse/features/bills/domain/entities/bill.dart';
import 'package:meter_pulse/features/dashboard/domain/usecases/compute_meter_summary.dart';
import 'package:meter_pulse/features/meters/domain/entities/meter.dart';
import 'package:meter_pulse/features/meters/domain/entities/meter_type.dart';
import 'package:meter_pulse/features/readings/domain/entities/reading.dart';

void main() {
  const compute = ComputeMeterSummary();
  final now = DateTime(2026, 7, 25);

  final testMeter = Meter(
    id: 1,
    name: 'Electric Meter',
    type: MeterType.electricity,
    unit: 'kWh',
    expectedReadingDayOfMonth: 25,
    createdAt: DateTime(2026, 1, 1),
  );

  final testCycle = BillingCycle(
    id: 10,
    meterId: 1,
    cycleStartDate: DateTime(2026, 7, 1),
    expectedReadingDate: DateTime(2026, 7, 25),
    createdAt: DateTime(2026, 7, 1),
  );

  final r1 = Reading(
    id: 100,
    meterId: 1,
    readingValue: 1000.0,
    readingDate: DateTime(2026, 7, 1),
    createdAt: DateTime(2026, 7, 1),
  );

  final r2 = Reading(
    id: 101,
    meterId: 1,
    readingValue: 1250.0,
    readingDate: DateTime(2026, 7, 15),
    createdAt: DateTime(2026, 7, 15),
  );

  final prevCycleReading = Reading(
    id: 99,
    meterId: 1,
    readingValue: 900.0,
    readingDate: DateTime(2026, 6, 15),
    createdAt: DateTime(2026, 6, 15),
  );

  group('ComputeMeterSummary', () {
    test('computes unitsUsed and averagePerDay for multiple cycle readings', () {
      final summary = compute(
        meter: testMeter,
        cycle: testCycle,
        cycleReadings: [r1, r2],
        latestBill: null,
        now: now,
      );

      expect(summary.currentReading, r2);
      expect(summary.previousReading, r1);
      expect(summary.unitsUsed, 250.0);
      expect(summary.averagePerDay, closeTo(17.85, 0.1));
    });

    test('uses previousReadingOverride when single reading in current cycle', () {
      final summary = compute(
        meter: testMeter,
        cycle: testCycle,
        cycleReadings: [r1],
        latestBill: null,
        now: now,
        previousReadingOverride: prevCycleReading,
      );

      expect(summary.currentReading, r1);
      expect(summary.previousReading, prevCycleReading);
      expect(summary.unitsUsed, 100.0);
    });

    test('computes bill and reading status correctly', () {
      final testBill = Bill(
        id: 50,
        meterId: 1,
        billAmount: 150.0,
        billDate: DateTime(2026, 7, 10),
        dueDate: DateTime(2026, 7, 28),
        isPaid: false,
        createdAt: DateTime(2026, 7, 10),
      );

      final summary = compute(
        meter: testMeter,
        cycle: testCycle,
        cycleReadings: [r1, r2],
        latestBill: testBill,
        now: now,
      );

      expect(summary.daysUntilReading, 0);
      expect(summary.daysUntilBill, 3);
    });
  });
}
