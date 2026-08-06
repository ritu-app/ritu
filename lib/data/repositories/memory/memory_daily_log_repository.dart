import '../../../core/date_format.dart';
import '../daily_log_repository.dart';
import 'memory_ritu_store.dart';

class MemoryDailyLogRepository implements DailyLogRepository {
  MemoryDailyLogRepository(this._store);

  final MemoryRituStore _store;

  int _computeStreak(Set<DateTime> loggedDays) {
    if (loggedDays.isEmpty) return 0;

    final today = dateOnly(DateTime.now());
    var cursor =
        loggedDays.contains(today) ? today : today.subtract(const Duration(days: 1));
    if (!loggedDays.contains(cursor)) return 0;

    var streak = 0;
    while (loggedDays.contains(cursor)) {
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  Set<DateTime> get _loggedDays =>
      _store.dailyLogs.keys.map(dateOnly).toSet();

  @override
  Future<DailyLogEntry?> getByDate(DateTime date) async {
    return _store.dailyLogs[dateOnly(date)];
  }

  @override
  Stream<DailyLogEntry?> watchByDate(DateTime date) async* {
    final day = dateOnly(date);
    yield _store.dailyLogs[day];
    await for (final _ in _store.dailyLogsChanges) {
      yield _store.dailyLogs[day];
    }
  }

  @override
  Future<bool> hasLoggedOn(DateTime date) async {
    return await getByDate(date) != null;
  }

  @override
  Future<int> getTotalLoggedDays() async => _store.dailyLogs.length;

  @override
  Stream<int> watchTotalLoggedDays() async* {
    yield _store.dailyLogs.length;
    await for (final _ in _store.dailyLogsChanges) {
      yield _store.dailyLogs.length;
    }
  }

  @override
  Future<int> getCurrentStreak() async => _computeStreak(_loggedDays);

  @override
  Stream<int> watchCurrentStreak() async* {
    yield _computeStreak(_loggedDays);
    await for (final _ in _store.dailyLogsChanges) {
      yield _computeStreak(_loggedDays);
    }
  }

  @override
  Future<DailyLogEntry> upsert({
    required DateTime loggedOn,
    String? flowIntensity,
    int? crampIntensity,
    List<String> moods = const [],
    String? energyLevel,
    String? sleepQuality,
    int? wellbeing,
    List<String> symptoms = const [],
  }) async {
    final day = dateOnly(loggedOn);
    final now = DateTime.now();

    final existing = _store.dailyLogs[day];
    if (existing == null) {
      final entry = DailyLogEntry(
        id: _store.nextDailyLogId++,
        loggedOn: day,
        flowIntensity: flowIntensity,
        crampIntensity: crampIntensity,
        moods: List.of(moods),
        energyLevel: energyLevel,
        sleepQuality: sleepQuality,
        wellbeing: wellbeing,
        symptoms: List.of(symptoms),
        createdAt: now,
        updatedAt: now,
      );
      _store.dailyLogs[day] = entry;
    } else {
      _store.dailyLogs[day] = DailyLogEntry(
        id: existing.id,
        loggedOn: day,
        flowIntensity: flowIntensity,
        crampIntensity: crampIntensity,
        moods: List.of(moods),
        energyLevel: energyLevel,
        sleepQuality: sleepQuality,
        wellbeing: wellbeing,
        symptoms: List.of(symptoms),
        createdAt: existing.createdAt,
        updatedAt: now,
      );
    }

    _store.notifyDailyLogs();
    return _store.dailyLogs[day]!;
  }
}
