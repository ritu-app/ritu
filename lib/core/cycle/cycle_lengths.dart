import '../date_format.dart';

/// Days between consecutive period starts (oldest → newest order).
///
/// Requires at least two start dates. Each length is
/// `laterStart - earlierStart` in whole calendar days.
List<int> cycleLengthsFromStarts(List<DateTime> periodStartsOldestFirst) {
  if (periodStartsOldestFirst.length < 2) return const [];

  final normalized = periodStartsOldestFirst.map(dateOnly).toList();
  final lengths = <int>[];
  for (var i = 1; i < normalized.length; i++) {
    lengths.add(normalized[i].difference(normalized[i - 1]).inDays);
  }
  return lengths;
}

/// Period start dates sorted oldest-first from an arbitrary list.
List<DateTime> sortPeriodStartsOldestFirst(Iterable<DateTime> starts) {
  final sorted = starts.map(dateOnly).toList()..sort();
  return sorted;
}

/// Number of completed cycles (= number of cycle lengths derivable).
int completedCycleCount(List<DateTime> periodStarts) {
  return cycleLengthsFromStarts(
    sortPeriodStartsOldestFirst(periodStarts),
  ).length;
}
