import 'package:drift/drift.dart';

import '../../../core/date_format.dart';
import '../../local/app_database.dart';
import '../period_repository.dart';
import '../period_repository_support.dart';

class DriftPeriodRepository implements PeriodRepository {
  DriftPeriodRepository(this._db);

  final AppDatabase _db;

  PeriodLog _mapPeriodLog(PeriodLogRow row) {
    return PeriodLog(
      id: row.id,
      startedOn: dateOnly(row.startedOn),
      endedOn: row.endedOn == null ? null : dateOnly(row.endedOn!),
      source: row.source,
      startSource: row.startSource,
      startConfidence: row.startConfidence,
      endStatus: row.endStatus,
      endSource: row.endSource,
      endConfidence: row.endConfidence,
      roughDurationBucket: row.roughDurationBucket,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  PeriodLogsCompanion _companionForUpsert({
    required DateTime startedOn,
    DateTime? endedOn,
    required String source,
    required DateTime now,
    String? startSource,
    String? startConfidence,
    String? endStatus,
    String? endSource,
    String? endConfidence,
    String? roughDurationBucket,
  }) {
    final meta = PeriodRepositorySupport.metadataForUpsert(
      legacySource: source,
      startedOn: startedOn,
      endedOn: endedOn,
      startSource: startSource,
      startConfidence: startConfidence,
      endStatus: endStatus,
      endSource: endSource,
      endConfidence: endConfidence,
      roughDurationBucket: roughDurationBucket,
    );
    return PeriodLogsCompanion(
      startedOn: Value(startedOn),
      endedOn: Value(endedOn),
      source: Value(source),
      startSource: Value(meta.startSource),
      startConfidence: Value(meta.startConfidence),
      endStatus: Value(meta.endStatus),
      endSource: Value(meta.endSource),
      endConfidence: Value(meta.endConfidence),
      roughDurationBucket: Value(meta.roughDurationBucket),
      updatedAt: Value(now),
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
    String? startSource,
    String? startConfidence,
    String? endStatus,
    String? endSource,
    String? endConfidence,
    String? roughDurationBucket,
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
    final meta = PeriodRepositorySupport.metadataForUpsert(
      legacySource: source,
      startedOn: start,
      endedOn: end,
      startSource: startSource,
      startConfidence: startConfidence,
      endStatus: endStatus,
      endSource: endSource,
      endConfidence: endConfidence,
      roughDurationBucket: roughDurationBucket,
    );

    final existing = await (_db.select(_db.periodLogs)
          ..where((t) => t.startedOn.equals(start)))
        .getSingleOrNull();

    if (existing == null) {
      await _db.into(_db.periodLogs).insert(
            PeriodLogsCompanion.insert(
              startedOn: start,
              endedOn: Value(end),
              source: source,
              startSource: Value(meta.startSource),
              startConfidence: Value(meta.startConfidence),
              endStatus: Value(meta.endStatus),
              endSource: Value(meta.endSource),
              endConfidence: Value(meta.endConfidence),
              roughDurationBucket: Value(meta.roughDurationBucket),
              createdAt: now,
              updatedAt: now,
            ),
          );
    } else {
      await (_db.update(_db.periodLogs)
            ..where((t) => t.id.equals(existing.id)))
          .write(
        _companionForUpsert(
          startedOn: start,
          endedOn: end,
          source: source,
          now: now,
          startSource: startSource,
          startConfidence: startConfidence,
          endStatus: endStatus,
          endSource: endSource,
          endConfidence: endConfidence,
          roughDurationBucket: roughDurationBucket,
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
    final end = PeriodRepository.estimateEnd(startedOn, typicalPeriodDays);
    final meta = PeriodRepositorySupport.metadataForEstimatedOnboarding(
      startSource: PeriodStartSources.onboardingLast,
      startConfidence: PeriodStartConfidence.logged,
      endSource: PeriodEndSources.onboardingEstimate,
      endedOn: end,
    );
    await upsertPeriod(
      startedOn: startedOn,
      endedOn: end,
      source: PeriodSources.onboardingLast,
      startSource: meta.startSource,
      startConfidence: meta.startConfidence,
      endStatus: meta.endStatus,
      endSource: meta.endSource,
      endConfidence: meta.endConfidence,
    );
  }

  @override
  Future<PeriodLog> recordOnboardingLastOpen({
    required DateTime startedOn,
  }) {
    final meta = PeriodLogMetadata.forOpenPeriod(
      startSource: PeriodStartSources.onboardingLast,
      startConfidence: PeriodStartConfidence.logged,
    );
    return upsertPeriod(
      startedOn: startedOn,
      source: PeriodSources.onboardingLast,
      startSource: meta.startSource,
      startConfidence: meta.startConfidence,
      endStatus: meta.endStatus,
      endSource: meta.endSource,
      endConfidence: meta.endConfidence,
      roughDurationBucket: meta.roughDurationBucket,
    );
  }

  @override
  Future<PeriodLog> recordOnboardingLastExactEnd({
    required DateTime startedOn,
    required DateTime endedOn,
  }) {
    final meta = PeriodLogMetadata.forExactEnd(
      startSource: PeriodStartSources.onboardingLast,
      startConfidence: PeriodStartConfidence.logged,
      endSource: PeriodEndSources.onboardingEstimate,
    );
    return upsertPeriod(
      startedOn: startedOn,
      endedOn: endedOn,
      source: PeriodSources.onboardingLast,
      startSource: meta.startSource,
      startConfidence: meta.startConfidence,
      endStatus: meta.endStatus,
      endSource: meta.endSource,
      endConfidence: meta.endConfidence,
    );
  }

  @override
  Future<PeriodLog> recordOnboardingLastRoughEnd({
    required DateTime startedOn,
    required String roughDurationBucket,
  }) {
    final end = PeriodRepository.estimateEndFromBucket(
      startedOn,
      roughDurationBucket,
    );
    final meta = PeriodLogMetadata.forRoughEnd(
      startSource: PeriodStartSources.onboardingLast,
      startConfidence: PeriodStartConfidence.logged,
      endSource: PeriodEndSources.onboardingEstimate,
      roughDurationBucket: roughDurationBucket,
      startedOn: startedOn,
      endedOn: end ?? dateOnly(startedOn),
    );
    return upsertPeriod(
      startedOn: startedOn,
      endedOn: end,
      source: PeriodSources.onboardingLast,
      startSource: meta.startSource,
      startConfidence: meta.startConfidence,
      endStatus: meta.endStatus,
      endSource: meta.endSource,
      endConfidence: meta.endConfidence,
      roughDurationBucket: meta.roughDurationBucket,
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
        final end = PeriodRepository.estimateEnd(start, typicalPeriodDays);
        final meta = PeriodRepositorySupport.metadataForEstimatedOnboarding(
          startSource: PeriodStartSources.onboardingPast,
          startConfidence: PeriodStartConfidence.manual,
          endSource: PeriodEndSources.onboardingEstimate,
          endedOn: end,
        );
        await upsertPeriod(
          startedOn: start,
          endedOn: end,
          source: PeriodSources.onboardingPast,
          startSource: meta.startSource,
          startConfidence: meta.startConfidence,
          endStatus: meta.endStatus,
          endSource: meta.endSource,
          endConfidence: meta.endConfidence,
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
    final end = PeriodRepository.estimateEnd(start, typicalPeriodDays);
    final bucket = PeriodRepositorySupport.roughBucketForTypicalDays(
      typicalPeriodDays,
    );
    final meta = end == null
        ? PeriodLogMetadata(
            startSource: PeriodStartSources.periodHistory,
            startConfidence: PeriodStartConfidence.manual,
            endStatus: PeriodEndStatus.unknown,
          )
        : PeriodLogMetadata.forRoughEnd(
            startSource: PeriodStartSources.periodHistory,
            roughDurationBucket:
                bucket ?? RoughDurationBuckets.fourToFiveDays,
            startedOn: start,
            endedOn: end,
          );
    return upsertPeriod(
      startedOn: start,
      endedOn: end,
      source: PeriodSources.manual,
      startSource: meta.startSource,
      startConfidence: meta.startConfidence,
      endStatus: meta.endStatus,
      endSource: meta.endSource,
      endConfidence: meta.endConfidence,
      roughDurationBucket: meta.roughDurationBucket,
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
        final end = PeriodRepository.estimateEnd(start, typicalPeriodDays);
        final meta = PeriodRepositorySupport.metadataForEstimatedOnboarding(
          startSource: PeriodStartSources.settings,
          startConfidence: PeriodStartConfidence.manual,
          endSource: PeriodEndSources.settings,
          endedOn: end,
        );
        await upsertPeriod(
          startedOn: start,
          endedOn: end,
          source: PeriodSources.settings,
          startSource: meta.startSource,
          startConfidence: meta.startConfidence,
          endStatus: meta.endStatus,
          endSource: meta.endSource,
          endConfidence: meta.endConfidence,
        );
      }
    });
  }

  Future<PeriodLog> _updateLatestWithMetadata({
    required PeriodLog latest,
    required DateTime start,
    DateTime? end,
    required PeriodLogMetadata meta,
  }) async {
    final now = DateTime.now();
    await (_db.update(_db.periodLogs)..where((t) => t.id.equals(latest.id)))
        .write(
      PeriodLogsCompanion(
        startedOn: Value(start),
        endedOn: Value(end),
        source: const Value(PeriodSources.settings),
        startSource: Value(meta.startSource),
        startConfidence: Value(meta.startConfidence),
        endStatus: Value(meta.endStatus),
        endSource: Value(meta.endSource),
        endConfidence: Value(meta.endConfidence),
        roughDurationBucket: Value(meta.roughDurationBucket),
        updatedAt: Value(now),
      ),
    );
    final row = await (_db.select(_db.periodLogs)
          ..where((t) => t.id.equals(latest.id)))
        .getSingle();
    return _mapPeriodLog(row);
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

    final meta = PeriodRepositorySupport.metadataForEstimatedOnboarding(
      startSource: PeriodStartSources.settings,
      startConfidence: PeriodStartConfidence.manual,
      endSource: PeriodEndSources.settings,
      endedOn: end,
    );

    if (latest == null) {
      return upsertPeriod(
        startedOn: start,
        endedOn: end,
        source: PeriodSources.settings,
        startSource: meta.startSource,
        startConfidence: meta.startConfidence,
        endStatus: meta.endStatus,
        endSource: meta.endSource,
        endConfidence: meta.endConfidence,
      );
    }

    if (dateOnly(latest.startedOn) == start) {
      if (end != latest.endedOn) {
        return _updateLatestWithMetadata(
          latest: latest,
          start: start,
          end: end,
          meta: meta,
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
            startSource: Value(meta.startSource),
            startConfidence: Value(meta.startConfidence),
            endStatus: Value(meta.endStatus),
            endSource: Value(meta.endSource),
            endConfidence: Value(meta.endConfidence),
            roughDurationBucket: Value(meta.roughDurationBucket),
            updatedAt: Value(now),
          ),
        );
        final row = await (_db.select(_db.periodLogs)
              ..where((t) => t.id.equals(conflict.id)))
            .getSingle();
        return _mapPeriodLog(row);
      }

      return _updateLatestWithMetadata(
        latest: latest,
        start: start,
        end: end,
        meta: meta,
      );
    });
  }

  @override
  Future<PeriodLog> saveOngoingManualPeriod({
    required DateTime startedOn,
  }) {
    final meta = PeriodLogMetadata.forOpenPeriod(
      startSource: PeriodStartSources.periodHistory,
      startConfidence: PeriodStartConfidence.manual,
    );
    return upsertPeriod(
      startedOn: startedOn,
      source: PeriodSources.manual,
      startSource: meta.startSource,
      startConfidence: meta.startConfidence,
      endStatus: meta.endStatus,
      endSource: meta.endSource,
      endConfidence: meta.endConfidence,
      roughDurationBucket: meta.roughDurationBucket,
    );
  }

  @override
  Future<PeriodLog> saveExactEndedManualPeriod({
    required DateTime startedOn,
    required DateTime endedOn,
  }) {
    final meta = PeriodLogMetadata.forExactEnd(
      startSource: PeriodStartSources.periodHistory,
      startConfidence: PeriodStartConfidence.manual,
      endSource: PeriodEndSources.addPeriodExact,
    );
    return upsertPeriod(
      startedOn: startedOn,
      endedOn: endedOn,
      source: PeriodSources.manual,
      startSource: meta.startSource,
      startConfidence: meta.startConfidence,
      endStatus: meta.endStatus,
      endSource: meta.endSource,
      endConfidence: meta.endConfidence,
    );
  }

  @override
  Future<PeriodLog> saveRoughEndedManualPeriod({
    required DateTime startedOn,
    required String roughDurationBucket,
  }) {
    final end = PeriodRepository.estimateEndFromBucket(
      startedOn,
      roughDurationBucket,
    );
    final meta = PeriodLogMetadata.forRoughEnd(
      startSource: PeriodStartSources.periodHistory,
      roughDurationBucket: roughDurationBucket,
      startedOn: startedOn,
      endedOn: end ?? dateOnly(startedOn),
    );
    return upsertPeriod(
      startedOn: startedOn,
      endedOn: end,
      source: PeriodSources.manual,
      startSource: meta.startSource,
      startConfidence: meta.startConfidence,
      endStatus: meta.endStatus,
      endSource: meta.endSource,
      endConfidence: meta.endConfidence,
      roughDurationBucket: meta.roughDurationBucket,
    );
  }
}
