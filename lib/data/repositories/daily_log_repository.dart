import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/date_format.dart';
import '../local/app_database.dart';

class DailyLogEntry {
  const DailyLogEntry({
    required this.id,
    required this.loggedOn,
    required this.createdAt,
    required this.updatedAt,
    this.flowIntensity,
    this.crampIntensity,
    this.moods = const [],
    this.energyLevel,
    this.sleepQuality,
    this.wellbeing,
    this.symptoms = const [],
    this.notes,
  });

  final int id;
  final DateTime loggedOn;
  final String? flowIntensity;
  final int? crampIntensity;
  final List<String> moods;
  final String? energyLevel;
  final String? sleepQuality;
  final int? wellbeing;
  final List<String> symptoms;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  static List<String> _decodeList(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded.map((e) => e.toString()).toList();
  }

  static String _encodeList(List<String> values) => jsonEncode(values);

  factory DailyLogEntry.fromRow(DailyLogRow row) {
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
      notes: row.notes,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}

/// Manages the Home "Log today" daily check-in — one row per calendar day.
class DailyLogRepository {
  DailyLogRepository(this._db);

  final AppDatabase _db;

  Future<DailyLogEntry?> getByDate(DateTime date) async {
    final day = dateOnly(date);
    final row = await (_db.select(
      _db.dailyLogs,
    )..where((t) => t.loggedOn.equals(day))).getSingleOrNull();
    if (row == null) return null;
    return DailyLogEntry.fromRow(row);
  }

  Future<bool> hasLoggedOn(DateTime date) async {
    return await getByDate(date) != null;
  }

  /// Total number of calendar days with a saved daily log entry, regardless
  /// of whether they're consecutive. Used to drive the "pattern unlock"
  /// progress on Home, which counts logging days, not periods.
  Future<int> getTotalLoggedDays() async {
    final countExp = _db.dailyLogs.id.count();
    final query = _db.selectOnly(_db.dailyLogs)..addColumns([countExp]);
    final row = await query.getSingle();
    return row.read(countExp) ?? 0;
  }

  /// Number of consecutive days (ending today, or yesterday if today hasn't
  /// been logged yet so the streak isn't broken mid-day) with a saved entry.
  Future<int> getCurrentStreak() async {
    final rows = await _db.select(_db.dailyLogs).get();
    if (rows.isEmpty) return 0;

    final loggedDays = rows.map((r) => dateOnly(r.loggedOn)).toSet();
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
    String? notes,
  }) async {
    final day = dateOnly(loggedOn);
    final now = DateTime.now();
    final trimmedNotes = notes?.trim();
    final resolvedNotes = trimmedNotes == null || trimmedNotes.isEmpty
        ? null
        : trimmedNotes;
    final encodedMoods = DailyLogEntry._encodeList(moods);
    final encodedSymptoms = DailyLogEntry._encodeList(symptoms);

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
              notes: Value(resolvedNotes),
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
          notes: Value(resolvedNotes),
          updatedAt: Value(now),
        ),
      );
    }

    return (await getByDate(day))!;
  }
}
