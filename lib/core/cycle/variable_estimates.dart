import 'cycle_sample.dart';

/// Midpoint of shortest and longest cycle in the sample, rounded half up.
///
/// See [docs/cycle-phase-range-spec.html] §6.2–6.3.
int variableCycleLengthMidpoint(List<int> cycleLengthsOldestFirst) {
  final sample = selectCycleSample(cycleLengthsOldestFirst);
  if (sample.isEmpty) {
    throw ArgumentError('At least 3 completed cycles required');
  }

  final shortest = sample.reduce((a, b) => a < b ? a : b);
  final longest = sample.reduce((a, b) => a > b ? a : b);
  return ((shortest + longest) / 2).round();
}

/// Ovulatory uncertainty window width for Variable users (Method 2).
///
/// Substitutes shortest and longest [C] into ovulatory expressions only.
/// Returns `latestPossibleEnd - earliestPossibleStart` in days.
int ovulatoryUncertaintyWidth(List<int> cycleLengthsOldestFirst) {
  final sample = selectCycleSample(cycleLengthsOldestFirst);
  if (sample.isEmpty) {
    throw ArgumentError('At least 3 completed cycles required');
  }

  final shortest = sample.reduce((a, b) => a < b ? a : b);
  final longest = sample.reduce((a, b) => a > b ? a : b);

  final earliestStart = shortest - 16;
  final latestEnd = longest - 14;
  return latestEnd - earliestStart;
}
