import 'package:intl/intl.dart';

/// App-wide display formatting. Centralised so numbers and dates read the same
/// on every screen.
abstract final class Formatters {
  static final NumberFormat _units = NumberFormat('#,##0.##');
  static final NumberFormat _whole = NumberFormat('#,##0');
  static final DateFormat _date = DateFormat('d MMM yyyy');
  static final DateFormat _shortDate = DateFormat('d MMM');

  /// A units value, or an em dash when null/unknown.
  static String units(double? value) => value == null ? '—' : _units.format(value);

  /// A raw meter reading (thousands separators, no forced decimals).
  static String reading(double value) => _units.format(value);

  /// A whole-number count.
  static String whole(num value) => _whole.format(value);

  /// A signed delta like "+18" / "−4".
  static String signedUnits(double value) {
    final formatted = _units.format(value.abs());
    if (value > 0) return '+$formatted';
    if (value < 0) return '−$formatted';
    return formatted;
  }

  static String date(DateTime? value) => value == null ? '—' : _date.format(value);

  static String shortDate(DateTime value) => _shortDate.format(value);

  /// A currency amount using the device locale's symbol.
  static String currency(double value) =>
      NumberFormat.simpleCurrency().format(value);

  /// "in 3 days" / "today" / "5 days ago" from a signed day count.
  static String relativeDays(int days) {
    if (days == 0) return 'today';
    if (days == 1) return 'tomorrow';
    if (days == -1) return 'yesterday';
    if (days > 0) return 'in $days days';
    return '${days.abs()} days ago';
  }
}
