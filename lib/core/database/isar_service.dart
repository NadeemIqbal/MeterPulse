import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/bills/data/models/bill_model.dart';
import '../../features/billing_cycles/data/models/billing_cycle_model.dart';
import '../../features/meters/data/models/meter_model.dart';
import '../../features/readings/data/models/reading_model.dart';
import '../../features/settings/data/models/app_settings_model.dart';

/// Owns the app's single [Isar] instance and the list of collection schemas.
///
/// [open] is awaited once during startup (before `runApp`); the resulting
/// [Isar] is registered in the service locator and injected into repositories.
class IsarService {
  const IsarService._();

  /// All collection schemas registered with Isar.
  static const List<CollectionSchema<dynamic>> schemas = [
    MeterModelSchema,
    ReadingModelSchema,
    BillModelSchema,
    BillingCycleModelSchema,
    AppSettingsModelSchema,
  ];

  /// Opens (or reuses) the Isar instance in the app documents directory.
  static Future<Isar> open() async {
    final existing = Isar.getInstance();
    if (existing != null) return existing;

    final dir = await getApplicationDocumentsDirectory();
    return Isar.open(schemas, directory: dir.path);
  }
}
