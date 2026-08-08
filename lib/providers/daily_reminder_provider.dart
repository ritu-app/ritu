import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/daily_reminder.dart';
import '../services/daily_reminder_notifications.dart';

final dailyReminderProvider =
    AsyncNotifierProvider<DailyReminderNotifier, DailyReminder>(
  DailyReminderNotifier.new,
);

class DailyReminderNotifier extends AsyncNotifier<DailyReminder> {
  @override
  Future<DailyReminder> build() async {
    final prefs = await SharedPreferences.getInstance();
    return DailyReminder(
      enabled: prefs.getBool(DailyReminder.prefsEnabledKey) ??
          DailyReminder.defaults.enabled,
      hour: prefs.getInt(DailyReminder.prefsHourKey) ??
          DailyReminder.defaults.hour,
      minute: prefs.getInt(DailyReminder.prefsMinuteKey) ??
          DailyReminder.defaults.minute,
    );
  }

  Future<void> setEnabled(bool enabled) async {
    final current = state.valueOrNull ?? DailyReminder.defaults;
    final next = current.copyWith(enabled: enabled);
    state = AsyncData(next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(DailyReminder.prefsEnabledKey, enabled);
    await DailyReminderNotifications.apply(next);
  }

  /// Turns the reminder on after a successful permission grant (onboarding).
  Future<void> enableFromOnboarding() async {
    final current = state.valueOrNull ?? DailyReminder.defaults;
    final next = current.copyWith(enabled: true);
    state = AsyncData(next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(DailyReminder.prefsEnabledKey, true);
    await prefs.setInt(DailyReminder.prefsHourKey, next.hour);
    await prefs.setInt(DailyReminder.prefsMinuteKey, next.minute);
    await DailyReminderNotifications.apply(next);
  }

  Future<void> setTime({required int hour, required int minute}) async {
    final current = state.valueOrNull ?? DailyReminder.defaults;
    final next = current.copyWith(hour: hour, minute: minute);
    state = AsyncData(next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(DailyReminder.prefsHourKey, hour);
    await prefs.setInt(DailyReminder.prefsMinuteKey, minute);
    await DailyReminderNotifications.apply(next);
  }

  /// Clears persisted prefs and cancels any scheduled notification.
  static Future<void> clearPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(DailyReminder.prefsEnabledKey);
    await prefs.remove(DailyReminder.prefsHourKey);
    await prefs.remove(DailyReminder.prefsMinuteKey);
    await DailyReminderNotifications.cancel();
  }
}
