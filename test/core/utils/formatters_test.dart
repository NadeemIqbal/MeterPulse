import 'package:flutter_test/flutter_test.dart';
import 'package:meter_pulse/core/utils/formatters.dart';

void main() {
  group('Formatters', () {
    test('units formats double and handles null', () {
      expect(Formatters.units(1234.56), '1,234.56');
      expect(Formatters.units(null), '—');
    });

    test('reading formats raw double values', () {
      expect(Formatters.reading(5432.1), '5,432.1');
    });

    test('whole formats integer numbers', () {
      expect(Formatters.whole(42), '42');
      expect(Formatters.whole(1000), '1,000');
    });

    test('signedUnits adds + or - sign correctly', () {
      expect(Formatters.signedUnits(15.5), '+15.5');
      expect(Formatters.signedUnits(-8.0), '−8');
      expect(Formatters.signedUnits(0.0), '0');
    });

    test('date and shortDate format DateTime correctly', () {
      final dt = DateTime(2026, 7, 25);
      expect(Formatters.date(dt), '25 Jul 2026');
      expect(Formatters.date(null), '—');
      expect(Formatters.shortDate(dt), '25 Jul');
    });

    test('monthYear formats MMMM yyyy', () {
      final dt = DateTime(2026, 7, 15);
      expect(Formatters.monthYear(dt), 'July 2026');
    });

    test('currency formats with default PKR and custom symbol', () {
      expect(Formatters.currency(1500.0), 'PKR 1,500.00');
      expect(Formatters.currency(25.5, symbol: '\$'), '\$25.50');
    });

    test('relativeDays returns natural language descriptions', () {

      expect(Formatters.relativeDays(0), 'today');
      expect(Formatters.relativeDays(1), 'tomorrow');
      expect(Formatters.relativeDays(-1), 'yesterday');
      expect(Formatters.relativeDays(5), 'in 5 days');
      expect(Formatters.relativeDays(-3), '3 days ago');
    });
  });
}
