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

    test(
        'measures the day span from the previous reading when the cycle holds '
        'only one', () {
      // A single reading on 1 Jul against a previous cycle reading on 15 Jun:
      // 100 units over 16 days. Previously the span was measured from the lone
      // cycle reading to itself (0 days), so every day-based figure came back
      // null and the card showed em dashes.
      final summary = compute(
        meter: testMeter,
        cycle: testCycle,
        cycleReadings: [r1],
        latestBill: null,
        now: now,
        previousReadingOverride: prevCycleReading,
      );

      expect(summary.unitsUsed, 100.0);
      expect(summary.averagePerDay, closeTo(100 / 16, 0.001));
      expect(summary.projectedMonthEndUnits, isNotNull);
      expect(summary.paceForecast, isNotNull);
      expect(summary.paceForecast!.dailyRate, closeTo(100 / 16, 0.001));
    });

    test(
        'spans from the scheduled reading day when units come from a bill and '
        'the reading opened the cycle', () {
      // Mirrors real data seen on device: one reading ever, no previous
      // reading, and a bill whose stored date is just when it was keyed in.
      // The cycle was opened *by* this reading, so cycleStartDate is the same
      // day — measuring from either that or billDate gives a ~0–1 day span and
      // a wildly overstated rate. The meter reads on the 15th, so the billed
      // reading is from 15 Jul.
      final meter = Meter(
        id: 1,
        name: 'First Floor',
        type: MeterType.electricity,
        unit: 'kWh',
        expectedReadingDayOfMonth: 15,
        highUsageThreshold: 199,
        createdAt: DateTime(2026, 1, 1),
      );

      final reading = Reading(
        id: 200,
        meterId: 1,
        readingValue: 20970,
        readingDate: DateTime(2026, 7, 25),
        createdAt: DateTime(2026, 7, 25),
      );

      final cycle = BillingCycle(
        id: 11,
        meterId: 1,
        cycleStartDate: DateTime(2026, 7, 25),
        expectedReadingDate: DateTime(2026, 8, 15),
        createdAt: DateTime(2026, 7, 25),
      );

      // `meterReading` is the absolute meter total printed on the bill and is
      // what opens the cycle. `unitsBilled` is the consumption charged and must
      // never be substituted for it — the deliberately small value here would
      // yield 20970 − 56 if the two were ever confused again.
      final bill = Bill(
        id: 51,
        meterId: 1,
        billAmount: 11183.0,
        billDate: DateTime(2026, 7, 24),
        unitsBilled: 56,
        meterReading: 20914,
        createdAt: DateTime(2026, 7, 24),
      );

      final summary = compute(
        meter: meter,
        cycle: cycle,
        cycleReadings: [reading],
        latestBill: bill,
        now: DateTime(2026, 7, 26),
      );

      // 20970 − 20914 = 56 units, 15 Jul → 25 Jul = 10 days ⇒ 5.6/day.
      expect(summary.unitsUsed, 56.0);
      expect(summary.averagePerDay, closeTo(5.6, 0.001));
      // 56 + 5.6 × 5 remaining days in July.
      expect(summary.projectedMonthEndUnits, closeTo(84.0, 0.001));
      expect(summary.paceForecast, isNotNull);
      expect(summary.paceForecast!.dailyRate, closeTo(5.6, 0.001));
    });

    test('measures from the billed reading even once the cycle has two readings',
        () {
      // The reported regression. With one reading the billed figure was used and
      // the total was right; adding a second silently switched the basis to the
      // last two readings (20,981 − 20,970 = 11) instead of measuring the whole
      // period from the bill (20,981 − 20,914 = 67).
      final meter = Meter(
        id: 1,
        name: 'First Floor',
        type: MeterType.electricity,
        unit: 'kWh',
        expectedReadingDayOfMonth: 15,
        highUsageThreshold: 199,
        createdAt: DateTime(2026, 1, 1),
      );

      final cycle = BillingCycle(
        id: 11,
        meterId: 1,
        cycleStartDate: DateTime(2026, 7, 25),
        expectedReadingDate: DateTime(2026, 8, 15),
        createdAt: DateTime(2026, 7, 25),
      );

      // Billed 24 Jul, but the reading it states was taken on the meter's
      // scheduled day (the 15th) — so the span starts there, not at billDate.
      final bill = Bill(
        id: 51,
        meterId: 1,
        billAmount: 11183.0,
        billDate: DateTime(2026, 7, 24),
        unitsBilled: 67,
        meterReading: 20914,
        createdAt: DateTime(2026, 7, 24),
      );

      final summary = compute(
        meter: meter,
        cycle: cycle,
        cycleReadings: [
          Reading(
            id: 200,
            meterId: 1,
            readingValue: 20970,
            readingDate: DateTime(2026, 7, 25),
            createdAt: DateTime(2026, 7, 25),
          ),
          Reading(
            id: 201,
            meterId: 1,
            readingValue: 20981,
            readingDate: DateTime(2026, 7, 27),
            createdAt: DateTime(2026, 7, 27),
          ),
        ],
        latestBill: bill,
        now: DateTime(2026, 7, 27),
      );

      // 20981 − 20914 = 67 units over 15 Jul → 27 Jul = 12 days ⇒ 5.58/day.
      expect(summary.unitsUsed, 67.0);
      expect(summary.averagePerDay, closeTo(5.583, 0.001));
      expect(summary.currentReading?.readingValue, 20981);
    });

    test('ignores a billed reading above the cycle readings', () {
      // A bill stating a total higher than the readings cannot be this period's
      // opening value, so the cycle's own baseline must win rather than
      // producing a nonsensical or negative figure.
      final bill = Bill(
        id: 52,
        meterId: 1,
        billAmount: 100.0,
        billDate: DateTime(2026, 7, 24),
        meterReading: 999999,
        createdAt: DateTime(2026, 7, 24),
      );

      final summary = compute(
        meter: testMeter,
        cycle: testCycle,
        cycleReadings: [r1, r2],
        latestBill: bill,
        now: now,
      );

      expect(summary.unitsUsed, 250.0);
    });

    test('leaves day-based figures null when only a baseline reading exists',
        () {
      // Nothing to measure against: no previous reading and no bill. A zero-day
      // span must stay null rather than dividing by zero.
      final summary = compute(
        meter: testMeter,
        cycle: testCycle,
        cycleReadings: [r1],
        latestBill: null,
        now: now,
      );

      expect(summary.unitsUsed, 0.0);
      expect(summary.averagePerDay, isNull);
      expect(summary.paceForecast, isNull);
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

    test('computes paceForecast when meter has highUsageThreshold configured', () {
      // Create meter entity with highUsageThreshold = 300
      final meterThreshold = Meter(
        id: 1,
        name: 'Electric Meter',
        type: MeterType.electricity,
        unit: 'kWh',
        expectedReadingDayOfMonth: 25,
        highUsageThreshold: 300,
        createdAt: DateTime(2026, 1, 1),
      );

      // r1: July 15 (reading 1000), r2: July 25 (reading 1100) -> 10 days, 100 units (10/day)
      final baseline = Reading(
        id: 10,
        meterId: 1,
        readingValue: 1000.0,
        readingDate: DateTime(2026, 7, 15),
        createdAt: DateTime(2026, 7, 15),
      );
      final current = Reading(
        id: 11,
        meterId: 1,
        readingValue: 1100.0,
        readingDate: DateTime(2026, 7, 25),
        createdAt: DateTime(2026, 7, 25),
      );
      final targetCycle = BillingCycle(
        id: 10,
        meterId: 1,
        cycleStartDate: DateTime(2026, 7, 15),
        expectedReadingDate: DateTime(2026, 8, 14), // 20 days remaining from July 25
        createdAt: DateTime(2026, 7, 15),
      );

      final summary = compute(
        meter: meterThreshold,
        cycle: targetCycle,
        cycleReadings: [baseline, current],
        latestBill: null,
        now: DateTime(2026, 7, 25),
      );

      expect(summary.paceForecast, isNotNull);
      expect(summary.paceForecast!.dailyRate, 10.0);
      expect(summary.paceForecast!.projectedUnits, 300.0);
      // Projected 300 units == target 300 -> Orange/Red boundary (300 >= 300 * 1.0 -> Red)
      expect(summary.paceForecast!.percentOfLimit, 100.0);
    });
  });
}

