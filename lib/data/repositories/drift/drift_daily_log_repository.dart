import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/date_format.dart';
import '../../local/app_database.dart';
import '../daily_log_repository.dart';

class DriftDailyLogRepository implements DailyLogRepository {
  DriftDailyLogRepository(this._db);

  final AppDatabase _db;

  static List<String> _decodeList(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded.map((e) => e.toString()).toList();
  }

  static String _encodeList(List<String> values) => jsonEncode(values);

  DailyLogEntry _mapEntry(DailyLogRow row) {
    return DailyLogEntry(
      id: row.id,
      loggedOn: dateOnly(row.loggedOn),
      flowIntensity: row.flowIntensity,
      crampIntensity: row.crampIntensity,
      moods: _decodeList(row.moods),
      energyLevel: row.energyLevel,
      sleepQuality: row.sleepQuality,
      wellbeing: row.wellbeing,
      symptoms: _decodeList(row.symptoms),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  int _computeStreak(Set<DateTime> loggedDays) {
    if (loggedDays.isEmpty) return 0;

    final today = dateOnly(DateTime.now());
    var cursor = loggedDays.contains(today)
        ? today
        : today.subtract(const Duration(days: 1));
    if (!loggedDays.contains(cursor)) return 0;

    var streak = 0;
    while (loggedDays.contains(cursor)) {
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  @override
  Future<DailyLogEntry?> getByDate(DateTime date) async {
    final day = dateOnly(date);
    final row = await (_db.select(
      _db.dailyLogs,
    )..where((t) => t.loggedOn.equals(day))).getSingleOrNull();
    if (row == null) return null;
    return _mapEntry(row);
  }

  @override
  Stream<DailyLogEntry?> watchByDate(DateTime date) {
    final day = dateOnly(date);
    return (_db.select(_db.dailyLogs)..where((t) => t.loggedOn.equals(day)))
        .watchSingleOrNull()
        .map((row) => row == null ? null : _mapEntry(row));
  }

  @override
  Future<List<DailyLogEntry>> getAll() async {
    final rows = await (_db.select(_db.dailyLogs)
          ..orderBy([(t) => OrderingTerm.desc(t.loggedOn)]))
        .get();
    return rows.map(_mapEntry).toList();
  }

  @override
  Future<bool> hasLoggedOn(DateTime date) async {
    return await getByDate(date) != null;
  }

  @override
  Future<int> getTotalLoggedDays() async {
    final countExp = _db.dailyLogs.id.count();
    final query = _db.selectOnly(_db.dailyLogs)..addColumns([countExp]);
    final row = await query.getSingle();
    return row.read(countExp) ?? 0;
  }

  @override
  Stream<int> watchTotalLoggedDays() {
    final countExp = _db.dailyLogs.id.count();
    final query = _db.selectOnly(_db.dailyLogs)..addColumns([countExp]);
    return query
        .watchSingle()
        .map((row) => row.read(countExp) ?? 0);
  }

  @override
  Future<int> getCurrentStreak() async {
    final rows = await _db.select(_db.dailyLogs).get();
    if (rows.isEmpty) return 0;
    final loggedDays = rows.map((r) => dateOnly(r.loggedOn)).toSet();
    return _computeStreak(loggedDays);
  }

  @override
  Stream<int> watchCurrentStreak() {
    return _db.select(_db.dailyLogs).watch().map((rows) {
      final loggedDays = rows.map((r) => dateOnly(r.loggedOn)).toSet();
      return _computeStreak(loggedDays);
    });
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
    final encodedMoods = _encodeList(moods);
    final encodedSymptoms = _encodeList(symptoms);

    final existing = await (_db.select(
      _db.dailyLogs,
    )..where((t) => t.loggedOn.equals(day))).getSingleOrNull();

    if (existing == null) {
      await _db
          .into(_db.dailyLogs)
          .insert(
            DailyLogsCompanion.insert(
              loggedOn: day,
              flowIntensity: Value(flowIntensity),
              crampIntensity: Value(crampIntensity),
              moods: Value(encodedMoods),
              energyLevel: Value(energyLevel),
              sleepQuality: Value(sleepQuality),
              wellbeing: Value(wellbeing),
              symptoms: Value(encodedSymptoms),
              createdAt: now,
              updatedAt: now,
            ),
          );
    } else {
      await (_db.update(
        _db.dailyLogs,
      )..where((t) => t.id.equals(existing.id))).write(
        DailyLogsCompanion(
          flowIntensity: Value(flowIntensity),
          crampIntensity: Value(crampIntensity),
          moods: Value(encodedMoods),
          energyLevel: Value(energyLevel),
          sleepQuality: Value(sleepQuality),
          wellbeing: Value(wellbeing),
          symptoms: Value(encodedSymptoms),
          updatedAt: Value(now),
        ),
      );
    }

    return (await getByDate(day))!;
  }
}
