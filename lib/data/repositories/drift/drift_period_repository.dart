import 'package:drift/drift.dart';

import '../../../core/date_format.dart';
import '../../local/app_database.dart';
import '../period_repository.dart';

class DriftPeriodRepository implements PeriodRepository {
  DriftPeriodRepository(this._db);

  final AppDatabase _db;

  PeriodLog _mapPeriodLog(PeriodLogRow row) {
    return PeriodLog(
      id: row.id,
      startedOn: dateOnly(row.startedOn),
      endedOn: row.endedOn == null ? null : dateOnly(row.endedOn!),
      source: row.source,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  @override
  Future<PeriodLog?> getLatest() async {
    final row = await (_db.select(_db.periodLogs)
          ..orderBy([(t) => OrderingTerm.desc(t.startedOn)])
          ..limit(1))
        .getSingleOrNull();
    if (row == null) return null;
    return _mapPeriodLog(row);
  }

  @override
  Stream<PeriodLog?> watchLatest() {
    return (_db.select(_db.periodLogs)
          ..orderBy([(t) => OrderingTerm.desc(t.startedOn)])
          ..limit(1))
        .watchSingleOrNull()
        .map((row) => row == null ? null : _mapPeriodLog(row));
  }

  @override
  Future<List<PeriodLog>> getAll() async {
    final rows = await (_db.select(_db.periodLogs)
          ..orderBy([(t) => OrderingTerm.desc(t.startedOn)]))
        .get();
    return rows.map(_mapPeriodLog).toList();
  }

  @override
  Stream<List<PeriodLog>> watchAll() {
    return (_db.select(_db.periodLogs)
          ..orderBy([(t) => OrderingTerm.desc(t.startedOn)]))
        .watch()
        .map((rows) => rows.map(_mapPeriodLog).toList());
  }

  @override
  Future<Set<DateTime>> allBleedDays() async {
    final logs = await getAll();
    return {for (final log in logs) ...log.bleedDays};
  }

  @override
  Future<int?> daysSinceLastPeriod([DateTime? today]) async {
    final latest = await getLatest();
    if (latest == null) return null;
    final now = dateOnly(today ?? DateTime.now());
    return now.difference(dateOnly(latest.startedOn)).inDays;
  }

  @override
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
    return _mapPeriodLog(row);
  }

  @override
  Future<void> recordLastPeriod({
    required DateTime startedOn,
    required int? typicalPeriodDays,
  }) async {
    await upsertPeriod(
      startedOn: startedOn,
      endedOn: PeriodRepository.estimateEnd(startedOn, typicalPeriodDays),
      source: PeriodSources.onboardingLast,
    );
  }

  @override
  Future<void> recordPastStarts({
    required List<DateTime> startedOnDates,
    required int? typicalPeriodDays,
  }) async {
    if (startedOnDates.isEmpty) return;
    await _db.transaction(() async {
      for (final start in startedOnDates) {
        await upsertPeriod(
          startedOn: start,
          endedOn: PeriodRepository.estimateEnd(start, typicalPeriodDays),
          source: PeriodSources.onboardingPast,
        );
      }
    });
  }

  @override
  Future<List<DateTime>> getPastStartedOn() async {
    final all = await getAll();
    if (all.length <= 1) return [];
    return all.skip(1).map((log) => dateOnly(log.startedOn)).toList();
  }

  @override
  Future<PeriodLog?> addPastStart({
    required DateTime startedOn,
    required int? typicalPeriodDays,
  }) async {
    final start = dateOnly(startedOn);
    final latest = await getLatest();
    if (latest != null && !start.isBefore(dateOnly(latest.startedOn))) {
      return null;
    }
    return upsertPeriod(
      startedOn: start,
      endedOn: PeriodRepository.estimateEnd(start, typicalPeriodDays),
      source: PeriodSources.manual,
    );
  }

  @override
  Future<void> deleteByStartedOn(DateTime startedOn) async {
    final start = dateOnly(startedOn);
    await (_db.delete(_db.periodLogs)..where((t) => t.startedOn.equals(start)))
        .go();
  }

  @override
  Future<void> syncPastStarts({
    required List<DateTime> startedOnDates,
    required int? typicalPeriodDays,
  }) async {
    final latest = await getLatest();
    final latestStart =
        latest == null ? null : dateOnly(latest.startedOn);

    final desired = <DateTime>{};
    for (final raw in startedOnDates) {
      final start = dateOnly(raw);
      if (latestStart != null && !start.isBefore(latestStart)) continue;
      desired.add(start);
    }

    await _db.transaction(() async {
      final all = await getAll();
      for (final log in all) {
        final start = dateOnly(log.startedOn);
        if (latestStart != null && start == latestStart) continue;
        if (!desired.contains(start)) {
          await (_db.delete(_db.periodLogs)..where((t) => t.id.equals(log.id)))
              .go();
        }
      }

      for (final start in desired) {
        await upsertPeriod(
          startedOn: start,
          endedOn: PeriodRepository.estimateEnd(start, typicalPeriodDays),
          source: PeriodSources.settings,
        );
      }
    });
  }

  @override
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
      end = PeriodRepository.estimateEnd(start, typicalPeriodDays);
    } else if (latest?.endedOn != null) {
      final length =
          dateOnly(latest!.endedOn!).difference(dateOnly(latest.startedOn)).inDays +
              1;
      end = PeriodRepository.estimateEnd(start, length);
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
      return _mapPeriodLog(row);
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
        return _mapPeriodLog(row);
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
      return _mapPeriodLog(row);
    });
  }
}
