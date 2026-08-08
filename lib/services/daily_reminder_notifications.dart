import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../data/models/daily_reminder.dart';
import 'daily_log_notification_navigation.dart';

/// Schedules / cancels the daily log reminder via local notifications.
///
/// Safe to call from tests and web: unsupported platforms no-op.
class DailyReminderNotifications {
  DailyReminderNotifications._();

  static const notificationId = 1001;
  static const payloadDailyLog = 'daily_log';

  static const _channelId = 'daily_reminder';
  static const _channelName = 'Daily reminder';
  static const _channelDescription =
      'Gentle nudge to log how you’re feeling each day';
  static const _title = 'Ritu';

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static var _initialized = false;
  static var _timezoneReady = false;

  static bool get _supported {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  /// Initializes the plugin and local timezone. Idempotent.
  ///
  /// Returns `false` if the native plugin is not ready yet (common on iOS
  /// during early startup with UIScene). Callers may retry later.
  static Future<bool> initialize() async {
    if (!_supported) return false;
    if (_initialized) return true;

    await _ensureTimezone();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(android: android, iOS: ios),
        onDidReceiveNotificationResponse: _onNotificationResponse,
      );
      _initialized = true;
      return true;
    } on MissingPluginException {
      // Plugin registrant not hooked up yet — retry on the next call.
      return false;
    }
  }

  static void _onNotificationResponse(NotificationResponse response) {
    if (_isDailyLogResponse(response.id, response.payload)) {
      DailyLogNotificationNavigation.requestOpen();
    }
  }

  static bool _isDailyLogResponse(int? id, String? payload) {
    return id == notificationId || payload == payloadDailyLog;
  }

  static Future<void> _ensureTimezone() async {
    if (_timezoneReady) return;
    tz_data.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // Keep package default (UTC) rather than failing.
    }
    _timezoneReady = true;
  }

  /// Asks the OS for notification permission. Returns whether it was granted.
  static Future<bool> requestPermission() async {
    if (!_supported) return false;
    if (!await initialize()) return false;

    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.requestNotificationsPermission();
      return granted ?? false;
    }

    if (Platform.isIOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final granted = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return false;
  }

  /// Schedules or cancels based on [reminder.enabled].
  static Future<void> apply(DailyReminder reminder) async {
    if (!_supported) return;
    if (!await initialize()) return;
    if (reminder.enabled) {
      await schedule(reminder);
    } else {
      await cancel();
    }
  }

  /// Re-reads SharedPreferences and applies the saved preference.
  ///
  /// Call after the first frame on cold start so a previously opted-in
  /// reminder stays scheduled (Android also reschedules via boot receiver).
  static Future<void> syncFromPrefs() async {
    if (!_supported) return;
    final prefs = await SharedPreferences.getInstance();
    final reminder = DailyReminder(
      enabled: prefs.getBool(DailyReminder.prefsEnabledKey) ?? false,
      hour: prefs.getInt(DailyReminder.prefsHourKey) ??
          DailyReminder.defaults.hour,
      minute: prefs.getInt(DailyReminder.prefsMinuteKey) ??
          DailyReminder.defaults.minute,
    );
    await apply(reminder);
    await _handleLaunchFromNotification();
  }

  /// If the app was opened by tapping the daily reminder, open Log today.
  static Future<void> _handleLaunchFromNotification() async {
    if (!await initialize()) return;
    try {
      final details = await _plugin.getNotificationAppLaunchDetails();
      if (details?.didNotificationLaunchApp != true) return;
      final response = details!.notificationResponse;
      if (_isDailyLogResponse(response?.id, response?.payload)) {
        DailyLogNotificationNavigation.requestOpen();
      }
    } on MissingPluginException {
      // Ignore.
    }
  }

  static Future<void> schedule(DailyReminder reminder) async {
    if (!_supported) return;
    if (!await initialize()) return;

    try {
      await _plugin.zonedSchedule(
        id: notificationId,
        title: _title,
        body: DailyReminder.sampleMessage,
        scheduledDate: _nextInstance(reminder.hour, reminder.minute),
        payload: payloadDailyLog,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } on MissingPluginException {
      // Ignore — will retry on next enable/time change or app launch.
    }
  }

  static Future<void> cancel() async {
    if (!_supported) return;
    if (!await initialize()) return;
    try {
      await _plugin.cancel(id: notificationId);
    } on MissingPluginException {
      // Ignore.
    }
  }

  static tz.TZDateTime _nextInstance(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
