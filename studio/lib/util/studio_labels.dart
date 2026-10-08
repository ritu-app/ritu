import 'package:ritu/core/cycle/cycle_classification.dart';
import 'package:ritu/core/cycle/cycle_phase.dart';
import 'package:ritu/core/home_greeting.dart';

import '../models/cycle_history_draft.dart';
import '../presets/logged_density.dart';

/// e.g. Sep 25, 2026
String formatStudioShortDate(DateTime date) {
  const months = [
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
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

/// e.g. 30/8/2026
String formatStudioNumericDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}

/// e.g. 30/08/2026
String formatStudioPaddedDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

String greetingWindowShortLabel(GreetingTimeWindow window) {
  return switch (window) {
    GreetingTimeWindow.morning => 'Morning',
    GreetingTimeWindow.afternoon => 'Afternoon',
    GreetingTimeWindow.evening => 'Evening',
    GreetingTimeWindow.night => 'Night',
  };
}

String greetingWindowRangeLabel(GreetingTimeWindow window) {
  return switch (window) {
    GreetingTimeWindow.morning => 'Morning (5:00 AM – 10:59 AM)',
    GreetingTimeWindow.afternoon => 'Afternoon (11:00 AM – 3:59 PM)',
    GreetingTimeWindow.evening => 'Evening (4:00 PM – 7:59 PM)',
    GreetingTimeWindow.night => 'Night (8:00 PM – 4:59 AM)',
  };
}

String simulatedDateSummary(DateTime date, GreetingTimeWindow window) {
  return '${formatStudioShortDate(date)} · ${greetingWindowShortLabel(window)}';
}

String cycleHistorySummary(CycleHistoryDraft draft) {
  final count = draft.rows.isEmpty ? 0 : draft.rows.length - 1;
  return count == 1 ? '1 cycle' : '$count cycles';
}

String loggedDataSummary({
  required DailyLogDensity logs,
  required JournalDensity journal,
}) {
  return '${logs.label} · ${journal.label}';
}

String insightsAvailabilityLabel(InsightsMode mode) {
  return switch (mode) {
    InsightsMode.full => 'Available',
    InsightsMode.partial => 'Partial',
  };
}

String classificationLabel(CycleClassification classification) {
  final name = classification.name;
  return '${name[0].toUpperCase()}${name.substring(1)}';
}

String phaseLabel(CyclePhase? phase) {
  if (phase == null) return '—';
  final name = phase.name;
  return '${name[0].toUpperCase()}${name.substring(1)}';
}
