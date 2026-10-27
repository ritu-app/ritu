import 'cycle_classification.dart';

/// Whether a Regular or Variable cycle has run past the length we can phase.
///
/// Regular compares against the personal average. Variable compares against
/// the longest cycle in the classification sample, so a day still inside her
/// recorded range keeps its phase. Past that point the next period has not
/// arrived and the phase is no longer known.
bool isCycleLongerThanUsual({
  required CycleClassification classification,
  required int cycleDay,
  required int? effectiveCycleLength,
  required List<int> sampleCycleLengths,
}) {
  final limit = _limit(
    classification: classification,
    effectiveCycleLength: effectiveCycleLength,
    sampleCycleLengths: sampleCycleLengths,
  );
  if (limit == null) return false;
  return cycleDay > limit;
}

/// Length shown as "Usually N days" — the personal average, or the Variable
/// midpoint when there is no single average.
int? usualCycleLengthDays({required int? effectiveCycleLength}) {
  if (effectiveCycleLength == null || effectiveCycleLength < 1) return null;
  return effectiveCycleLength;
}

String usualCycleLengthLabel(int days) {
  final unit = days == 1 ? 'day' : 'days';
  return 'Usually $days $unit';
}

int? _limit({
  required CycleClassification classification,
  required int? effectiveCycleLength,
  required List<int> sampleCycleLengths,
}) {
  switch (classification) {
    case CycleClassification.regular:
      if (effectiveCycleLength == null || effectiveCycleLength < 1) {
        return null;
      }
      return effectiveCycleLength;
    case CycleClassification.variable:
      if (sampleCycleLengths.isEmpty) return null;
      var longest = sampleCycleLengths.first;
      for (final length in sampleCycleLengths) {
        if (length > longest) longest = length;
      }
      if (longest < 1) return null;
      return longest;
    case CycleClassification.unpredictable:
    case CycleClassification.unclassified:
      return null;
  }
}
