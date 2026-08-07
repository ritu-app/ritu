import 'package:flutter/material.dart';
import 'package:ritu/core/date_format.dart';

import '../models/cycle_history_draft.dart';
import '../presets/cycle_presets.dart';
import '../scope/studio_scope.dart';
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
  });

  final CycleHistoryDraft historyDraft;
  final ValueChanged<CycleHistoryDraft> onHistoryDraftChanged;
  final int loggedDaysCount;
  final bool loggedToday;
  final ValueChanged<int> onLoggedDaysChanged;
  final ValueChanged<bool> onLoggedTodayChanged;

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
      ],
    );
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
