import 'package:flutter_test/flutter_test.dart';
import 'package:meter_pulse/core/utils/meter_display_mode.dart';

void main() {
  group('assessReading', () {
    test('accepts normal forward movement', () {
      final result = assessReading(
        20981,
        previousValue: 20970,
        daysElapsed: 2,
        expectedMonthlyUnits: 170,
      );

      expect(result.mode, MeterDisplayMode.energyTotal);
      expect(result.plausibility, ReadingPlausibility.plausible);
      expect(result.isClean, isTrue);
      expect(result.message, isNull);
    });

    test('flags an instantaneous kW value captured instead of the total', () {
      // The display cycles to "Instantaneous KW" and shows something like 2.4
      // where a five-digit total belongs. Recognition is perfect; the mode is
      // wrong.
      final result = assessReading(
        2.4,
        previousValue: 20970,
        daysElapsed: 1,
      );

      expect(result.mode, MeterDisplayMode.demandOrPower);
      expect(result.plausibility, ReadingPlausibility.wrongMode);
      expect(result.isClean, isFalse);
      expect(result.message, contains('demand or instantaneous'));
    });

    test('flags a maximum-demand register value', () {
      final result = assessReading(
        229.2,
        previousValue: 20970,
        daysElapsed: 3,
      );

      expect(result.mode, MeterDisplayMode.demandOrPower);
      expect(result.plausibility, ReadingPlausibility.wrongMode);
    });

    test('recognises the serial number being displayed', () {
      final result = assessReading(
        7500046444,
        previousValue: 20970,
        meterNumber: '7500046444',
      );

      expect(result.mode, MeterDisplayMode.serialNumber);
      expect(result.plausibility, ReadingPlausibility.wrongMode);
      expect(result.message, contains('serial number'));
    });

    test('a small step backwards reads as a misread, not a mode error', () {
      // 20,969 against 20,970 is a digit problem: far too close to the previous
      // total to be a demand value.
      final result = assessReading(
        20969,
        previousValue: 20970,
        daysElapsed: 1,
      );

      expect(result.mode, MeterDisplayMode.energyTotal);
      expect(result.plausibility, ReadingPlausibility.wentBackwards);
      expect(result.message, contains('cannot go down'));
    });

    test('flags an extra digit as an implausible jump', () {
      // 209,810 instead of 20,981 — one misread digit, ten times the usage.
      final result = assessReading(
        209810,
        previousValue: 20970,
        daysElapsed: 2,
        expectedMonthlyUnits: 170,
      );

      expect(result.plausibility, ReadingPlausibility.implausibleJump);
      expect(result.isClean, isFalse);
    });

    test('allows heavy use when it stays within the meter\'s own scale', () {
      // 170/month is ~5.7/day; 60 units over 2 days is heavy but under the
      // ten-times-daily ceiling, so it must not be blocked.
      final result = assessReading(
        21030,
        previousValue: 20970,
        daysElapsed: 2,
        expectedMonthlyUnits: 170,
      );

      expect(result.plausibility, ReadingPlausibility.plausible);
    });

    test('is unverified with no previous reading rather than guessing', () {
      final result = assessReading(20981);

      expect(result.plausibility, ReadingPlausibility.unverified);
      // Nothing to contradict, so it must not obstruct the first-ever reading.
      expect(result.isClean, isTrue);
    });

    test('treats a zero-day gap as one day instead of dividing by zero', () {
      final result = assessReading(
        20975,
        previousValue: 20970,
        daysElapsed: 0,
        expectedMonthlyUnits: 170,
      );

      expect(result.plausibility, ReadingPlausibility.plausible);
    });
  });
}
