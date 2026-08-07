/// Rolling sample of cycle lengths used for classification and Variable [C].
///
/// Grows 3 → 4 → 5, then caps at the 6 most recent completed cycles.
/// Returns empty when fewer than 3 lengths exist.
List<int> selectCycleSample(List<int> cycleLengthsOldestFirst) {
  final count = cycleLengthsOldestFirst.length;
  if (count < 3) return const [];

  final take = count < 6 ? count : 6;
  return cycleLengthsOldestFirst.sublist(count - take);
}
