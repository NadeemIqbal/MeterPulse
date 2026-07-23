import 'dart:io';

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

  /// Filename a staged restore is written to (see BackupService). Applied here
  /// at startup before the database is opened.
  static const String pendingRestoreName = 'restore_pending.isar';

  /// Opens (or reuses) the Isar instance in the app documents directory,
  /// applying any staged restore first.
  static Future<Isar> open() async {
    final existing = Isar.getInstance();
    if (existing != null) return existing;

    final dir = await getApplicationDocumentsDirectory();
    await _applyPendingRestore(dir.path);
    return Isar.open(schemas, directory: dir.path);
  }

  /// If a restore was staged, swap it into place before opening. Done at
  /// startup so the live database is never replaced mid-session.
  static Future<void> _applyPendingRestore(String dirPath) async {
    final staged = File('$dirPath/$pendingRestoreName');
    if (!await staged.exists()) return;

    final target = File('$dirPath/default.isar');
    final lock = File('$dirPath/default.isar.lock');
    try {
      if (await target.exists()) await target.delete();
      if (await lock.exists()) await lock.delete();
      await staged.copy(target.path);
    } finally {
      if (await staged.exists()) await staged.delete();
    }
  }
}
