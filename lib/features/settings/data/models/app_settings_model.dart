import 'package:isar_community/isar.dart';

import '../../domain/entities/app_theme_mode.dart';

part 'app_settings_model.g.dart';

/// Single-row Isar collection holding app-wide preferences. The repository
/// always reads/writes the first (and only) row.
@collection
class AppSettingsModel {
  Id id = Isar.autoIncrement;

  @Enumerated(EnumType.name)
  AppThemeMode themeMode = AppThemeMode.system;

  String? currencySymbol;

  // --- Phase 2 preferences (nullable, unused in Phase 1) ---
  /// Legacy combined switch. Left in place as the migration fallback for the
  /// two split flags below — never remove it without a data migration.
  bool? notificationsEnabled;

  /// Null means "never set"; the entity then falls back to
  /// [notificationsEnabled] so existing installs keep their choice.
  bool? readingRemindersEnabled;
  bool? billAlertsEnabled;

  /// Reminder time as minutes from midnight (e.g. 8am == 480).
  int? reminderTimeMinutes;

  String? notificationSound;
}

