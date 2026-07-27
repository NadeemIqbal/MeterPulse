import 'package:flutter_test/flutter_test.dart';
import 'package:meter_pulse/features/settings/domain/entities/app_settings.dart';

void main() {
  group('AppSettings notification migration', () {
    test('an existing install with reminders on keeps both kinds on', () {
      // Rows written before the split have only `notificationsEnabled`.
      const settings = AppSettings(notificationsEnabled: true);

      expect(settings.readingRemindersOn, isTrue);
      expect(settings.billAlertsOn, isTrue);
      expect(settings.anyNotificationsOn, isTrue);
    });

    test('an existing install with reminders off keeps both kinds off', () {
      const settings = AppSettings(notificationsEnabled: false);

      expect(settings.readingRemindersOn, isFalse);
      expect(settings.billAlertsOn, isFalse);
      expect(settings.anyNotificationsOn, isFalse);
    });

    test('a fresh install defaults to off', () {
      const settings = AppSettings();

      expect(settings.readingRemindersOn, isFalse);
      expect(settings.billAlertsOn, isFalse);
    });

    test('an explicit split flag overrides the legacy value', () {
      const settings = AppSettings(
        notificationsEnabled: true,
        billAlertsEnabled: false,
      );

      expect(settings.readingRemindersOn, isTrue); // still falls back
      expect(settings.billAlertsOn, isFalse); // explicitly turned off
      expect(settings.anyNotificationsOn, isTrue);
    });

    test('both kinds can be independently off', () {
      const settings = AppSettings(
        notificationsEnabled: true,
        readingRemindersEnabled: false,
        billAlertsEnabled: false,
      );

      expect(settings.anyNotificationsOn, isFalse);
    });

    test('copyWith preserves the legacy flag it is not given', () {
      const original = AppSettings(notificationsEnabled: true);
      final updated = original.copyWith(readingRemindersEnabled: false);

      expect(updated.notificationsEnabled, isTrue);
      expect(updated.readingRemindersOn, isFalse);
      expect(updated.billAlertsOn, isTrue);
    });
  });
}
