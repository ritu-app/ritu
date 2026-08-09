import 'classification.dart';
import 'cycle_classification.dart';
import 'cycle_day.dart';
import 'cycle_phase.dart';
import 'period_episode.dart';
import 'phase_ranges.dart';
import 'variable_estimates.dart';

/// Aggregated cycle state for a calendar day — input to UI and providers.
class CycleSnapshot {
  const CycleSnapshot({
    required this.referenceDate,
    required this.completedCycles,
    required this.insightsMode,
    required this.classification,
    required this.sample,
    this.mean,
    this.mad,
    this.cycleDay,
    this.periodDuration,
    this.effectiveCycleLength,
    this.ranges,
    this.todayPhase,
    this.phaseConfidence,
    this.ovulatoryUncertaintyDays,
  });

  final DateTime referenceDate;
  final int completedCycles;
  final InsightsMode insightsMode;
  final CycleClassification classification;
  final List<int> sample;
  final double? mean;
  final double? mad;
  final int? cycleDay;
  final int? periodDuration;
  final int? effectiveCycleLength;
  final PhaseRanges? ranges;
  final CyclePhase? todayPhase;
  final PhaseConfidence? phaseConfidence;
  final int? ovulatoryUncertaintyDays;

  bool get showsPhaseEstimates =>
      insightsMode == InsightsMode.full &&
      classification != CycleClassification.unpredictable &&
      ranges != null &&
      ranges!.tier != PhaseTier.irregular;
}

/// Computes full cycle state for [referenceDate] from logged episodes.
///
/// [episodes] may be in any order; only completed cycles (consecutive starts)
/// contribute to classification. The current open cycle uses estimated [C].
CycleSnapshot computeCycleSnapshot({
  required DateTime referenceDate,
  required List<PeriodEpisode> episodes,
}) {
  if (episodes.isEmpty) {
    return CycleSnapshot(
      referenceDate: referenceDate,
      completedCycles: 0,
      insightsMode: InsightsMode.partial,
      classification: CycleClassification.unclassified,
      sample: const [],
    );
  }

  final sorted = sortEpisodesNewestFirst(episodes);
  final lengths = cycleLengthsFromEpisodes(episodes);
  final completed = lengths.length;
  final insightsMode = insightsModeForCompletedCycles(completed);
  final classificationResult = classifyCycleLengths(lengths);

  final cycleDay = cycleDayForDate(
    date: referenceDate,
    episodesNewestFirst: sorted,
  );
  final active = activeEpisodeForDate(
    date: referenceDate,
    episodesNewestFirst: sorted,
  );

  final onBleed = isBleedDay(
    date: referenceDate,
    episodes: episodes,
    referenceDate: referenceDate,
  );

  if (onBleed) {
    return CycleSnapshot(
      referenceDate: referenceDate,
      completedCycles: completed,
      insightsMode: insightsMode,
      classification: classificationResult.classification,
      sample: classificationResult.sample,
      mean: classificationResult.mean,
      mad: classificationResult.mad,
      cycleDay: cycleDay,
      periodDuration: active?.periodDuration(throughDate: referenceDate),
      effectiveCycleLength: _effectiveCycleLength(classificationResult, lengths),
      todayPhase: CyclePhase.menstrual,
      phaseConfidence: PhaseConfidence.logged,
    );
  }

  if (insightsMode == InsightsMode.partial ||
      classificationResult.classification ==
          CycleClassification.unpredictable ||
      classificationResult.classification ==
          CycleClassification.unclassified ||
      active == null ||
      cycleDay == null) {
    return CycleSnapshot(
      referenceDate: referenceDate,
      completedCycles: completed,
      insightsMode: insightsMode,
      classification: classificationResult.classification,
      sample: classificationResult.sample,
      mean: classificationResult.mean,
      mad: classificationResult.mad,
      cycleDay: cycleDay,
      periodDuration: active?.periodDuration(throughDate: referenceDate),
    );
  }

  final p = active.periodDuration(throughDate: referenceDate);
  final c = _effectiveCycleLength(classificationResult, lengths);
  if (c == null) {
    return CycleSnapshot(
      referenceDate: referenceDate,
      completedCycles: completed,
      insightsMode: insightsMode,
      classification: classificationResult.classification,
      sample: classificationResult.sample,
      mean: classificationResult.mean,
      mad: classificationResult.mad,
      cycleDay: cycleDay,
      periodDuration: p,
    );
  }

  final ranges = computePhaseRanges(periodDuration: p, cycleLength: c);
  final confidence = classificationResult.classification ==
          CycleClassification.variable
      ? PhaseConfidence.estimated
      : PhaseConfidence.exact;

  int? uncertainty;
  if (classificationResult.classification == CycleClassification.variable) {
    uncertainty = ovulatoryUncertaintyWidth(lengths);
  }

  return CycleSnapshot(
    referenceDate: referenceDate,
    completedCycles: completed,
    insightsMode: insightsMode,
    classification: classificationResult.classification,
    sample: classificationResult.sample,
    mean: classificationResult.mean,
    mad: classificationResult.mad,
    cycleDay: cycleDay,
    periodDuration: p,
    effectiveCycleLength: c,
    ranges: ranges,
    todayPhase: ranges.phaseForDay(cycleDay),
    phaseConfidence: confidence,
    ovulatoryUncertaintyDays: uncertainty,
  );
}

int? _effectiveCycleLength(
  ClassificationResult result,
  List<int> cycleLengthsOldestFirst,
) {
  return switch (result.classification) {
    CycleClassification.regular => result.mean!.round(),
    CycleClassification.variable =>
      variableCycleLengthMidpoint(cycleLengthsOldestFirst),
    _ => null,
  };
}
