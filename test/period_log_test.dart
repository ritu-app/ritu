import 'package:flutter_test/flutter_test.dart';
import 'package:ritu/data/models/period_log.dart';

void main() {
  group('PeriodLog helpers', () {
    test('onboarding_last is logged start, not manual', () {
      final log = PeriodLog(
        id: 1,
        startedOn: DateTime(2026, 7, 1),
        endedOn: DateTime(2026, 7, 5),
        source: PeriodSources.onboardingLast,
        createdAt: DateTime(2026, 7, 1),
        updatedAt: DateTime(2026, 7, 1),
      );

      expect(log.hasLoggedStart, isTrue);
      expect(log.hasManualStart, isFalse);
      expect(log.isManual, isFalse);
      expect(log.endStatus, PeriodEndStatus.estimated);
    });

    test('period history manual start uses rough approximate end', () {
      final log = PeriodLog(
        id: 1,
        startedOn: DateTime(2026, 6, 1),
        endedOn: DateTime(2026, 6, 5),
        source: PeriodSources.manual,
        createdAt: DateTime(2026, 6, 1),
        updatedAt: DateTime(2026, 6, 1),
      );

      expect(log.startSource, PeriodStartSources.periodHistory);
      expect(log.hasManualStart, isTrue);
      expect(log.isManual, isTrue);
      expect(log.hasApproximateEnd, isTrue);
      expect(log.endStatus, PeriodEndStatus.rough);
      expect(log.roughDurationBucket, RoughDurationBuckets.fourToFiveDays);
    });

    test('open period from daily log has no end date', () {
      final log = PeriodLog(
        id: 1,
        startedOn: DateTime(2026, 8, 1),
        source: PeriodSources.calendar,
        createdAt: DateTime(2026, 8, 1),
        updatedAt: DateTime(2026, 8, 1),
      );

      expect(log.isOpen, isTrue);
      expect(log.endStatus, PeriodEndStatus.open);
      expect(log.endedOn, isNull);
      expect(log.hasConfirmedEnd, isFalse);
    });

    test('exact ended period is confirmed', () {
      final log = PeriodLog(
        id: 1,
        startedOn: DateTime(2026, 8, 1),
        endedOn: DateTime(2026, 8, 4),
        source: PeriodSources.manual,
        startSource: PeriodStartSources.periodHistory,
        startConfidence: PeriodStartConfidence.manual,
        endStatus: PeriodEndStatus.exact,
        endSource: PeriodEndSources.addPeriodExact,
        endConfidence: PeriodEndConfidence.confirmed,
        createdAt: DateTime(2026, 8, 1),
        updatedAt: DateTime(2026, 8, 1),
      );

      expect(log.hasConfirmedEnd, isTrue);
      expect(log.hasApproximateEnd, isFalse);
      expect(log.isOpen, isFalse);
    });
  });

  group('RoughDurationBuckets', () {
    test('maps inclusive day counts to buckets', () {
      expect(
        RoughDurationBuckets.fromInclusiveDayCount(3),
        RoughDurationBuckets.twoToThreeDays,
      );
      expect(
        RoughDurationBuckets.fromInclusiveDayCount(8),
        RoughDurationBuckets.eightPlusDays,
      );
    });

    test('derives endedOn from bucket via repository helper days', () {
      expect(
        RoughDurationBuckets.typicalDaysFor(RoughDurationBuckets.sixToSevenDays),
        7,
      );
    });
  });
}
