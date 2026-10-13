import '../../core/cycle/cycle_lengths.dart';
import '../../core/date_format.dart';

/// One row in the Overview cycle length record.
class CycleLengthRecordRow {
  const CycleLengthRecordRow({
    required this.span,
    required this.length,
    required this.inProgress,
  });

  /// e.g. "Jun → Jul 2026" or "Aug 2026 → ongoing"
  final String span;

  /// e.g. "21 days" or "In progress"
  final String length;

  final bool inProgress;
}

/// Completed cycles between period starts, oldest first, then the open cycle.
List<CycleLengthRecordRow> cycleLengthRecord({
  required Iterable<DateTime> periodStarts,
}) {
  final starts = sortPeriodStartsOldestFirst(periodStarts);
  if (starts.isEmpty) return const [];

  final rows = <CycleLengthRecordRow>[];
  for (var i = 1; i < starts.length; i++) {
    final days = starts[i].difference(starts[i - 1]).inDays;
    final unit = days == 1 ? 'day' : 'days';
    rows.add(
      CycleLengthRecordRow(
        span: _completedSpan(starts[i - 1], starts[i]),
        length: '$days $unit',
        inProgress: false,
      ),
    );
  }

  final latest = starts.last;
  rows.add(
    CycleLengthRecordRow(
      span: '${formatShortMonth(latest)} ${latest.year} → ongoing',
      length: 'In progress',
      inProgress: true,
    ),
  );
  return rows;
}

String _completedSpan(DateTime from, DateTime to) {
  final start = from.year == to.year
      ? formatShortMonth(from)
      : '${formatShortMonth(from)} ${from.year}';
  return '$start → ${formatShortMonth(to)} ${to.year}';
}
