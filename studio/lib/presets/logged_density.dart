/// How many past days (not including today) get a daily-log check-in.
enum DailyLogDensity {
  none(0, 'None'),
  sparse(3, 'Sparse'),
  full(14, 'Full');

  const DailyLogDensity(this.days, this.label);

  final int days;
  final String label;
}

/// How journal entries are spread across logged history.
enum JournalDensity {
  off(0, false, 'Off'),
  occasional(3, false, 'Occasional'),
  daily(13, true, 'Daily');

  const JournalDensity(this.pastCount, this.includesToday, this.label);

  /// Entries on days before simulated today.
  final int pastCount;

  /// Whether simulated today also has an entry.
  final bool includesToday;

  final String label;
}
