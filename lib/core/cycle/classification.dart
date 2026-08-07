import 'cycle_classification.dart';
import 'cycle_sample.dart';

/// Result of the MAD-based classification pipeline.
class ClassificationResult {
  const ClassificationResult({
    required this.classification,
    required this.sample,
    this.mean,
    this.mad,
  });

  final CycleClassification classification;
  final List<int> sample;
  final double? mean;
  final double? mad;

  bool get isClassified =>
      classification != CycleClassification.unclassified;
}

/// Classifies cycle regularity from completed cycle lengths (oldest-first).
///
/// See [docs/cycle-classification-spec.html].
ClassificationResult classifyCycleLengths(
  List<int> cycleLengthsOldestFirst,
) {
  final sample = selectCycleSample(cycleLengthsOldestFirst);
  if (sample.isEmpty) {
    return const ClassificationResult(
      classification: CycleClassification.unclassified,
      sample: [],
    );
  }

  final mean = sample.reduce((a, b) => a + b) / sample.length;
  final deviations = sample.map((length) => (length - mean).abs()).toList();
  final mad = deviations.reduce((a, b) => a + b) / deviations.length;

  return ClassificationResult(
    classification: _classificationForMad(mad),
    sample: sample,
    mean: mean,
    mad: mad,
  );
}

CycleClassification _classificationForMad(double mad) {
  if (mad <= 4) return CycleClassification.regular;
  if (mad <= 9) return CycleClassification.variable;
  return CycleClassification.unpredictable;
}

/// Insights mode from completed cycle count (product rule + classification spec).
InsightsMode insightsModeForCompletedCycles(int completedCycles) {
  return completedCycles >= 3 ? InsightsMode.full : InsightsMode.partial;
}
