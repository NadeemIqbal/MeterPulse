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
  });
}
