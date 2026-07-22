import 'package:isar_community/isar.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../models/app_settings_model.dart';

/// Isar-backed [SettingsRepository]. Reads/writes the single settings row.
class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._isar);

  final Isar _isar;

  @override
  Future<AppSettings> getSettings() async {
    final model = await _isar.appSettingsModels.where().findFirst();
    if (model == null) return const AppSettings();
    return AppSettings(
      themeMode: model.themeMode,
      notificationsEnabled: model.notificationsEnabled,
      reminderTimeMinutes: model.reminderTimeMinutes,
      notificationSound: model.notificationSound,
    );
  }

  @override
  Future<void> saveSettings(AppSettings settings) {
    return _isar.writeTxn(() async {
      // Preserve the existing row id so we update in place rather than append.
      final existing = await _isar.appSettingsModels.where().findFirst();
      final model = AppSettingsModel()
        ..id = existing?.id ?? Isar.autoIncrement
        ..themeMode = settings.themeMode
        ..notificationsEnabled = settings.notificationsEnabled
        ..reminderTimeMinutes = settings.reminderTimeMinutes
        ..notificationSound = settings.notificationSound;
      await _isar.appSettingsModels.put(model);
    });
  }
}
