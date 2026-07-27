import 'package:equatable/equatable.dart';

import 'app_theme_mode.dart';

/// App-wide preferences (single instance).
class AppSettings extends Equatable {
  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.currencySymbol = 'PKR',
    this.notificationsEnabled,
    this.readingRemindersEnabled,
    this.billAlertsEnabled,
    this.reminderTimeMinutes,
    this.notificationSound,
  });

  final AppThemeMode themeMode;
  final String currencySymbol;

  /// Legacy single switch that drove both reminder kinds. Kept as the fallback
  /// for the split flags below so upgrading users don't silently lose the
  /// preference they already set.
  final bool? notificationsEnabled;

  final bool? readingRemindersEnabled;
  final bool? billAlertsEnabled;

  final int? reminderTimeMinutes;
  final String? notificationSound;

  /// Whether to remind the user to take a reading.
  bool get readingRemindersOn =>
      readingRemindersEnabled ?? notificationsEnabled ?? false;

  /// Whether to warn the user before a bill falls due.
  bool get billAlertsOn => billAlertsEnabled ?? notificationsEnabled ?? false;

  /// True when either reminder kind is active — the gate for scheduling work.
  bool get anyNotificationsOn => readingRemindersOn || billAlertsOn;

  AppSettings copyWith({
    AppThemeMode? themeMode,
    String? currencySymbol,
    bool? notificationsEnabled,
    bool? readingRemindersEnabled,
    bool? billAlertsEnabled,
    int? reminderTimeMinutes,
    String? notificationSound,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      readingRemindersEnabled:
          readingRemindersEnabled ?? this.readingRemindersEnabled,
      billAlertsEnabled: billAlertsEnabled ?? this.billAlertsEnabled,
      reminderTimeMinutes: reminderTimeMinutes ?? this.reminderTimeMinutes,
      notificationSound: notificationSound ?? this.notificationSound,
    );
  }

  @override
  List<Object?> get props => [
        themeMode,
        currencySymbol,
        notificationsEnabled,
        readingRemindersEnabled,
        billAlertsEnabled,
        reminderTimeMinutes,
        notificationSound,
      ];
}

