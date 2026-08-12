import '../../core/date_format.dart';
import '../models/period_log.dart';

export '../models/period_log.dart';

/// Persistence for period episodes and bleed-day calendar data.
abstract class PeriodRepository {
  Future<PeriodLog?> getLatest();

  Stream<PeriodLog?> watchLatest();

  Future<List<PeriodLog>> getAll();

  Stream<List<PeriodLog>> watchAll();

  Future<Set<DateTime>> allBleedDays();

  /// Days since the latest period start (0 = started today). Null if none.
  Future<int?> daysSinceLastPeriod([DateTime? today]);

  /// Insert or update a period keyed by [startedOn].
  ///
  /// Throws [ArgumentError] if [startedOn] is after today.
  ///
  /// New metadata fields default from [source] and [endedOn] when omitted.
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
  });

  Future<void> recordLastPeriod({
    required DateTime startedOn,
    required int? typicalPeriodDays,
  });

  /// Onboarding: latest period still open (no end date yet).
  Future<PeriodLog> recordOnboardingLastOpen({
    required DateTime startedOn,
  });

  /// Onboarding: latest period ended on an exact inclusive date.
  Future<PeriodLog> recordOnboardingLastExactEnd({
    required DateTime startedOn,
    required DateTime endedOn,
  });

  /// Onboarding: latest period ended via a rough duration bucket.
  Future<PeriodLog> recordOnboardingLastRoughEnd({
    required DateTime startedOn,
    required String roughDurationBucket,
  });

  Future<void> recordPastStarts({
    required List<DateTime> startedOnDates,
    required int? typicalPeriodDays,
  });

  /// All period starts except the latest episode (older history only).
  Future<List<DateTime>> getPastStartedOn();

  /// Adds one past start (settings / history). Skips dates on/after the latest.
  Future<PeriodLog?> addPastStart({
    required DateTime startedOn,
    required int? typicalPeriodDays,
  });

  Future<void> deleteByStartedOn(DateTime startedOn);

  /// Replaces past (non-latest) starts with [startedOnDates].
  ///
  /// The latest episode is left unchanged. Dates on or after the latest start
  /// are ignored. Removals delete matching rows.
  Future<void> syncPastStarts({
    required List<DateTime> startedOnDates,
    required int? typicalPeriodDays,
  });

  /// Moves (or creates) the latest period episode to [newStartedOn].
  ///
  /// Recalculates `endedOn` from [typicalPeriodDays] when provided; otherwise
  /// preserves the previous episode length when known.
  Future<PeriodLog> updateLatestStartedOn({
    required DateTime newStartedOn,
    int? typicalPeriodDays,
  });

  /// Add Period: ongoing manual episode with no end date yet.
  Future<PeriodLog> saveOngoingManualPeriod({
    required DateTime startedOn,
  });

  /// Add Period: manual episode with an exact inclusive end date.
  Future<PeriodLog> saveExactEndedManualPeriod({
    required DateTime startedOn,
    required DateTime endedOn,
  });

  /// Add Period: manual episode ended via a rough duration bucket.
  Future<PeriodLog> saveRoughEndedManualPeriod({
    required DateTime startedOn,
    required String roughDurationBucket,
  });

  static DateTime? estimateEnd(DateTime startedOn, int? typicalPeriodDays) {
    if (typicalPeriodDays == null || typicalPeriodDays < 1) return null;
    return dateOnly(startedOn).add(Duration(days: typicalPeriodDays - 1));
  }

  static DateTime? estimateEndFromBucket(
    DateTime startedOn,
    String roughDurationBucket,
  ) {
    final days = RoughDurationBuckets.typicalDaysFor(roughDurationBucket);
    return estimateEnd(startedOn, days);
  }
}
