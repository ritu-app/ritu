import '../data/models/period_log.dart';
import 'cycle/cycle_adapters.dart';
import 'cycle/cycle_day.dart';
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
  final cycleDay = cycleDayForDate(
    date: entryDate,
    episodesNewestFirst: episodesFromPeriodLogs(periods),
  );

  if (cycleDay == null) return '${dateOnly(entryDate).year}';

  return '${dateOnly(entryDate).year} • Day $cycleDay';
}
