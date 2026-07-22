import '../entities/app_settings.dart';

/// Persistence contract for the single [AppSettings] row.
abstract interface class SettingsRepository {
  /// Returns the stored settings, or defaults if none have been saved yet.
  Future<AppSettings> getSettings();

  Future<void> saveSettings(AppSettings settings);
}
