import '../../core/date_format.dart';

class PeriodSources {
  static const onboardingLast = 'onboarding_last';
  static const onboardingPast = 'onboarding_past';
  static const calendar = 'calendar';
  static const settings = 'settings';
  /// Backfilled from Period History (not logged in real time).
  static const manual = 'manual';

  /// True when the episode was recalled/backfilled rather than logged live.
  static bool isManual(String source) =>
      source == manual ||
      source == settings ||
      source == onboardingPast;
}

class PeriodLog {
  const PeriodLog({
    required this.id,
    required this.startedOn,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
    this.endedOn,
  });

  final int id;
  final DateTime startedOn;
  final DateTime? endedOn;
  final String source;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isManual => PeriodSources.isManual(source);

  /// Inclusive bleed days for calendar highlighting.
  Set<DateTime> get bleedDays {
    final start = dateOnly(startedOn);
    final end = endedOn == null ? start : dateOnly(endedOn!);
    if (end.isBefore(start)) return {start};

    final days = <DateTime>{};
    var cursor = start;
    while (!cursor.isAfter(end)) {
      days.add(cursor);
      cursor = cursor.add(const Duration(days: 1));
    }
    return days;
  }
}
