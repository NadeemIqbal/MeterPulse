import 'package:flutter_test/flutter_test.dart';
import 'package:meter_pulse/features/analytics/domain/usecases/compute_global_stats.dart';
import 'package:meter_pulse/features/meters/domain/entities/meter.dart';
import 'package:meter_pulse/features/meters/domain/entities/meter_type.dart';
import 'package:meter_pulse/features/readings/domain/entities/reading.dart';

void main() {
  const compute = ComputeGlobalStats();
  final now = DateTime(2026, 7, 25);

  Meter meter({
    required int id,
    required MeterType type,
    String unit = 'kWh',
    double? threshold,
    double? rollover,
  }) {
    return Meter(
      id: id,
      name: 'Meter $id',
      type: type,
      unit: unit,
      expectedReadingDayOfMonth: 1,
      highUsageThreshold: threshold,
      rolloverValue: rollover,
      createdAt: DateTime(2026, 1, 1),
    );
  }

  Reading reading(int meterId, double value, DateTime date) => Reading(
        meterId: meterId,
        readingValue: value,
        readingDate: date,
        createdAt: date,
      );

  group('ComputeGlobalStats', () {
    test('returns empty stats when no meter matches the type', () {
      final stats = compute(
        type: MeterType.water,
        meterReadings: [
          (
            meter: meter(id: 1, type: MeterType.electricity),
            readings: [reading(1, 100, DateTime(2026, 5, 1))],
          ),
        ],
        now: now,
      );

      expect(stats.hasData, isFalse);
      expect(stats.meterCount, 0);
      expect(stats.totalUnits, 0);
    });

    test('sums reading deltas across every meter of the type', () {
      final stats = compute(
        type: MeterType.electricity,
        meterReadings: [
          (
            meter: meter(id: 1, type: MeterType.electricity),
            readings: [
              reading(1, 100, DateTime(2026, 5, 1)),
              reading(1, 180, DateTime(2026, 6, 1)),
            ],
          ),
          (
            meter: meter(id: 2, type: MeterType.electricity),
            readings: [
              reading(2, 500, DateTime(2026, 5, 1)),
              reading(2, 520, DateTime(2026, 6, 1)),
            ],
          ),
        ],
        now: now,
      );

      expect(stats.meterCount, 2);
      expect(stats.readingCount, 4);
      expect(stats.totalUnits, 100); // 80 + 20, both landing in June
      expect(stats.monthlyUsage.single.units, 100);
    });

    test('excludes meters of other types from the totals', () {
      final stats = compute(
        type: MeterType.electricity,
        meterReadings: [
          (
            meter: meter(id: 1, type: MeterType.electricity),
            readings: [
              reading(1, 100, DateTime(2026, 5, 1)),
              reading(1, 180, DateTime(2026, 6, 1)),
            ],
          ),
          (
            meter: meter(id: 2, type: MeterType.gas, unit: 'm³'),
            readings: [
              reading(2, 10, DateTime(2026, 5, 1)),
              reading(2, 9999, DateTime(2026, 6, 1)),
            ],
          ),
        ],
        now: now,
      );

      expect(stats.meterCount, 1);
      expect(stats.unit, 'kWh');
      expect(stats.totalUnits, 80);
    });

    test('buckets usage into the calendar month of the later reading', () {
      final stats = compute(
        type: MeterType.electricity,
        meterReadings: [
          (
            meter: meter(id: 1, type: MeterType.electricity),
            readings: [
              reading(1, 0, DateTime(2026, 4, 1)),
              reading(1, 50, DateTime(2026, 5, 3)),
              reading(1, 130, DateTime(2026, 6, 2)),
            ],
          ),
        ],
        now: now,
      );

      expect(stats.monthlyUsage, hasLength(2));
      expect(stats.monthlyUsage[0].month, DateTime(2026, 5));
      expect(stats.monthlyUsage[0].units, 50);
      expect(stats.monthlyUsage[1].month, DateTime(2026, 6));
      expect(stats.monthlyUsage[1].units, 80);
    });

    test('reports the peak month and the monthly average', () {
      final stats = compute(
        type: MeterType.electricity,
        meterReadings: [
          (
            meter: meter(id: 1, type: MeterType.electricity),
            readings: [
              reading(1, 0, DateTime(2026, 4, 1)),
              reading(1, 40, DateTime(2026, 5, 1)),
              reading(1, 160, DateTime(2026, 6, 1)),
            ],
          ),
        ],
        now: now,
      );

      expect(stats.peakMonthlyUnits, 120);
      expect(stats.peakMonth, DateTime(2026, 6));
      expect(stats.averageMonthlyUnits, 80); // (40 + 120) / 2
    });

    test('skips anomalous backwards readings instead of counting them', () {
      final stats = compute(
        type: MeterType.electricity,
        meterReadings: [
          (
            meter: meter(id: 1, type: MeterType.electricity),
            readings: [
              reading(1, 100, DateTime(2026, 5, 1)),
              reading(1, 60, DateTime(2026, 6, 1)), // typo, no rollover set
              reading(1, 90, DateTime(2026, 7, 1)),
            ],
          ),
        ],
        now: now,
      );

      // Only the 60 → 90 step is trusted.
      expect(stats.totalUnits, 30);
      expect(stats.monthlyUsage.single.month, DateTime(2026, 7));
    });

    test('compares the last two complete months, ignoring the current one', () {
      final stats = compute(
        type: MeterType.electricity,
        meterReadings: [
          (
            meter: meter(id: 1, type: MeterType.electricity),
            readings: [
              reading(1, 0, DateTime(2026, 4, 1)),
              reading(1, 100, DateTime(2026, 5, 1)),
              reading(1, 188, DateTime(2026, 6, 1)),
              reading(1, 200, DateTime(2026, 7, 20)), // partial current month
            ],
          ),
        ],
        now: now,
      );

      // June (88) vs May (100) → 12% lower. July is excluded.
      expect(stats.previousPeriodChangePercent, closeTo(-12, 0.001));
    });

    test('combines per-meter thresholds into the pace forecast target', () {
      final stats = compute(
        type: MeterType.electricity,
        meterReadings: [
          (
            meter: meter(id: 1, type: MeterType.electricity, threshold: 300),
            readings: [
              reading(1, 0, DateTime(2026, 7, 1)),
              reading(1, 120, DateTime(2026, 7, 21)),
            ],
          ),
          (
            meter: meter(id: 2, type: MeterType.electricity, threshold: 200),
            readings: [
              reading(2, 0, DateTime(2026, 7, 1)),
              reading(2, 30, DateTime(2026, 7, 21)),
            ],
          ),
        ],
        now: now,
      );

      expect(stats.targetLimit, 500);
      expect(stats.currentCycleUnits, 150);
      expect(stats.paceForecast, isNotNull);
      expect(stats.paceForecast!.targetLimit, 500);
    });

    test('leaves the target null when any meter has no threshold', () {
      final stats = compute(
        type: MeterType.electricity,
        meterReadings: [
          (
            meter: meter(id: 1, type: MeterType.electricity, threshold: 300),
            readings: [
              reading(1, 0, DateTime(2026, 7, 1)),
              reading(1, 120, DateTime(2026, 7, 21)),
            ],
          ),
          (
            meter: meter(id: 2, type: MeterType.electricity),
            readings: [
              reading(2, 0, DateTime(2026, 7, 1)),
              reading(2, 30, DateTime(2026, 7, 21)),
            ],
          ),
        ],
        now: now,
      );

      expect(stats.targetLimit, isNull);
      expect(stats.paceForecast?.targetLimit, isNull);
    });

    test('honours a configured rollover instead of flagging an anomaly', () {
      final stats = compute(
        type: MeterType.electricity,
        meterReadings: [
          (
            meter: meter(id: 1, type: MeterType.electricity, rollover: 1000),
            readings: [
              reading(1, 980, DateTime(2026, 6, 1)),
              reading(1, 30, DateTime(2026, 7, 1)),
            ],
          ),
        ],
        now: now,
      );

      expect(stats.totalUnits, 50); // 1000 − 980 + 30
    });
  });
}
