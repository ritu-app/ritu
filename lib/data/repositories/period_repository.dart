import 'package:drift/drift.dart';

import '../../core/date_format.dart';
import '../local/app_database.dart';

class PeriodSources {
  static const onboardingLast = 'onboarding_last';
  static const onboardingPast = 'onboarding_past';
  static const calendar = 'calendar';
  static const settings = 'settings';
}

class PeriodLog {
  const PeriodLog({
    required this.id,
    required this.startedOn,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
    this.endedOn,
  });

  final int id;
  final DateTime startedOn;
  final DateTime? endedOn;
  final String source;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory PeriodLog.fromRow(PeriodLogRow row) {
    return PeriodLog(
      id: row.id,
      startedOn: dateOnly(row.startedOn),
      endedOn: row.endedOn == null ? null : dateOnly(row.endedOn!),
      source: row.source,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  /// Inclusive bleed days for calendar highlighting.
  Set<DateTime> get bleedDays {
    final start = dateOnly(startedOn);
    final end = endedOn == null ? start : dateOnly(endedOn!);
    if (end.isBefore(start)) return {start};

    final days = <DateTime>{};
    var cursor = start;
    while (!cursor.isAfter(end)) {
      days.add(cursor);
      cursor = cursor.add(const Duration(days: 1));
    }
    return days;
  }
}

class PeriodRepository {
  PeriodRepository(this._db);

  final AppDatabase _db;

  Future<PeriodLog?> getLatest() async {
    final row = await (_db.select(_db.periodLogs)
          ..orderBy([(t) => OrderingTerm.desc(t.startedOn)])
          ..limit(1))
        .getSingleOrNull();
    if (row == null) return null;
    return PeriodLog.fromRow(row);
  }

  Future<List<PeriodLog>> getAll() async {
    final rows = await (_db.select(_db.periodLogs)
          ..orderBy([(t) => OrderingTerm.desc(t.startedOn)]))
        .get();
    return rows.map(PeriodLog.fromRow).toList();
  }

  Future<Set<DateTime>> allBleedDays() async {
    final logs = await getAll();
    return {for (final log in logs) ...log.bleedDays};
  }

  /// Days since the latest period start (0 = started today). Null if none.
  Future<int?> daysSinceLastPeriod([DateTime? today]) async {
    final latest = await getLatest();
    if (latest == null) return null;
    final now = dateOnly(today ?? DateTime.now());
    return now.difference(dateOnly(latest.startedOn)).inDays;
  }

  /// Insert or update a period keyed by [startedOn].
  ///
  /// Throws [ArgumentError] if [startedOn] is after today.
  Future<PeriodLog> upsertPeriod({
    required DateTime startedOn,
    DateTime? endedOn,
    required String source,
  }) async {
    final start = dateOnly(startedOn);
    final today = dateOnly(DateTime.now());
    if (start.isAfter(today)) {
      throw ArgumentError.value(
        startedOn,
        'startedOn',
        'Period start cannot be in the future',
      );
    }
    final end = endedOn == null ? null : dateOnly(endedOn);
    final now = DateTime.now();

    final existing = await (_db.select(_db.periodLogs)
          ..where((t) => t.startedOn.equals(start)))
        .getSingleOrNull();

    if (existing == null) {
      await _db.into(_db.periodLogs).insert(
            PeriodLogsCompanion.insert(
              startedOn: start,
              endedOn: Value(end),
              source: source,
              createdAt: now,
              updatedAt: now,
            ),
          );
    } else {
      await (_db.update(_db.periodLogs)
            ..where((t) => t.id.equals(existing.id)))
          .write(
        PeriodLogsCompanion(
          endedOn: Value(end),
          source: Value(source),
          updatedAt: Value(now),
        ),
      );
    }

    final row = await (_db.select(_db.periodLogs)
          ..where((t) => t.startedOn.equals(start)))
        .getSingle();
    return PeriodLog.fromRow(row);
  }

  Future<void> recordLastPeriod({
    required DateTime startedOn,
    required int? typicalPeriodDays,
  }) async {
    await upsertPeriod(
      startedOn: startedOn,
      endedOn: estimateEnd(startedOn, typicalPeriodDays),
      source: PeriodSources.onboardingLast,
    );
  }

  Future<void> recordPastStarts({
    required List<DateTime> startedOnDates,
    required int? typicalPeriodDays,
  }) async {
    if (startedOnDates.isEmpty) return;
    await _db.transaction(() async {
      for (final start in startedOnDates) {
        await upsertPeriod(
          startedOn: start,
          endedOn: estimateEnd(start, typicalPeriodDays),
          source: PeriodSources.onboardingPast,
        );
      }
    });
  }

  /// Moves (or creates) the latest period episode to [newStartedOn].
  ///
  /// Recalculates `endedOn` from [typicalPeriodDays] when provided; otherwise
  /// preserves the previous episode length when known.
  Future<PeriodLog> updateLatestStartedOn({
    required DateTime newStartedOn,
    int? typicalPeriodDays,
  }) async {
    final start = dateOnly(newStartedOn);
    final today = dateOnly(DateTime.now());
    if (start.isAfter(today)) {
      throw ArgumentError.value(
        newStartedOn,
        'newStartedOn',
        'Period start cannot be in the future',
      );
    }
    final latest = await getLatest();
    final now = DateTime.now();

    DateTime? end;
    if (typicalPeriodDays != null && typicalPeriodDays >= 1) {
      end = estimateEnd(start, typicalPeriodDays);
    } else if (latest?.endedOn != null) {
      final length =
          dateOnly(latest!.endedOn!).difference(dateOnly(latest.startedOn)).inDays +
              1;
      end = estimateEnd(start, length);
    }

    if (latest == null) {
      return upsertPeriod(
        startedOn: start,
        endedOn: end,
        source: PeriodSources.settings,
      );
    }

    if (dateOnly(latest.startedOn) == start) {
      if (end != latest.endedOn) {
        await (_db.update(_db.periodLogs)..where((t) => t.id.equals(latest.id)))
            .write(
          PeriodLogsCompanion(
            endedOn: Value(end),
            source: const Value(PeriodSources.settings),
            updatedAt: Value(now),
          ),
        );
      }
      final row = await (_db.select(_db.periodLogs)
            ..where((t) => t.id.equals(latest.id)))
          .getSingle();
      return PeriodLog.fromRow(row);
    }

    final conflict = await (_db.select(_db.periodLogs)
          ..where((t) => t.startedOn.equals(start)))
        .getSingleOrNull();

    return _db.transaction(() async {
      if (conflict != null && conflict.id != latest.id) {
        await (_db.delete(_db.periodLogs)
              ..where((t) => t.id.equals(latest.id)))
            .go();
        await (_db.update(_db.periodLogs)
              ..where((t) => t.id.equals(conflict.id)))
            .write(
          PeriodLogsCompanion(
            endedOn: Value(end),
            source: const Value(PeriodSources.settings),
            updatedAt: Value(now),
          ),
        );
        final row = await (_db.select(_db.periodLogs)
              ..where((t) => t.id.equals(conflict.id)))
            .getSingle();
        return PeriodLog.fromRow(row);
      }

      await (_db.update(_db.periodLogs)..where((t) => t.id.equals(latest.id)))
          .write(
        PeriodLogsCompanion(
          startedOn: Value(start),
          endedOn: Value(end),
          source: const Value(PeriodSources.settings),
          updatedAt: Value(now),
        ),
      );
      final row = await (_db.select(_db.periodLogs)
            ..where((t) => t.id.equals(latest.id)))
          .getSingle();
      return PeriodLog.fromRow(row);
    });
  }

  static DateTime? estimateEnd(DateTime startedOn, int? typicalPeriodDays) {
    if (typicalPeriodDays == null || typicalPeriodDays < 1) return null;
    return dateOnly(startedOn).add(Duration(days: typicalPeriodDays - 1));
  }
}
