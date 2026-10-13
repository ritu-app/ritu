import '../../core/cycle/cycle_classification.dart';

/// Copy for the green "Cycle length is consistent" insight card.
class ConsistentCycleCopy {
  const ConsistentCycleCopy({required this.body, required this.average});

  /// e.g. "Last 3 cycles: 27, 28, 27 days. Healthy stable variation"
  final String body;

  /// e.g. "Average 27.3 days"
  final String average;
}

/// Shown once classification is Regular, which requires at least three
/// completed cycles. [cycleLengths] is oldest-first; only the three most
/// recent lengths are described, and the average is theirs.
ConsistentCycleCopy? consistentCycleCopy({
  required CycleClassification classification,
  required List<int> cycleLengths,
}) {
  if (classification != CycleClassification.regular) return null;
  if (cycleLengths.length < 3) return null;

  final recent = cycleLengths.sublist(cycleLengths.length - 3);
  final mean = recent.reduce((a, b) => a + b) / recent.length;
  return ConsistentCycleCopy(
    body: 'Last 3 cycles: ${recent.join(', ')} days. Healthy stable variation',
    average: 'Average ${mean.toStringAsFixed(1)} days',
  );
}
