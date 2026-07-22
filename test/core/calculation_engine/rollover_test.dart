import 'package:flutter_test/flutter_test.dart';
import 'package:meter_pulse/core/calculation_engine/consumption_calculator.dart';

/// Focused coverage of the meter-rollover vs. data-entry-error distinction —
/// the case where the engine must never silently guess a consumption value.
void main() {
  group('meter rollover', () {
    test('computes wrapped units when the meter passes its configured max', () {
      // 4-digit meter wrapping at 9999: 9980 -> 15 == 19 + 15 = 34 units.
      final result = unitsConsumed(15, 9980, rolloverMax: 9999);
      expect(result.outcome, ConsumptionOutcome.rollover);
      expect(result.units, 34);
    });

    test('wraps exactly to the max boundary', () {
      // rolloverMax == previous: wrapped == current.
      final result = unitsConsumed(12, 500, rolloverMax: 500);
      expect(result.outcome, ConsumptionOutcome.rollover);
      expect(result.units, 12);
    });

    test('does not trigger rollover when current >= previous', () {
      final result = unitsConsumed(9990, 9980, rolloverMax: 9999);
      expect(result.outcome, ConsumptionOutcome.normal);
      expect(result.units, 10);
    });
  });

  group('data-entry anomaly', () {
    test('flags an anomaly when current < previous and no max is configured',
        () {
      final result = unitsConsumed(15, 9980);
      expect(result.outcome, ConsumptionOutcome.anomaly);
      expect(result.units, isNull);
      expect(result.isAnomaly, isTrue);
    });

    test('flags an anomaly when the configured max is below the previous value',
        () {
      // Nonsensical config (max < previous) must not be treated as a rollover.
      final result = unitsConsumed(15, 9980, rolloverMax: 5000);
      expect(result.outcome, ConsumptionOutcome.anomaly);
      expect(result.units, isNull);
    });
  });
}
