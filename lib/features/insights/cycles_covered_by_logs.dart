import '../../core/date_format.dart';

/// How many period cycles contain at least one daily log.
///
/// A cycle starts on a period start and runs until the next start. The
/// newest cycle stays open. Logs dated before the first start do not count.
int cyclesCoveredByLogs({
  required Iterable<DateTime> logDates,
  required Iterable<DateTime> periodStarts,
}) {
  final starts = periodStarts.map(dateOnly).toSet().toList()..sort();
  if (starts.isEmpty) return 0;

  final covered = <DateTime>{};
  for (final raw in logDates) {
    final day = dateOnly(raw);
    if (day.isBefore(starts.first)) continue;

    var owner = starts.first;
    for (final start in starts) {
      if (start.isAfter(day)) break;
      owner = start;
    }
    covered.add(owner);
  }
  return covered.length;
}
