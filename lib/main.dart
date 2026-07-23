import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/router/app_router.dart';
import 'core/di/service_locator.dart';
import 'core/services/notification_service.dart';
import 'features/settings/presentation/cubit/theme_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Open Isar and wire dependencies, then load the saved theme so the first
  // frame paints in the correct mode (no flash).
  await configureDependencies();
  await sl<ThemeCubit>().load();

  // Set up notification channels/timezone up front (best-effort).
  try {
    await sl<NotificationService>().init();
  } catch (_) {
    // Non-fatal — the app runs fine without notifications.
  }

  runApp(MeterPulseApp(router: buildRouter()));
}
