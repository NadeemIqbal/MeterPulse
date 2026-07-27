import 'package:flutter_test/flutter_test.dart';
import 'package:meter_pulse/core/utils/number_parsing_utils.dart';

void main() {
  group('extractMeterReadingFromLines', () {
    test('ignores 10-digit serial numbers and picks 5-digit meter reading', () {
      final lines = [
        const OcrLineContext(lineText: 'MODEL EM115'),
        const OcrLineContext(lineText: 'SN 2024849102'),
        const OcrLineContext(lineText: '01428 kWh'),
      ];

      final result = extractMeterReadingFromLines(
        lines,
        unit: 'kWh',
        previousReadingValue: 1400.0,
      );

      expect(result.hasValue, true);
      expect(result.value, 1428.0);
    });

    test('ignores electrical specifications like 230V 50Hz 1000imp/kWh', () {
      final lines = [
        const OcrLineContext(lineText: '230V 50Hz 1000imp/kWh'),
        const OcrLineContext(lineText: '05432.5'),
      ];

      final result = extractMeterReadingFromLines(
        lines,
        unit: 'kWh',
        previousReadingValue: 5400.0,
      );

      expect(result.hasValue, true);
      expect(result.value, 5432.5);
    });

    test('filters candidate matching meter serial number', () {
      final lines = [
        const OcrLineContext(lineText: 'Meter No 98765432'),
        const OcrLineContext(lineText: '03210'),
      ];

      final result = extractMeterReadingFromLines(
        lines,
        meterNumber: '98765432',
        previousReadingValue: 3180.0,
      );

      expect(result.hasValue, true);
      expect(result.value, 3210.0);
    });

    test('boosts candidate close to previousReadingValue', () {
      final lines = [
        const OcrLineContext(lineText: '1285.4'),
        const OcrLineContext(lineText: '9999999'),
      ];

      final result = extractMeterReadingFromLines(
        lines,
        previousReadingValue: 1250.0,
      );

      expect(result.hasValue, true);
      expect(result.value, 1285.4);
    });

    test('returns alternative candidate values', () {
      final lines = [
        const OcrLineContext(lineText: '05432.5 kWh'),
        const OcrLineContext(lineText: '05432'),
      ];

      final result = extractMeterReadingFromLines(
        lines,
        unit: 'kWh',
      );

      expect(result.hasValue, true);
      expect(result.value, 5432.5);
      expect(result.alternativeValues.contains(5432.0), true);
    });

    test('does not pick nameplate constants off a real K-Electric faceplate', () {
      // Exactly what ML Kit returned from an uncropped capture on the device.
      // "3200" (the imp/kWh constant) was chosen as the reading, with 240 (volts),
      // 50 (Hz) and 62053 (the IEC standard number) among the alternatives.
      const raw = 'Made In Pakistan\n2017\n'
          'Earth Neutral 3200impkWh Reverse Poww Tote\n'
          'Static 1 Phase 2 Wire 240V 10(40)A 50Hz\n'
          'Type: HXE 12 Class 1.0 IEC 62053-21\n'
          'No.\nKBK\nDISPLA YS\nMeer Sen\n'
          'KBK BLECTRONICS (PVT) LIMITED\nsM';

      final result = extractLongestNumericSequence(
        raw,
        unit: 'kWh',
        previousReadingValue: 20981,
        expectedDigits: 5,
      );

      // This text contains no valid reading at all, so there is no "right" value
      // to return — the only correct behaviour is to report near-zero confidence
      // so the UI treats it as a failed scan rather than a reading. Asserting a
      // specific value here would be meaningless.
      expect(
        result.confidence,
        lessThan(0.2),
        reason: 'nothing here is plausible against a running total of 20981, '
            'so the scan must not look confident',
      );
    });

    test('prefers a plausible reading over nameplate noise', () {
      const raw = 'Static 1 Phase 2 Wire 240V 10(40)A 50Hz\n'
          '3200impkWh\n'
          '21004\n'
          'IEC 62053-21';

      final result = extractLongestNumericSequence(
        raw,
        unit: 'kWh',
        previousReadingValue: 20981,
        expectedDigits: 5,
      );

      // 21004 moves forward from 20981 by a believable 23 units.
      expect(result.value, 21004);
    });
  });
}
