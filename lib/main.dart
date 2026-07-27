import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';

import 'app/app.dart';
import 'app/router/app_router.dart';
import 'core/database/bill_reading_repair.dart';
import 'core/database/isar_service.dart';
import 'core/di/service_locator.dart';
import 'core/services/notification_service.dart';
import 'features/settings/presentation/cubit/theme_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Open Isar and wire dependencies, then load the saved theme so the first
  // frame paints in the correct mode (no flash).
  await configureDependencies();

  // Reconcile bills against the readings they created, before any screen reads
  // them. Bills used to create readings without keeping a reference, so editing
  // a bill's date left the original reading behind; two rows then held the same
  // value and consumption between them came out as zero. Idempotent, so this is
  // a no-op once the data is clean.
  // Snapshot first: the repair removes abandoned rows, so it only runs when a
  // restorable copy of the original database is on disk. Fails closed. Skipped
  // entirely once the user has restored that snapshot, which would otherwise be
  // undone by this very call.
  try {
    if (!await IsarService.isRepairOptedOut() &&
        await IsarService.snapshotBeforeRepair(sl<Isar>())) {
      await sl<BillReadingRepair>().run();
    }
  } catch (_) {
    // Non-fatal — a repair failure must never stop the app from starting.
  }

  await sl<ThemeCubit>().load();

  // Set up notification channels/timezone up front (best-effort).
  try {
    await sl<NotificationService>().init();
  } catch (_) {
    // Non-fatal — the app runs fine without notifications.
  }

  runApp(MeterPulseApp(router: buildRouter()));
}
