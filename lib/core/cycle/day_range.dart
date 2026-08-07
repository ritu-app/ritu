/// Inclusive calendar-day range within a cycle (1-based cycle day indices).
class DayRange {
  const DayRange({required this.start, required this.end})
      : assert(start >= 1),
        assert(end >= start);

  final int start;
  final int end;

  int get length => end - start + 1;

  bool contains(int cycleDay) => cycleDay >= start && cycleDay <= end;

  @override
  bool operator ==(Object other) =>
      other is DayRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'DayRange($start–$end)';
}
