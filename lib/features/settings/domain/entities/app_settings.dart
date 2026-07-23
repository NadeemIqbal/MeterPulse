import 'package:equatable/equatable.dart';

import 'app_theme_mode.dart';

/// App-wide preferences (single instance).
class AppSettings extends Equatable {
  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.notificationsEnabled,
    this.reminderTimeMinutes,
    this.notificationSound,
  });

  final AppThemeMode themeMode;

  // Phase 2 preferences.
  final bool? notificationsEnabled;
  final int? reminderTimeMinutes;
  final String? notificationSound;

  AppSettings copyWith({
    AppThemeMode? themeMode,
    bool? notificationsEnabled,
    int? reminderTimeMinutes,
    String? notificationSound,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      reminderTimeMinutes: reminderTimeMinutes ?? this.reminderTimeMinutes,
      notificationSound: notificationSound ?? this.notificationSound,
    );
  }

  @override
  List<Object?> get props => [
        themeMode,
        notificationsEnabled,
        reminderTimeMinutes,
        notificationSound,
      ];
}
