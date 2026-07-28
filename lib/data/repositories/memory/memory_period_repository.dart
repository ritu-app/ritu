import '../../../core/date_format.dart';
import '../period_repository.dart';
import 'memory_ritu_store.dart';

class MemoryPeriodRepository implements PeriodRepository {
  MemoryPeriodRepository(this._store);

  final MemoryRituStore _store;

  List<PeriodLog> get _sortedDesc => List<PeriodLog>.from(_store.periods)
    ..sort((a, b) => b.startedOn.compareTo(a.startedOn));

  @override
  Future<PeriodLog?> getLatest() async {
    final all = _sortedDesc;
    return all.isEmpty ? null : all.first;
  }

  @override
  Stream<PeriodLog?> watchLatest() async* {
    yield await getLatest();
    await for (final _ in _store.periodsChanges) {
      yield await getLatest();
    }
  }

  @override
  Future<List<PeriodLog>> getAll() async => _sortedDesc;

  @override
  Stream<List<PeriodLog>> watchAll() async* {
    yield await getAll();
    await for (final _ in _store.periodsChanges) {
      yield await getAll();
    }
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

    final index = _store.periods.indexWhere(
      (log) => dateOnly(log.startedOn) == start,
    );

    if (index == -1) {
      final log = PeriodLog(
        id: _store.nextPeriodId++,
        startedOn: start,
        endedOn: end,
        source: source,
        createdAt: now,
        updatedAt: now,
      );
      _store.periods.add(log);
      _store.notifyPeriods();
      return log;
    }

    final existing = _store.periods[index];
    final updated = PeriodLog(
      id: existing.id,
      startedOn: start,
      endedOn: end,
      source: source,
      createdAt: existing.createdAt,
      updatedAt: now,
    );
    _store.periods[index] = updated;
    _store.notifyPeriods();
    return updated;
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
    for (final start in startedOnDates) {
      await upsertPeriod(
        startedOn: start,
        endedOn: PeriodRepository.estimateEnd(start, typicalPeriodDays),
        source: PeriodSources.onboardingPast,
      );
    }
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
      source: PeriodSources.settings,
    );
  }

  @override
  Future<void> deleteByStartedOn(DateTime startedOn) async {
    final start = dateOnly(startedOn);
    _store.periods.removeWhere((log) => dateOnly(log.startedOn) == start);
    _store.notifyPeriods();
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

    final all = await getAll();
    for (final log in all) {
      final start = dateOnly(log.startedOn);
      if (latestStart != null && start == latestStart) continue;
      if (!desired.contains(start)) {
        _store.periods.removeWhere((p) => p.id == log.id);
      }
    }

    for (final start in desired) {
      await upsertPeriod(
        startedOn: start,
        endedOn: PeriodRepository.estimateEnd(start, typicalPeriodDays),
        source: PeriodSources.settings,
      );
    }
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
        final index = _store.periods.indexWhere((p) => p.id == latest.id);
        if (index != -1) {
          _store.periods[index] = PeriodLog(
            id: latest.id,
            startedOn: start,
            endedOn: end,
            source: PeriodSources.settings,
            createdAt: latest.createdAt,
            updatedAt: now,
          );
          _store.notifyPeriods();
        }
      }
      return (await getLatest())!;
    }

    final conflictIndex = _store.periods.indexWhere(
      (log) => dateOnly(log.startedOn) == start,
    );

    if (conflictIndex != -1 && _store.periods[conflictIndex].id != latest.id) {
      final conflict = _store.periods[conflictIndex];
      _store.periods.removeWhere((p) => p.id == latest.id);
      _store.periods[conflictIndex] = PeriodLog(
        id: conflict.id,
        startedOn: start,
        endedOn: end,
        source: PeriodSources.settings,
        createdAt: conflict.createdAt,
        updatedAt: now,
      );
      _store.notifyPeriods();
      return _store.periods[conflictIndex];
    }

    final latestIndex = _store.periods.indexWhere((p) => p.id == latest.id);
    _store.periods[latestIndex] = PeriodLog(
      id: latest.id,
      startedOn: start,
      endedOn: end,
      source: PeriodSources.settings,
      createdAt: latest.createdAt,
      updatedAt: now,
    );
    _store.notifyPeriods();
    return _store.periods[latestIndex];
  }
}
