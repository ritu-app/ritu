import 'package:flutter_test/flutter_test.dart';
import 'package:ritu/core/date_format.dart';
import 'package:ritu/data/local/app_database.dart';
import 'package:ritu/data/models/period_log.dart';
import 'package:ritu/data/repositories/drift/drift_period_repository.dart';
import 'package:ritu/data/repositories/memory/memory_period_repository.dart';
import 'package:ritu/data/repositories/memory/memory_ritu_store.dart';
import 'package:ritu/data/repositories/period_repository.dart';

void main() {
  group('PeriodRepository drift/memory parity', () {
    late AppDatabase database;
    late DriftPeriodRepository drift;
    late MemoryPeriodRepository memory;

    setUp(() {
      database = AppDatabase.memory();
      drift = DriftPeriodRepository(database);
      memory = MemoryPeriodRepository(MemoryRituStore());
    });

    tearDown(() async {
      await database.close();
    });

    Future<void> expectSameMetadata(
      Future<PeriodLog> driftFuture,
      Future<PeriodLog> memoryFuture,
    ) async {
      final a = await driftFuture;
      final b = await memoryFuture;
      expect(dateOnly(a.startedOn), dateOnly(b.startedOn));
      expect(a.endedOn == null ? null : dateOnly(a.endedOn!), b.endedOn == null ? null : dateOnly(b.endedOn!));
      expect(a.source, b.source);
      expect(a.startSource, b.startSource);
      expect(a.startConfidence, b.startConfidence);
      expect(a.endStatus, b.endStatus);
      expect(a.endSource, b.endSource);
      expect(a.endConfidence, b.endConfidence);
      expect(a.roughDurationBucket, b.roughDurationBucket);
    }

    test('saveOngoingManualPeriod stores open episode', () async {
      final start = dateOnly(DateTime.now().subtract(const Duration(days: 2)));
      await expectSameMetadata(
        drift.saveOngoingManualPeriod(startedOn: start),
        memory.saveOngoingManualPeriod(startedOn: start),
      );
      final saved = await drift.saveOngoingManualPeriod(startedOn: start);
      expect(saved.isOpen, isTrue);
      expect(saved.endedOn, isNull);
      expect(saved.startSource, PeriodStartSources.periodHistory);
    });

    test('saveExactEndedManualPeriod stores confirmed end', () async {
      final start = dateOnly(DateTime.now().subtract(const Duration(days: 30)));
      final end = start.add(const Duration(days: 4));
      await expectSameMetadata(
        drift.saveExactEndedManualPeriod(startedOn: start, endedOn: end),
        memory.saveExactEndedManualPeriod(startedOn: start, endedOn: end),
      );
      final saved =
          await drift.saveExactEndedManualPeriod(startedOn: start, endedOn: end);
      expect(saved.hasConfirmedEnd, isTrue);
      expect(saved.endSource, PeriodEndSources.addPeriodExact);
    });

    test('saveRoughEndedManualPeriod stores bucket and approximate end', () async {
      final start = dateOnly(DateTime.now().subtract(const Duration(days: 60)));
      await expectSameMetadata(
        drift.saveRoughEndedManualPeriod(
          startedOn: start,
          roughDurationBucket: RoughDurationBuckets.sixToSevenDays,
        ),
        memory.saveRoughEndedManualPeriod(
          startedOn: start,
          roughDurationBucket: RoughDurationBuckets.sixToSevenDays,
        ),
      );
      final saved = await drift.saveRoughEndedManualPeriod(
        startedOn: start,
        roughDurationBucket: RoughDurationBuckets.sixToSevenDays,
      );
      expect(saved.hasApproximateEnd, isTrue);
      expect(saved.roughDurationBucket, RoughDurationBuckets.sixToSevenDays);
      expect(
        saved.endedOn,
        PeriodRepository.estimateEndFromBucket(
          start,
          RoughDurationBuckets.sixToSevenDays,
        ),
      );
    });

    test('recordLastPeriod marks logged onboarding estimate', () async {
      final start = dateOnly(DateTime.now().subtract(const Duration(days: 10)));
      await drift.recordLastPeriod(startedOn: start, typicalPeriodDays: 5);
      await memory.recordLastPeriod(startedOn: start, typicalPeriodDays: 5);

      final driftLatest = await drift.getLatest();
      final memoryLatest = await memory.getLatest();
      expect(driftLatest!.hasLoggedStart, isTrue);
      expect(driftLatest.isManual, isFalse);
      expect(driftLatest.endStatus, PeriodEndStatus.estimated);
      expect(memoryLatest!.endStatus, PeriodEndStatus.estimated);
    });

    test('onboarding last open/exact/rough stay aligned', () async {
      final openStart = dateOnly(DateTime.now().subtract(const Duration(days: 3)));
      final endedStart = dateOnly(DateTime.now().subtract(const Duration(days: 30)));
      final exactEnd = endedStart.add(const Duration(days: 4));

      await drift.recordOnboardingLastOpen(startedOn: openStart);
      await memory.recordOnboardingLastOpen(startedOn: openStart);

      final driftOpen = await drift.getLatest();
      final memoryOpen = await memory.getLatest();
      expect(driftOpen!.isOpen, isTrue);
      expect(driftOpen.startSource, PeriodStartSources.onboardingLast);
      expect(memoryOpen!.isOpen, isTrue);

      await drift.deleteByStartedOn(openStart);
      await memory.deleteByStartedOn(openStart);

      await drift.recordOnboardingLastExactEnd(
        startedOn: endedStart,
        endedOn: exactEnd,
      );
      await memory.recordOnboardingLastExactEnd(
        startedOn: endedStart,
        endedOn: exactEnd,
      );

      final driftExact = await drift.getLatest();
      final memoryExact = await memory.getLatest();
      expect(driftExact!.hasConfirmedEnd, isTrue);
      expect(memoryExact!.hasConfirmedEnd, isTrue);

      await drift.deleteByStartedOn(endedStart);
      await memory.deleteByStartedOn(endedStart);

      await drift.recordOnboardingLastRoughEnd(
        startedOn: endedStart,
        roughDurationBucket: RoughDurationBuckets.sixToSevenDays,
      );
      await memory.recordOnboardingLastRoughEnd(
        startedOn: endedStart,
        roughDurationBucket: RoughDurationBuckets.sixToSevenDays,
      );

      final driftRough = await drift.getLatest();
      final memoryRough = await memory.getLatest();
      expect(driftRough!.hasApproximateEnd, isTrue);
      expect(driftRough.roughDurationBucket,
          RoughDurationBuckets.sixToSevenDays);
      expect(memoryRough!.roughDurationBucket,
          RoughDurationBuckets.sixToSevenDays);
    });
  });
}
