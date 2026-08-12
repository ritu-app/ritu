import '../../core/date_format.dart';

/// Legacy provenance values stored in [PeriodLog.source].
class PeriodSources {
  static const onboardingLast = 'onboarding_last';
  static const onboardingPast = 'onboarding_past';
  static const calendar = 'calendar';
  static const settings = 'settings';

  /// Backfilled from Period History (not logged in real time).
  static const manual = 'manual';

  /// True when the episode used the legacy [source] column only.
  static bool isManual(String source) =>
      source == manual ||
      source == settings ||
      source == onboardingPast;
}

/// Where a period start was recorded.
class PeriodStartSources {
  static const dailyLog = 'daily_log';
  static const onboardingLast = 'onboarding_last';
  static const onboardingPast = 'onboarding_past';
  static const periodHistory = 'period_history';
  static const settings = 'settings';
}

/// Whether the start was logged live or recalled manually.
class PeriodStartConfidence {
  static const logged = 'logged';
  static const manual = 'manual';
}

/// How the period end is represented.
class PeriodEndStatus {
  static const open = 'open';
  static const exact = 'exact';
  static const rough = 'rough';
  static const estimated = 'estimated';
  static const autoCapped = 'auto_capped';
  static const unknown = 'unknown';
}

/// Where a period end came from.
class PeriodEndSources {
  static const dailyLogNoneGap = 'daily_log_none_gap';
  static const addPeriodExact = 'add_period_exact';
  static const addPeriodRough = 'add_period_rough';
  static const homeConfirm = 'home_confirm';
  static const onboardingEstimate = 'onboarding_estimate';
  static const settings = 'settings';
  static const day10Cap = 'day_10_cap';
}

/// Confidence in the recorded end date.
class PeriodEndConfidence {
  static const confirmed = 'confirmed';
  static const approximate = 'approximate';
  static const estimated = 'estimated';
}

/// Rough duration bucket for Add Period / manual backfill.
class RoughDurationBuckets {
  static const twoToThreeDays = '2_3_days';
  static const fourToFiveDays = '4_5_days';
  static const sixToSevenDays = '6_7_days';
  static const eightPlusDays = '8_plus_days';

  /// Typical bleed length used to derive an inclusive [endedOn].
  static int typicalDaysFor(String bucket) => switch (bucket) {
        twoToThreeDays => 3,
        fourToFiveDays => 5,
        sixToSevenDays => 7,
        eightPlusDays => 8,
        _ => 5,
      };

  /// Bucket that best matches an inclusive bleed-day count.
  static String? fromInclusiveDayCount(int days) {
    if (days <= 3) return twoToThreeDays;
    if (days <= 5) return fourToFiveDays;
    if (days <= 7) return sixToSevenDays;
    if (days >= 8) return eightPlusDays;
    return null;
  }
}

/// Resolved start/end metadata for a period episode.
class PeriodLogMetadata {
  const PeriodLogMetadata({
    required this.startSource,
    required this.startConfidence,
    required this.endStatus,
    this.endSource,
    this.endConfidence,
    this.roughDurationBucket,
  });

  final String startSource;
  final String startConfidence;
  final String endStatus;
  final String? endSource;
  final String? endConfidence;
  final String? roughDurationBucket;

  /// Derives metadata from the legacy [source] column and optional [endedOn].
  static PeriodLogMetadata fromLegacySource(
    String source, {
    DateTime? startedOn,
    DateTime? endedOn,
  }) {
    final hasEnd = endedOn != null;
    final inclusiveDays = hasEnd && startedOn != null
        ? dateOnly(endedOn).difference(dateOnly(startedOn)).inDays + 1
        : null;
    switch (source) {
      case PeriodSources.onboardingLast:
        return PeriodLogMetadata(
          startSource: PeriodStartSources.onboardingLast,
          startConfidence: PeriodStartConfidence.logged,
          endStatus: hasEnd
              ? PeriodEndStatus.estimated
              : PeriodEndStatus.unknown,
          endSource: hasEnd ? PeriodEndSources.onboardingEstimate : null,
          endConfidence:
              hasEnd ? PeriodEndConfidence.estimated : null,
        );
      case PeriodSources.onboardingPast:
        return PeriodLogMetadata(
          startSource: PeriodStartSources.onboardingPast,
          startConfidence: PeriodStartConfidence.manual,
          endStatus: hasEnd
              ? PeriodEndStatus.estimated
              : PeriodEndStatus.unknown,
          endSource: hasEnd ? PeriodEndSources.onboardingEstimate : null,
          endConfidence:
              hasEnd ? PeriodEndConfidence.estimated : null,
        );
      case PeriodSources.manual:
        return PeriodLogMetadata(
          startSource: PeriodStartSources.periodHistory,
          startConfidence: PeriodStartConfidence.manual,
          endStatus: hasEnd ? PeriodEndStatus.rough : PeriodEndStatus.unknown,
          endSource: hasEnd ? PeriodEndSources.addPeriodRough : null,
          endConfidence:
              hasEnd ? PeriodEndConfidence.approximate : null,
          roughDurationBucket: inclusiveDays == null
              ? null
              : RoughDurationBuckets.fromInclusiveDayCount(inclusiveDays),
        );
      case PeriodSources.settings:
        return PeriodLogMetadata(
          startSource: PeriodStartSources.settings,
          startConfidence: PeriodStartConfidence.manual,
          endStatus: hasEnd
              ? PeriodEndStatus.estimated
              : PeriodEndStatus.unknown,
          endSource: hasEnd ? PeriodEndSources.settings : null,
          endConfidence:
              hasEnd ? PeriodEndConfidence.estimated : null,
        );
      case PeriodSources.calendar:
        return PeriodLogMetadata(
          startSource: PeriodStartSources.dailyLog,
          startConfidence: PeriodStartConfidence.logged,
          endStatus:
              hasEnd ? PeriodEndStatus.exact : PeriodEndStatus.open,
          endSource: hasEnd ? PeriodEndSources.dailyLogNoneGap : null,
          endConfidence:
              hasEnd ? PeriodEndConfidence.confirmed : null,
        );
      default:
        return PeriodLogMetadata(
          startSource: PeriodStartSources.periodHistory,
          startConfidence: PeriodStartConfidence.manual,
          endStatus: hasEnd ? PeriodEndStatus.rough : PeriodEndStatus.unknown,
          endSource: hasEnd ? PeriodEndSources.addPeriodRough : null,
          endConfidence:
              hasEnd ? PeriodEndConfidence.approximate : null,
        );
    }
  }

  static PeriodLogMetadata resolve({
    required String legacySource,
    DateTime? startedOn,
    DateTime? endedOn,
    String? startSource,
    String? startConfidence,
    String? endStatus,
    String? endSource,
    String? endConfidence,
    String? roughDurationBucket,
  }) {
    final derived =
        fromLegacySource(legacySource, startedOn: startedOn, endedOn: endedOn);
    return PeriodLogMetadata(
      startSource: startSource ?? derived.startSource,
      startConfidence: startConfidence ?? derived.startConfidence,
      endStatus: endStatus ?? derived.endStatus,
      endSource: endSource ?? derived.endSource,
      endConfidence: endConfidence ?? derived.endConfidence,
      roughDurationBucket: roughDurationBucket ?? derived.roughDurationBucket,
    );
  }

  static PeriodLogMetadata forEstimatedEnd({
    required String startSource,
    required String startConfidence,
    required String endSource,
  }) {
    return PeriodLogMetadata(
      startSource: startSource,
      startConfidence: startConfidence,
      endStatus: PeriodEndStatus.estimated,
      endSource: endSource,
      endConfidence: PeriodEndConfidence.estimated,
    );
  }

  static PeriodLogMetadata forRoughEnd({
    required String startSource,
    required String roughDurationBucket,
    required DateTime endedOn,
    required DateTime startedOn,
    String? startConfidence,
    String? endSource,
  }) {
    return PeriodLogMetadata(
      startSource: startSource,
      startConfidence: startConfidence ?? PeriodStartConfidence.manual,
      endStatus: PeriodEndStatus.rough,
      endSource: endSource ?? PeriodEndSources.addPeriodRough,
      endConfidence: PeriodEndConfidence.approximate,
      roughDurationBucket: roughDurationBucket,
    );
  }

  static PeriodLogMetadata forExactEnd({
    required String startSource,
    required String startConfidence,
    required String endSource,
  }) {
    return PeriodLogMetadata(
      startSource: startSource,
      startConfidence: startConfidence,
      endStatus: PeriodEndStatus.exact,
      endSource: endSource,
      endConfidence: PeriodEndConfidence.confirmed,
    );
  }

  static PeriodLogMetadata forOpenPeriod({
    required String startSource,
    required String startConfidence,
  }) {
    return PeriodLogMetadata(
      startSource: startSource,
      startConfidence: startConfidence,
      endStatus: PeriodEndStatus.open,
    );
  }
}

class PeriodLog {
  PeriodLog({
    required this.id,
    required this.startedOn,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
    this.endedOn,
    String? startSource,
    String? startConfidence,
    String? endStatus,
    String? endSource,
    String? endConfidence,
    String? roughDurationBucket,
  }) : _metadata = PeriodLogMetadata.resolve(
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

  final PeriodLogMetadata _metadata;

  final int id;
  final DateTime startedOn;
  final DateTime? endedOn;

  /// Legacy provenance column. Prefer [startSource] / [endSource] for new logic.
  final String source;

  String get startSource => _metadata.startSource;
  String get startConfidence => _metadata.startConfidence;
  String get endStatus => _metadata.endStatus;
  String? get endSource => _metadata.endSource;
  String? get endConfidence => _metadata.endConfidence;
  String? get roughDurationBucket => _metadata.roughDurationBucket;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get hasLoggedStart => startConfidence == PeriodStartConfidence.logged;

  bool get hasManualStart => startConfidence == PeriodStartConfidence.manual;

  bool get hasConfirmedEnd =>
      endStatus == PeriodEndStatus.exact &&
      endConfidence == PeriodEndConfidence.confirmed;

  bool get hasApproximateEnd =>
      endStatus == PeriodEndStatus.rough ||
      endConfidence == PeriodEndConfidence.approximate;

  bool get isOpen => endStatus == PeriodEndStatus.open;

  /// Manual vs logged classification for UI (based on [startConfidence]).
  bool get isManual => hasManualStart;

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

  PeriodLog copyWith({
    int? id,
    DateTime? startedOn,
    DateTime? endedOn,
    bool clearEndedOn = false,
    String? source,
    String? startSource,
    String? startConfidence,
    String? endStatus,
    String? endSource,
    bool clearEndSource = false,
    String? endConfidence,
    bool clearEndConfidence = false,
    String? roughDurationBucket,
    bool clearRoughDurationBucket = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final nextStartedOn = startedOn ?? this.startedOn;
    final nextEndedOn = clearEndedOn ? null : (endedOn ?? this.endedOn);
    final nextSource = source ?? this.source;
    return PeriodLog(
      id: id ?? this.id,
      startedOn: nextStartedOn,
      endedOn: nextEndedOn,
      source: nextSource,
      startSource: startSource,
      startConfidence: startConfidence,
      endStatus: endStatus,
      endSource: clearEndSource ? null : endSource,
      endConfidence: clearEndConfidence ? null : endConfidence,
      roughDurationBucket:
          clearRoughDurationBucket ? null : roughDurationBucket,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
