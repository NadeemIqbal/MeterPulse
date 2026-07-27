/// Central route paths and builders for parameterised locations.
abstract final class RouteNames {
  static const String dashboard = '/';
  static const String meters = '/meters';
  static const String newMeter = '/meters/new';
  static const String settings = '/settings';
  static const String about = '/settings/about';

  /// Portfolio-wide tabs (all meters), as opposed to the `/meters/:id/…` views.
  static const String allBills = '/bills';
  static const String allStats = '/stats';

  static String meterDetail(int id) => '/meters/$id';
  static String editMeter(int id) => '/meters/$id/edit';
  static String takeReading(int id) => '/meters/$id/reading';
  static String history(int id) => '/meters/$id/history';
  static String stats(int id) => '/meters/$id/stats';
  static String bills(int id) => '/meters/$id/bills';
  static String newBill(int id) => '/meters/$id/bill';
}
