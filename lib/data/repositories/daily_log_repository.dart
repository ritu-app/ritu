import '../models/daily_log_entry.dart';

export '../models/daily_log_entry.dart';

/// Manages the Home "Log today" daily check-in — one row per calendar day.
abstract class DailyLogRepository {
  Future<DailyLogEntry?> getByDate(DateTime date);

  Stream<DailyLogEntry?> watchByDate(DateTime date);

  /// All daily logs, newest [loggedOn] first.
  Future<List<DailyLogEntry>> getAll();

  Future<bool> hasLoggedOn(DateTime date);

  /// Total number of calendar days with a saved daily log entry, regardless
  /// of whether they're consecutive. Used to drive the "pattern unlock"
  /// progress on Home, which counts logging days, not periods.
  Future<int> getTotalLoggedDays();

  Stream<int> watchTotalLoggedDays();

  /// Number of consecutive days (ending today, or yesterday if today hasn't
  /// been logged yet so the streak isn't broken mid-day) with a saved entry.
  Future<int> getCurrentStreak();

  Stream<int> watchCurrentStreak();

  /// Creates or updates the entry for [loggedOn] with whatever fields the
  /// flow collected. Fields left null/empty simply mean "not answered".
  Future<DailyLogEntry> upsert({
    required DateTime loggedOn,
    String? flowIntensity,
    int? crampIntensity,
    List<String> moods = const [],
    String? energyLevel,
    String? sleepQuality,
    int? wellbeing,
    List<String> symptoms = const [],
  });
}
