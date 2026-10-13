import '../../core/cycle/cycle_classification.dart';

/// Copy for the unpredictable Overview variation card and the shared
/// "How insights work for you" note.
class UnpredictableCycleCopy {
  const UnpredictableCycleCopy({
    required this.howInsightsBody,
    required this.title,
    required this.recorded,
  });

  /// e.g. "Your cycles vary quite a bit (21–46 days). ..."
  final String howInsightsBody;

  /// e.g. "Cycles vary significantly - 21 to 46 days"
  final String title;

  /// e.g. "3 cycles recorded"
  final String recorded;
}

/// Shown once classification is Unpredictable. [cycleLengths] is the rolling
/// sample used for classification; the range is its shortest and longest.
UnpredictableCycleCopy? unpredictableCycleCopy({
  required CycleClassification classification,
  required List<int> cycleLengths,
}) {
  if (classification != CycleClassification.unpredictable) return null;
  if (cycleLengths.isEmpty) return null;

  final shortest = cycleLengths.reduce((a, b) => a < b ? a : b);
  final longest = cycleLengths.reduce((a, b) => a > b ? a : b);
  final count = cycleLengths.length;
  final unit = count == 1 ? 'cycle' : 'cycles';
  return UnpredictableCycleCopy(
    howInsightsBody:
        'Your cycles vary quite a bit ($shortest–$longest days). '
        "Phase strips aren't shown. Patterns here are based on what "
        "you've logged, not cycle timing.",
    title: 'Cycles vary significantly - $shortest to $longest days',
    recorded: '$count $unit recorded',
  );
}
