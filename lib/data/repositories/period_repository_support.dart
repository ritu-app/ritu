import '../models/period_log.dart';

/// Shared helpers for populating period metadata in both repository impls.
class PeriodRepositorySupport {
  PeriodRepositorySupport._();

  static PeriodLogMetadata metadataForUpsert({
    required String legacySource,
    required DateTime startedOn,
    DateTime? endedOn,
    String? startSource,
    String? startConfidence,
    String? endStatus,
    String? endSource,
    String? endConfidence,
    String? roughDurationBucket,
  }) {
    return PeriodLogMetadata.resolve(
      legacySource: legacySource,
      startedOn: startedOn,
      endedOn: endedOn,
      startSource: startSource,
      startConfidence: startConfidence,
      endStatus: endStatus,
      endSource: endSource,
      endConfidence: endConfidence,
      roughDurationBucket: roughDurationBucket,
    );
  }

  static PeriodLogMetadata metadataForEstimatedOnboarding({
    required String startSource,
    required String startConfidence,
    required String endSource,
    DateTime? endedOn,
  }) {
    if (endedOn == null) {
      return PeriodLogMetadata(
        startSource: startSource,
        startConfidence: startConfidence,
        endStatus: PeriodEndStatus.unknown,
      );
    }
    return PeriodLogMetadata.forEstimatedEnd(
      startSource: startSource,
      startConfidence: startConfidence,
      endSource: endSource,
    );
  }

  static String? roughBucketForTypicalDays(int? typicalPeriodDays) {
    if (typicalPeriodDays == null || typicalPeriodDays < 1) return null;
    return RoughDurationBuckets.fromInclusiveDayCount(typicalPeriodDays);
  }
}
