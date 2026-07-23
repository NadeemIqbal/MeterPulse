import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Wraps `flutter_local_notifications` for reading/bill reminders and usage
/// alerts. All scheduling is inexact (reminders don't need to-the-minute
/// precision), which avoids the Android 12+ exact-alarm permission entirely.
///
/// Reminders are one-off: the app reschedules the next occurrence on every
/// launch (see the dashboard), matching the "no background jobs" design.
class NotificationService {
  NotificationService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  static const String _remindersChannelId = 'reminders';
  static const String _alertsChannelId = 'alerts';

  bool _initialised = false;

  /// Initialises timezone data and the plugin, and creates the channels.
  /// Safe to call more than once.
  Future<void> init() async {
    if (_initialised) return;

    tzdata.initializeTimeZones();
    try {
      final localName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localName.identifier));
    } catch (_) {
      // Fall back to UTC if the device timezone can't be resolved.
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      settings: const InitializationSettings(android: androidInit),
    );

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _remindersChannelId,
        'Reminders',
        description: 'Reading and bill reminders',
        importance: Importance.high,
      ),
    );
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _alertsChannelId,
        'Usage alerts',
        description: 'High-usage and abnormal-consumption alerts',
        importance: Importance.max,
      ),
    );

    _initialised = true;
  }

  /// Requests the Android 13+ notification permission. Returns true if granted
  /// (or not required on older Android).
  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    return granted ?? true;
  }

  Future<void> scheduleReadingReminder({
    required int meterId,
    required String meterName,
    required DateTime when,
  }) =>
      _scheduleAt(
        id: _readingId(meterId),
        channelId: _remindersChannelId,
        channelName: 'Reminders',
        title: 'Reading due — $meterName',
        body: 'Time to take a reading for $meterName.',
        when: when,
      );

  Future<void> scheduleBillReminder({
    required int meterId,
    required String meterName,
    required DateTime when,
  }) =>
      _scheduleAt(
        id: _billId(meterId),
        channelId: _remindersChannelId,
        channelName: 'Reminders',
        title: 'Bill due — $meterName',
        body: 'A bill for $meterName is due.',
        when: when,
      );

  /// Fires an immediate high-priority usage alert.
  Future<void> showUsageAlert({
    required int meterId,
    required String meterName,
    required String title,
    required String message,
  }) async {
    await init();
    await _plugin.show(
      id: _alertId(meterId),
      title: '$title — $meterName',
      body: message,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _alertsChannelId,
          'Usage alerts',
          channelDescription: 'High-usage and abnormal-consumption alerts',
          importance: Importance.max,
          priority: Priority.max,
        ),
      ),
    );
  }

  /// Fires a test notification so the user can confirm delivery.
  Future<void> showTest() async {
    await init();
    await _plugin.show(
      id: 1,
      title: 'MeterPulse notifications are on',
      body: 'This is a test reminder. You\'ll be nudged when readings and bills '
          'are due.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _remindersChannelId,
          'Reminders',
          channelDescription: 'Reading and bill reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> cancelForMeter(int meterId) async {
    await _plugin.cancel(id: _readingId(meterId));
    await _plugin.cancel(id: _billId(meterId));
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  Future<void> _scheduleAt({
    required int id,
    required String channelId,
    required String channelName,
    required String title,
    required String body,
    required DateTime when,
  }) async {
    await init();
    // Never schedule in the past.
    if (!when.isAfter(DateTime.now())) {
      await _plugin.cancel(id: id);
      return;
    }
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(when, tz.local),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  // Deterministic ids so a meter's notifications can be replaced/cancelled.
  int _readingId(int meterId) => meterId * 10 + 1;
  int _billId(int meterId) => meterId * 10 + 2;
  int _alertId(int meterId) => meterId * 10 + 3;
}
