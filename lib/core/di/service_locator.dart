import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isar_community/isar.dart';

import '../../features/bills/data/repositories/bill_repository_impl.dart';
import '../../features/bills/domain/repositories/bill_repository.dart';
import '../../features/bills/presentation/cubit/bill_cubit.dart';
import '../../features/bills/presentation/cubit/bill_form_cubit.dart';
import '../../features/backup/data/backup_service.dart';
import '../../features/billing_cycles/data/repositories/billing_cycle_repository_impl.dart';
import '../../features/billing_cycles/domain/repositories/billing_cycle_repository.dart';
import '../../features/export/data/export_service.dart';
import '../../features/dashboard/domain/usecases/compute_meter_summary.dart';
import '../../features/dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../features/meters/data/repositories/meter_repository_impl.dart';
import '../../features/meters/domain/repositories/meter_repository.dart';
import '../../features/meters/presentation/cubit/meter_form_cubit.dart';
import '../../features/meters/presentation/cubit/meter_list_cubit.dart';
import '../../features/readings/data/datasources/ocr_datasource.dart';
import '../../features/readings/data/repositories/reading_repository_impl.dart';
import '../../features/readings/domain/repositories/reading_repository.dart';
import '../../features/readings/domain/usecases/add_reading.dart';
import '../../features/readings/presentation/cubit/reading_capture_cubit.dart';
import '../../features/readings/presentation/cubit/reading_history_cubit.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/presentation/cubit/settings_cubit.dart';
import '../../features/settings/presentation/cubit/theme_cubit.dart';
import '../database/isar_service.dart';
import '../services/file_storage_service.dart';
import '../services/image_capture_service.dart';
import '../services/notification_service.dart';
import '../services/permission_service.dart';

/// Global service locator. Registration order is:
///   1. Isar + stateless services  → singletons
///   2. Repositories + use cases    → lazy singletons (stateless)
///   3. Cubits                      → factories (fresh per screen)
/// The pure calculation engine is intentionally *not* registered — it is
/// imported directly wherever needed and stays free of the locator.
final GetIt sl = GetIt.instance;

/// Awaited once in `main` before `runApp`. Opens Isar and wires dependencies.
Future<void> configureDependencies() async {
  // --- Infrastructure ---
  final isar = await IsarService.open();
  sl
    ..registerSingleton<Isar>(isar)
    ..registerLazySingleton<ImagePicker>(ImagePicker.new)
    ..registerLazySingleton<PermissionService>(PermissionService.new)
    ..registerLazySingleton<FileStorageService>(FileStorageService.new)
    ..registerLazySingleton<ImageCaptureService>(
      () => ImageCaptureService(sl<ImagePicker>()),
    )
    ..registerLazySingleton<OcrDatasource>(OcrDatasource.new)
    ..registerLazySingleton<FlutterLocalNotificationsPlugin>(
      FlutterLocalNotificationsPlugin.new,
    )
    ..registerLazySingleton<NotificationService>(
      () => NotificationService(sl<FlutterLocalNotificationsPlugin>()),
    );

  // --- Repositories ---
  sl
    ..registerLazySingleton<MeterRepository>(
      () => MeterRepositoryImpl(sl<Isar>()),
    )
    ..registerLazySingleton<ReadingRepository>(
      () => ReadingRepositoryImpl(sl<Isar>()),
    )
    ..registerLazySingleton<BillRepository>(
      () => BillRepositoryImpl(sl<Isar>()),
    )
    ..registerLazySingleton<BillingCycleRepository>(
      () => BillingCycleRepositoryImpl(sl<Isar>()),
    )
    ..registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(sl<Isar>()),
    );

  // --- Use cases ---
  sl
    ..registerLazySingleton<AddReading>(
      () => AddReading(sl<ReadingRepository>(), sl<BillingCycleRepository>()),
    )
    ..registerLazySingleton<ComputeMeterSummary>(ComputeMeterSummary.new);

  // --- Export / backup services ---
  sl
    ..registerLazySingleton<ExportService>(
      () => ExportService(
        meterRepository: sl<MeterRepository>(),
        readingRepository: sl<ReadingRepository>(),
        cycleRepository: sl<BillingCycleRepository>(),
        billRepository: sl<BillRepository>(),
      ),
    )
    ..registerLazySingleton<BackupService>(() => BackupService(sl<Isar>()));

  // --- Cubits ---
  // ThemeCubit is app-global (sits above MaterialApp) → singleton.
  sl.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(sl<SettingsRepository>()),
  );
  sl.registerFactory<SettingsCubit>(
    () => SettingsCubit(sl<SettingsRepository>(), sl<NotificationService>()),
  );
  // Screen-scoped cubits → new instance each time they're requested.
  sl
    ..registerFactory<MeterListCubit>(
      () => MeterListCubit(sl<MeterRepository>()),
    )
    ..registerFactory<MeterFormCubit>(
      () => MeterFormCubit(sl<MeterRepository>()),
    )
    ..registerFactory<DashboardCubit>(
      () => DashboardCubit(
        meterRepository: sl<MeterRepository>(),
        readingRepository: sl<ReadingRepository>(),
        cycleRepository: sl<BillingCycleRepository>(),
        billRepository: sl<BillRepository>(),
        settingsRepository: sl<SettingsRepository>(),
        notificationService: sl<NotificationService>(),
        compute: sl<ComputeMeterSummary>(),
      ),
    )
    ..registerFactory<ReadingCaptureCubit>(
      () => ReadingCaptureCubit(
        permissionService: sl<PermissionService>(),
        imageCaptureService: sl<ImageCaptureService>(),
        fileStorageService: sl<FileStorageService>(),
        ocrDatasource: sl<OcrDatasource>(),
        addReading: sl<AddReading>(),
        readingRepository: sl<ReadingRepository>(),
        cycleRepository: sl<BillingCycleRepository>(),
      ),
    )
    ..registerFactory<ReadingHistoryCubit>(
      () => ReadingHistoryCubit(
        sl<ReadingRepository>(),
        sl<BillingCycleRepository>(),
      ),
    )
    ..registerFactory<BillCubit>(() => BillCubit(sl<BillRepository>()))
    ..registerFactory<BillFormCubit>(() => BillFormCubit(sl<BillRepository>()));
}
