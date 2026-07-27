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

  /// Filename of the one-off snapshot taken before a data repair first runs.
  static const String preRepairSnapshotName = 'pre-repair-backup.isar';

  /// Marker written when the user restores [preRepairSnapshotName].
  ///
  /// Restoring that snapshot brings back exactly the rows the repair removes, so
  /// without this the repair would re-run on the very same launch and undo the
  /// restore. Its presence means the user has deliberately opted out, and the
  /// repair stays off for good rather than reappearing on the next launch.
  static const String repairOptOutName = 'repair-opt-out';

  /// Whether the user has opted out of the automatic repair by restoring the
  /// pre-repair snapshot. Treated as opted-out on error, so an unreadable marker
  /// never results in data being removed against the user's wishes.
  static Future<bool> isRepairOptedOut() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      return File('${dir.path}/$repairOptOutName').exists();
    } catch (_) {
      return true;
    }
  }

  /// Copies the live database once, before any repair mutates it.
  ///
  /// A no-op when the snapshot already exists, so the file always holds the
  /// *original* pre-repair state rather than being overwritten on later
  /// launches. Restore it through BackupService's file picker, which stages any
  /// `.isar` file for the next launch.
  ///
  /// Returns true when a usable snapshot is in place. Callers should treat false
  /// as a reason to skip destructive work rather than proceed unprotected.
  static Future<bool> snapshotBeforeRepair(Isar isar) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$preRepairSnapshotName');
      if (await file.exists()) return true;
      await isar.copyToFile(file.path);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<Isar> open() async {
    final existing = Isar.getInstance();
    if (existing != null) return existing;

    final dir = await getApplicationDocumentsDirectory();
    await _applyPendingRestore(dir.path);

    try {
      return await Isar.open(schemas, directory: dir.path);
    } catch (_) {
      final lock = File('${dir.path}/default.isar.lock');
      if (await lock.exists()) {
        try {
          await lock.delete();
        } catch (_) {}
      }
      return await Isar.open(schemas, directory: dir.path);
    }
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
