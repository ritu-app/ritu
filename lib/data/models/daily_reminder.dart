/// Persisted daily log reminder preference.
class DailyReminder {
  const DailyReminder({
    required this.enabled,
    required this.hour,
    required this.minute,
  });

  static const prefsEnabledKey = 'daily_reminder_enabled';
  static const prefsHourKey = 'daily_reminder_hour';
  static const prefsMinuteKey = 'daily_reminder_minute';

  /// Off until the user opts in (onboarding or Settings).
  static const defaults = DailyReminder(enabled: false, hour: 8, minute: 0);

  /// Placeholder copy for the notification body. Update freely later.
  static const sampleMessage =
      'Time to check in with yourself. Open Ritu to log how you’re feeling today.';

  final bool enabled;
  final int hour;
  final int minute;

  String get timeLabel {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final m = minute.toString().padLeft(2, '0');
    final period = hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  /// Settings row subtitle: time when on, otherwise Off.
  String get settingsSubtitle => enabled ? timeLabel : 'Off';

  DailyReminder copyWith({bool? enabled, int? hour, int? minute}) {
    return DailyReminder(
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }
}
