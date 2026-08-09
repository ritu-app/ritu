import 'package:flutter/material.dart';
import 'package:ritu/core/date_format.dart';
import 'package:ritu/core/home_greeting.dart';

import '../models/cycle_history_draft.dart';
import '../presets/cycle_presets.dart';
import '../presets/journal_controls.dart';
import '../scope/studio_scope.dart';
import '../util/download_text_file.dart';
import 'cycle_history_editor.dart';

class ControlPanel extends StatelessWidget {
  const ControlPanel({
    super.key,
    required this.historyDraft,
    required this.onHistoryDraftChanged,
    required this.loggedDaysCount,
    required this.loggedToday,
    required this.onLoggedDaysChanged,
    required this.onLoggedTodayChanged,
    required this.journalTodayBody,
    required this.pastJournalCount,
    required this.onJournalTodayBodyChanged,
    required this.onPastJournalCountChanged,
  });

  final CycleHistoryDraft historyDraft;
  final ValueChanged<CycleHistoryDraft> onHistoryDraftChanged;
  final int loggedDaysCount;
  final bool loggedToday;
  final ValueChanged<int> onLoggedDaysChanged;
  final ValueChanged<bool> onLoggedTodayChanged;
  final String journalTodayBody;
  final int pastJournalCount;
  final ValueChanged<String> onJournalTodayBodyChanged;
  final ValueChanged<int> onPastJournalCountChanged;

  @override
  Widget build(BuildContext context) {
    final controller = context.studioController;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Cycle Studio', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          'Live cycle data playground',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        Text('Simulated today', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _pickDate(context, controller),
          icon: const Icon(Icons.calendar_today_outlined, size: 18),
          label: Text(formatDisplayDate(controller.simulatedToday)),
        ),
        const SizedBox(height: 24),
        Text('Time of day', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        DropdownMenu<GreetingTimeWindow>(
          key: ValueKey(controller.simulatedClock),
          initialSelection: greetingTimeWindowFor(controller.simulatedClock),
          expandedInsets: EdgeInsets.zero,
          dropdownMenuEntries: const [
            DropdownMenuEntry(
              value: GreetingTimeWindow.morning,
              label: 'Morning (5:00–10:59)',
            ),
            DropdownMenuEntry(
              value: GreetingTimeWindow.afternoon,
              label: 'Afternoon (11:00–15:59)',
            ),
            DropdownMenuEntry(
              value: GreetingTimeWindow.evening,
              label: 'Evening (16:00–19:59)',
            ),
            DropdownMenuEntry(
              value: GreetingTimeWindow.night,
              label: 'Night (20:00–4:59)',
            ),
          ],
          onSelected: (window) {
            if (window == null) return;
            controller.setGreetingTimeWindow(window);
          },
        ),
        const SizedBox(height: 24),
        _PresetSelector(
          onHistoryDraftChanged: onHistoryDraftChanged,
        ),
        const SizedBox(height: 24),
        CycleHistoryEditor(
          draft: historyDraft,
          simulatedToday: controller.simulatedToday,
          onDraftChanged: onHistoryDraftChanged,
          onApply: () => controller.applyHistory(historyDraft),
          onLiveApply: controller.applyHistory,
        ),
        const SizedBox(height: 24),
        DailyLogControls(
          loggedDaysCount: loggedDaysCount,
          loggedToday: loggedToday,
          onLoggedDaysChanged: onLoggedDaysChanged,
          onLoggedTodayChanged: onLoggedTodayChanged,
        ),
        const SizedBox(height: 24),
        JournalControls(
          todayBody: journalTodayBody,
          pastEntryCount: pastJournalCount,
          onTodayBodyChanged: onJournalTodayBodyChanged,
          onPastEntryCountChanged: onPastJournalCountChanged,
        ),
        const SizedBox(height: 24),
        Text('Device backup', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Text(
          'Download a ritu.backup JSON to import on a phone via '
          'Settings → Export Data → Import from file. '
          'Keep simulated today on or before wall-clock today so period '
          'starts import cleanly.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => _exportBackup(context, controller),
          icon: const Icon(Icons.download_outlined, size: 18),
          label: const Text('Export JSON for device'),
        ),
      ],
    );
  }

  Future<void> _exportBackup(
    BuildContext context,
    StudioController controller,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final json = await controller.exportBackupJson();
      final stamp = DateTime.now().toIso8601String().split('T').first;
      downloadTextFile(
        filename: 'ritu-studio-$stamp.json',
        contents: json,
      );
      messenger.showSnackBar(
        const SnackBar(content: Text('Backup downloaded')),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Export failed: $error')),
      );
    }
  }

  Future<void> _pickDate(
    BuildContext context,
    StudioController controller,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.simulatedToday,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null || !context.mounted) return;
    controller.setSimulatedToday(dateOnly(picked));
  }
}

String formatDisplayDate(DateTime date) {
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

class _PresetSelector extends StatefulWidget {
  const _PresetSelector({required this.onHistoryDraftChanged});

  final ValueChanged<CycleHistoryDraft> onHistoryDraftChanged;

  @override
  State<_PresetSelector> createState() => _PresetSelectorState();
}

class _PresetSelectorState extends State<_PresetSelector> {
  CyclePreset _selected = CyclePreset.regular;

  Future<void> _applyPreset(CyclePreset preset) async {
    final controller = context.studioController;
    await controller.applyPreset(preset);
    widget.onHistoryDraftChanged(CycleHistoryDraft.fromPreset(preset));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Preset', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        DropdownMenu<CyclePreset>(
          key: ValueKey(_selected),
          initialSelection: _selected,
          expandedInsets: EdgeInsets.zero,
          dropdownMenuEntries: [
            for (final preset in CyclePreset.values)
              DropdownMenuEntry(value: preset, label: preset.label),
          ],
          onSelected: (preset) {
            if (preset == null) return;
            setState(() => _selected = preset);
            _applyPreset(preset);
          },
        ),
        const SizedBox(height: 10),
        Text(
          _selected.description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
