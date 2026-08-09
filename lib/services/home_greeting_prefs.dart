import 'package:shared_preferences/shared_preferences.dart';

import '../core/date_format.dart';

const _hasSeenHomeKey = 'home_has_seen';
const _lastOpenDateKey = 'home_last_open_date';

/// Session metadata read from prefs before recording today's home open.
class HomeGreetingSession {
  HomeGreetingSession._(
    this.isFirstHomeVisit,
    this.isFirstOpenToday,
    this.daysSinceLastOpen,
    this._prefs,
    this._today,
  );

  final bool isFirstHomeVisit;
  final bool isFirstOpenToday;
  final int daysSinceLastOpen;
  final SharedPreferences _prefs;
  final DateTime _today;

  static Future<HomeGreetingSession> load(DateTime today) async {
    final prefs = await SharedPreferences.getInstance();
    final day = dateOnly(today);
    final hasSeen = prefs.getBool(_hasSeenHomeKey) ?? false;
    final lastOpenRaw = prefs.getString(_lastOpenDateKey);
    final lastOpen = lastOpenRaw == null ? null : dateOnly(DateTime.parse(lastOpenRaw));

    final isFirstOpenToday = lastOpen == null || !isSameCalendarDay(lastOpen, day);
    final daysSinceLastOpen =
        lastOpen == null ? 0 : day.difference(lastOpen).inDays;

    return HomeGreetingSession._(
      !hasSeen,
      isFirstOpenToday,
      daysSinceLastOpen,
      prefs,
      day,
    );
  }

  Future<void> commit() async {
    await _prefs.setBool(_hasSeenHomeKey, true);
    await _prefs.setString(_lastOpenDateKey, _today.toIso8601String());
  }

  static Future<void> clearPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hasSeenHomeKey);
    await prefs.remove(_lastOpenDateKey);
  }
}
