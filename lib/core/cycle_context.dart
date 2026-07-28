import '../data/models/period_log.dart';
import 'date_format.dart';

/// e.g. June 18
String formatJournalEntryModalTitle(DateTime date) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${months[date.month - 1]} ${date.day}';
}

/// e.g. 2026 • Day 20
String formatJournalEntryContextLine(
  DateTime entryDate,
  List<PeriodLog> periods,
) {
  final day = dateOnly(entryDate);
  PeriodLog? applicable;
  for (final period in periods) {
    final start = dateOnly(period.startedOn);
    if (start.isAfter(day)) continue;
    if (applicable == null ||
        start.isAfter(dateOnly(applicable.startedOn))) {
      applicable = period;
    }
  }

  if (applicable == null) return '${day.year}';

  final cycleDay =
      day.difference(dateOnly(applicable.startedOn)).inDays + 1;
  return '${day.year} • Day $cycleDay';
}
