import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ritu/core/cycle/cycle_classification.dart';
import 'package:ritu/providers/cycle_snapshot_provider.dart';
import 'package:ritu/theme/ritu_colors.dart';

import '../presets/studio_scenario.dart';
import '../scope/studio_scope.dart';
import '../theme/studio_styles.dart';
import '../util/download_text_file.dart';
import 'studio_widgets.dart';

class StudioScenarioList extends StatelessWidget {
  const StudioScenarioList({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final StudioScenario selected;
  final ValueChanged<StudioScenario> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final scenario in StudioScenario.values) ...[
          if (scenario != StudioScenario.values.first)
            const SizedBox(height: 8),
          _ScenarioOption(
            label: scenario.label,
            selected: scenario == selected,
            onTap: () => onSelected(scenario),
          ),
        ],
      ],
    );
  }
}

class _ScenarioOption extends StatelessWidget {
  const _ScenarioOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: RituColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected ? studioMeadow500 : RituColors.fillMuted,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text(
                label,
                style: selected ? StudioText.fieldValue : StudioText.option,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ExportScenarioActions extends ConsumerWidget {
  const ExportScenarioActions({
    super.key,
    required this.onExport,
    required this.completedCycles,
    required this.loggedDays,
    required this.scenarioLabel,
    required this.dailyLogLabel,
    required this.journalLabel,
    required this.loggedToday,
  });

  final VoidCallback onExport;
  final int completedCycles;
  final int loggedDays;
  final String scenarioLabel;
  final String dailyLogLabel;
  final String journalLabel;
  final bool loggedToday;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insights = ref
        .watch(cycleSnapshotProvider)
        .maybeWhen(
          data: (snapshot) => snapshot.insightsMode == InsightsMode.full
              ? 'Enabled'
              : 'Partial',
          orElse: () => '—',
        );
    final lines = [
      _countLabel(completedCycles, 'completed cycle', 'completed cycles'),
      _countLabel(loggedDays, 'logged day', 'logged days'),
      scenarioLabel,
      'Daily logs: $dailyLogLabel',
      'Journal entries: $journalLabel',
      "Today's check-in: ${loggedToday ? 'Logged' : 'Not logged'}",
      'Insights: $insights',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: 1, thickness: 1, color: RituColors.borderSubtle),
        const SizedBox(height: 16),
        Text('Scenario includes', style: StudioText.option),
        for (final line in lines) _IncludeLine(line),
        const SizedBox(height: 16),
        const Divider(height: 1, thickness: 1, color: RituColors.borderSubtle),
        const SizedBox(height: 16),
        StudioPillButton(
          icon: LucideIcons.download,
          label: 'Export',
          expand: true,
          onPressed: onExport,
        ),
        const SizedBox(height: 4),
        Text(
          'Go to Ritu app → Settings → Export/Import Data → Import data from file',
          textAlign: TextAlign.center,
          style: StudioText.hint,
        ),
      ],
    );
  }
}

String _countLabel(int count, String singular, String plural) {
  return '$count ${count == 1 ? singular : plural}';
}

class _IncludeLine extends StatelessWidget {
  const _IncludeLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('•', style: StudioText.caption),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: StudioText.caption)),
        ],
      ),
    );
  }
}

class ResetScenarioButton extends StatelessWidget {
  const ResetScenarioButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                LucideIcons.rotateCcw,
                size: 20,
                color: RituColors.sage500,
              ),
              const SizedBox(width: 8),
              Text('Reset scenario', style: StudioText.reset),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> exportStudioBackup(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  final controller = context.studioController;
  try {
    final json = await controller.exportBackupJson();
    if (!context.mounted) return;
    final stamp = DateTime.now().toIso8601String().split('T').first;
    downloadTextFile(filename: 'ritu-studio-$stamp.json', contents: json);
    messenger.showSnackBar(const SnackBar(content: Text('Backup downloaded')));
  } catch (error) {
    messenger.showSnackBar(SnackBar(content: Text('Export failed: $error')));
  }
}
