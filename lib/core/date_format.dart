/// e.g. July 24, 2026
String formatDisplayDate(DateTime date) {
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
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

/// e.g. June 18 — full month name, no year (period history stats).
String formatMonthDay(DateTime date) {
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

const _shortMonths = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// e.g. Sep 17 — abbreviated month, no year (home status card).
String formatShortMonthDay(DateTime date) {
  return '${_shortMonths[date.month - 1]} ${date.day}';
}

/// Variable next-period range, e.g. `~Oct 9-15` or `~Oct 28-Nov 3`.
String formatEstimatedShortMonthDayRange(DateTime start, DateTime end) {
  final from = dateOnly(start);
  final to = dateOnly(end);
  if (isSameCalendarDay(from, to)) {
    return '~${formatShortMonthDay(from)}';
  }
  if (from.year == to.year && from.month == to.month) {
    return '~${_shortMonths[from.month - 1]} ${from.day}-${to.day}';
  }
  return '~${formatShortMonthDay(from)}-${formatShortMonthDay(to)}';
}

/// e.g. June 17 • 2026
String formatJournalEntryDate(DateTime date) {
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
  return '${months[date.month - 1]} ${date.day} • ${date.year}';
}

/// e.g. June 2026 — month section headers on All entries.
String formatMonthYear(DateTime date) {
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
  return '${months[date.month - 1]} ${date.year}';
}

/// Date-only (local calendar day).
DateTime dateOnly(DateTime date) =>
    DateTime(date.year, date.month, date.day);

bool isSameCalendarDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
