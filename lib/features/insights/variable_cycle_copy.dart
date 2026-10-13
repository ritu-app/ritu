import '../../core/cycle/cycle_classification.dart';

/// Copy for the Overview "Cycle length varies" card.
class VariableCycleCopy {
  const VariableCycleCopy({required this.title, required this.recorded});

  /// e.g. "Cycle length varies - 24 to 33 days"
  final String title;

  /// e.g. "3 cycles recorded"
  final String recorded;
}

/// Shown once classification is Variable. [cycleLengths] is the rolling
/// sample used for classification; the range is its shortest and longest.
VariableCycleCopy? variableCycleCopy({
  required CycleClassification classification,
  required List<int> cycleLengths,
}) {
  if (classification != CycleClassification.variable) return null;
  if (cycleLengths.isEmpty) return null;

  final shortest = cycleLengths.reduce((a, b) => a < b ? a : b);
  final longest = cycleLengths.reduce((a, b) => a > b ? a : b);
  final count = cycleLengths.length;
  final unit = count == 1 ? 'cycle' : 'cycles';
  return VariableCycleCopy(
    title: 'Cycle length varies - $shortest to $longest days',
    recorded: '$count $unit recorded',
  );
}
