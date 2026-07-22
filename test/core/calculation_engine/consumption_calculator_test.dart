import 'package:flutter_test/flutter_test.dart';
import 'package:meter_pulse/core/calculation_engine/consumption_calculator.dart';
import 'package:meter_pulse/core/calculation_engine/models/cycle_consumption.dart';

void main() {
  group('unitsConsumed', () {
    test('returns forward difference when current > previous', () {
      final result = unitsConsumed(12518, 12500);
      expect(result.outcome, ConsumptionOutcome.normal);
      expect(result.units, 18);
    });

    test('returns 0 when current == previous', () {
      final result = unitsConsumed(12500, 12500);
      expect(result.outcome, ConsumptionOutcome.normal);
      expect(result.units, 0);
    });

    test('returns noPrevious (null units) for the first reading in a cycle', () {
      final result = unitsConsumed(12500, null);
      expect(result.outcome, ConsumptionOutcome.noPrevious);
      expect(result.units, isNull);
      expect(result.hasUnits, isFalse);
    });

    test('flags an anomaly when current < previous and no rollover configured',
        () {
      final result = unitsConsumed(120, 12500);
      expect(result.outcome, ConsumptionOutcome.anomaly);
      expect(result.units, isNull);
      expect(result.isAnomaly, isTrue);
    });

    test('computes wrapped units when current < previous and rollover is set',
        () {
      // Meter wraps at 99999: was 99990, now 20 -> (99999-99990)+20 = 29.
      final result = unitsConsumed(20, 99990, rolloverMax: 99999);
      expect(result.outcome, ConsumptionOutcome.rollover);
      expect(result.units, 29);
    });

    test('treats rolloverMax below previous as an anomaly (bad config)', () {
      final result = unitsConsumed(20, 12500, rolloverMax: 9999);
      expect(result.outcome, ConsumptionOutcome.anomaly);
      expect(result.units, isNull);
    });
  });

  group('averagePerDay', () {
    test('divides units by days', () {
      expect(averagePerDay(60, 5), 12);
    });

    test('returns null on a zero-day span (same-day readings)', () {
      expect(averagePerDay(18, 0), isNull);
    });

    test('returns null on a negative span', () {
      expect(averagePerDay(18, -3), isNull);
    });

    test('handles a single-day gap', () {
      expect(averagePerDay(18, 1), 18);
    });
  });

  group('averagePerWeek', () {
    test('multiplies the daily average by 7', () {
      expect(averagePerWeek(3), 21);
    });

    test('passes null through', () {
      expect(averagePerWeek(null), isNull);
    });
  });

  group('projectedUnits', () {
    test('projects partway through a window', () {
      // 40 so far + 4/day * 15 days left = 100.
      expect(
        projectedUnits(unitsSoFar: 40, perDay: 4, remainingDays: 15),
        100,
      );
    });

    test('returns unitsSoFar unchanged when no days remain', () {
      expect(
        projectedUnits(unitsSoFar: 120, perDay: 4, remainingDays: 0),
        120,
      );
    });

    test('returns null when the daily average is unknown', () {
      expect(
        projectedUnits(unitsSoFar: 40, perDay: null, remainingDays: 15),
        isNull,
      );
    });

    test('month-end and bill-cycle projections diverge with different windows',
        () {
      const soFar = 100.0;
      const perDay = 5.0;
      final monthEnd =
          projectedUnits(unitsSoFar: soFar, perDay: perDay, remainingDays: 6);
      final billCycle =
          projectedUnits(unitsSoFar: soFar, perDay: perDay, remainingDays: 12);
      expect(monthEnd, 130); // 100 + 5*6
      expect(billCycle, 160); // 100 + 5*12
      expect(monthEnd, isNot(billCycle));
    });
  });

  group('highestReading / lowestReading', () {
    test('finds the max and min of a list', () {
      final values = [12500.0, 12518.0, 12546.0, 12570.0];
      expect(highestReading(values), 12570);
      expect(lowestReading(values), 12500);
    });

    test('handles a single-element list', () {
      expect(highestReading([42]), 42);
      expect(lowestReading([42]), 42);
    });

    test('returns null on an empty list (no exception)', () {
      expect(highestReading([]), isNull);
      expect(lowestReading([]), isNull);
    });
  });

  group('averageMonthlyConsumption / averageYearlyConsumption', () {
    test('averages equal-length full cycles', () {
      final cycles = [
        const CycleConsumption(totalUnits: 300, days: 30),
        const CycleConsumption(totalUnits: 330, days: 30),
      ];
      // daily rates 10 and 11 -> mean 10.5 -> *30 = 315, *365 = 3832.5
      expect(averageMonthlyConsumption(cycles), 315);
      expect(averageYearlyConsumption(cycles), 3832.5);
    });

    test('normalises an irregular/short cycle by its daily rate', () {
      final cycles = [
        const CycleConsumption(totalUnits: 300, days: 30), // 10/day
        const CycleConsumption(totalUnits: 150, days: 10), // 15/day
      ];
      // mean daily rate = 12.5 -> monthly 375
      expect(averageMonthlyConsumption(cycles), 375);
    });

    test('ignores cycles with a non-positive span', () {
      final cycles = [
        const CycleConsumption(totalUnits: 300, days: 30), // 10/day
        const CycleConsumption(totalUnits: 5, days: 0), // ignored
      ];
      expect(averageMonthlyConsumption(cycles), 300);
    });

    test('returns null when there are no usable cycles', () {
      expect(averageMonthlyConsumption([]), isNull);
      expect(averageYearlyConsumption([]), isNull);
      expect(
        averageMonthlyConsumption(
          [const CycleConsumption(totalUnits: 5, days: 0)],
        ),
        isNull,
      );
    });
  });

  group('compareCycles', () {
    test('reports a positive percent delta on an increase', () {
      final comparison = compareCycles(145, 100);
      expect(comparison, isNotNull);
      expect(comparison!.absoluteDelta, 45);
      expect(comparison.percentDelta, 45);
      expect(comparison.isIncrease, isTrue);
    });

    test('reports a negative delta on a decrease', () {
      final comparison = compareCycles(80, 100);
      expect(comparison!.absoluteDelta, -20);
      expect(comparison.percentDelta, -20);
      expect(comparison.isIncrease, isFalse);
    });

    test('returns null when the previous cycle is missing', () {
      expect(compareCycles(120, null), isNull);
    });

    test('returns null when the previous cycle was zero (no divide-by-zero)',
        () {
      expect(compareCycles(120, 0), isNull);
    });
  });
}
