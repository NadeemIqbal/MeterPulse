import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/notification_service.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

/// Manages the notification-related settings (theme is handled separately by
/// ThemeCubit). Both read/write the same [AppSettings] row.
class SettingsCubit extends Cubit<AppSettings> {
  SettingsCubit(this._repo, this._notifications)
      : super(const AppSettings());

  final SettingsRepository _repo;
  final NotificationService _notifications;

  Future<void> load() async {
    emit(await _repo.getSettings());
  }

  Future<void> setReadingRemindersEnabled(bool enabled) => _setNotificationFlag(
        state.copyWith(
          readingRemindersEnabled: enabled,
          notificationsEnabled: enabled || state.billAlertsOn,
        ),
      );

  Future<void> setBillAlertsEnabled(bool enabled) => _setNotificationFlag(
        state.copyWith(
          billAlertsEnabled: enabled,
          notificationsEnabled: enabled || state.readingRemindersOn,
        ),
      );

  /// Requests permission when the first reminder kind is switched on, and
  /// clears any scheduled notifications once both are off.
  Future<void> _setNotificationFlag(AppSettings updated) async {
    if (updated.anyNotificationsOn) {
      await _notifications.init();
      await _notifications.requestPermission();
    } else {
      await _notifications.cancelAll();
    }
    emit(updated);
    await _repo.saveSettings(updated);
  }

  Future<void> setReminderTime(int minutesFromMidnight) async {
    final updated = state.copyWith(reminderTimeMinutes: minutesFromMidnight);
    emit(updated);
    await _repo.saveSettings(updated);
  }

  Future<void> setCurrencySymbol(String symbol) async {
    final updated = state.copyWith(currencySymbol: symbol.trim());
    emit(updated);
    await _repo.saveSettings(updated);
  }

  /// Fires a test notification so the user can confirm delivery.
  Future<void> sendTest() => _notifications.showTest();
}

