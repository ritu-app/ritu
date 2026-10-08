import 'package:flutter/material.dart';
import 'package:ritu/core/home_greeting.dart';
import 'package:ritu/theme/ritu_colors.dart';

import '../models/cycle_history_draft.dart';
import '../presets/logged_density.dart';
import '../presets/studio_scenario.dart';
import '../theme/studio_styles.dart';
import '../util/studio_labels.dart';
import 'control_panel.dart';
import 'cycle_history_editor.dart';
import 'date_time_section.dart';
import 'logged_data_section.dart';
import 'studio_disclosure.dart';

enum ConsoleSection { dateTime, scenario, history, logged, export }

class ConsoleColumn extends StatelessWidget {
  const ConsoleColumn({
    super.key,
    required this.expanded,
    required this.onToggle,
    required this.date,
    required this.window,
    required this.historyDraft,
    required this.onDate,
    required this.onWindow,
    required this.onCycleDay,
    required this.onCycleDayCommit,
    required this.scenario,
    required this.onScenario,
    required this.onHistoryDraftChanged,
    required this.logDensity,
    required this.journalDensity,
    required this.loggedToday,
    required this.onLogDensity,
    required this.onJournalDensity,
    required this.onLoggedToday,
    required this.onRegenerate,
    required this.onExport,
    required this.onReset,
  });

  final ConsoleSection? expanded;
  final ValueChanged<ConsoleSection> onToggle;
  final DateTime date;
  final GreetingTimeWindow window;
  final CycleHistoryDraft historyDraft;
  final ValueChanged<DateTime> onDate;
  final ValueChanged<GreetingTimeWindow> onWindow;
  final ValueChanged<int> onCycleDay;
  final ValueChanged<int> onCycleDayCommit;
  final StudioScenario scenario;
  final ValueChanged<StudioScenario> onScenario;
  final ValueChanged<CycleHistoryDraft> onHistoryDraftChanged;
  final DailyLogDensity logDensity;
  final JournalDensity journalDensity;
  final bool loggedToday;
  final ValueChanged<DailyLogDensity> onLogDensity;
  final ValueChanged<JournalDensity> onJournalDensity;
  final ValueChanged<bool> onLoggedToday;
  final VoidCallback onRegenerate;
  final VoidCallback onExport;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Intro(
          label: 'How this works',
          body:
              'Change the data and watch the experience evolve. Pick a scenario below, then tune it in the console.',
        ),
        StudioDisclosure(
          title: 'Simulated date & time',
          summary: simulatedDateSummary(date, window),
          expanded: expanded == ConsoleSection.dateTime,
          onToggle: () => onToggle(ConsoleSection.dateTime),
          body: DateTimeSection(
            date: date,
            window: window,
            cycleDay: historyDraft.currentCycleDay,
            maxCycleDay: scenario.maxCycleDay,
            onDate: onDate,
            onWindow: onWindow,
            onCycleDay: onCycleDay,
            onCycleDayCommit: onCycleDayCommit,
          ),
        ),
        const SizedBox(height: 12),
        StudioDisclosure(
          title: 'Scenario preset',
          summary: scenario.label,
          expanded: expanded == ConsoleSection.scenario,
          onToggle: () => onToggle(ConsoleSection.scenario),
          body: StudioScenarioList(selected: scenario, onSelected: onScenario),
        ),
        const SizedBox(height: 12),
        StudioDisclosure(
          title: 'Cycle history',
          summary: cycleHistorySummary(historyDraft),
          expandedSubtitle: 'Newest → Oldest. Tap a start date to adjust.',
          expanded: expanded == ConsoleSection.history,
          onToggle: () => onToggle(ConsoleSection.history),
          body: CycleHistoryEditor(
            draft: historyDraft,
            simulatedToday: date,
            onDraftChanged: onHistoryDraftChanged,
          ),
        ),
        const SizedBox(height: 12),
        StudioDisclosure(
          title: 'Logged data',
          summary: loggedDataSummary(logs: logDensity, journal: journalDensity),
          expandedSubtitle:
              'Simulate today\'s mood check-in as already complete, to preview the Home card after logging.',
          expanded: expanded == ConsoleSection.logged,
          onToggle: () => onToggle(ConsoleSection.logged),
          body: LoggedDataSection(
            logDensity: logDensity,
            journalDensity: journalDensity,
            loggedToday: loggedToday,
            onLogDensity: onLogDensity,
            onJournalDensity: onJournalDensity,
            onLoggedToday: onLoggedToday,
            onRegenerate: onRegenerate,
          ),
        ),
        const SizedBox(height: 12),
        StudioDisclosure(
          title: 'Export scenario',
          summary: 'Download JSON for the Ritu app',
          expandedSubtitle:
              'Download this scenario as JSON and import it into Ritu to experience it in the app.',
          expanded: expanded == ConsoleSection.export,
          onToggle: () => onToggle(ConsoleSection.export),
          body: ExportScenarioActions(
            onExport: onExport,
            completedCycles: historyDraft.rows.isEmpty
                ? 0
                : historyDraft.rows.length - 1,
            loggedDays: logDensity.days + (loggedToday ? 1 : 0),
            scenarioLabel: scenario.label,
            dailyLogLabel: logDensity.label,
            journalLabel: journalDensity.label,
            loggedToday: loggedToday,
          ),
        ),
        const SizedBox(height: 8),
        ResetScenarioButton(onPressed: onReset),
      ],
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.label, required this.body});

  final String label;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: StudioText.sectionLabel),
        Text(body, style: StudioText.sectionBody),
        const SizedBox(height: 16),
        const Divider(height: 1, thickness: 1, color: RituColors.borderSubtle),
        const SizedBox(height: 16),
      ],
    );
  }
}
