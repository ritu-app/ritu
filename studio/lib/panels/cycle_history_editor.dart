import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/cycle_history_draft.dart';
import '../presets/cycle_presets.dart';
import 'control_panel.dart';

class CycleHistoryEditor extends StatelessWidget {
  const CycleHistoryEditor({
    super.key,
    required this.draft,
    required this.simulatedToday,
    required this.onDraftChanged,
    required this.onApply,
  });

  final CycleHistoryDraft draft;
  final DateTime simulatedToday;
  final ValueChanged<CycleHistoryDraft> onDraftChanged;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final starts = draft.computedStarts(simulatedToday);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cycle history editor', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Text(
          'Oldest → newest. Start dates derive from simulated today and cycle day.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _NumberField(
                label: 'Current cycle day',
                value: draft.currentCycleDay,
                min: 1,
                max: 60,
                onChanged: (value) {
                  onDraftChanged(draft.copyWith(currentCycleDay: value));
                },
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () => onDraftChanged(draft.addOldestRow()),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add cycle'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: draft.rows.length,
          onReorderItem: (oldIndex, newIndex) {
            onDraftChanged(draft.reorderRows(oldIndex, newIndex));
          },
          itemBuilder: (context, index) {
            final row = draft.rows[index];
            final start = starts[index];
            return _HistoryRowTile(
              key: ValueKey('history-row-$index-${start.toIso8601String()}'),
              index: index,
              row: row,
              startDate: start,
              isOldest: index == 0,
              onChanged: (updated) {
                final rows = draft.rows.toList(growable: true);
                rows[index] = updated;
                onDraftChanged(draft.copyWith(rows: rows));
              },
              onRemove: index == 0 && draft.rows.length > 1
                  ? () => onDraftChanged(draft.removeOldestRow())
                  : null,
            );
          },
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: onApply,
          child: const Text('Apply history'),
        ),
      ],
    );
  }
}

class _HistoryRowTile extends StatelessWidget {
  const _HistoryRowTile({
    super.key,
    required this.index,
    required this.row,
    required this.startDate,
    required this.isOldest,
    required this.onChanged,
    this.onRemove,
  });

  final int index;
  final CycleHistoryRow row;
  final DateTime startDate;
  final bool isOldest;
  final ValueChanged<CycleHistoryRow> onChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ReorderableDragStartListener(
                  index: index,
                  child: Icon(
                    Icons.drag_handle,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isOldest ? 'Oldest' : 'Cycle ${index + 1}',
                  style: theme.textTheme.labelLarge,
                ),
                const Spacer(),
                if (onRemove != null)
                  IconButton(
                    tooltip: 'Remove oldest',
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_outline, size: 20),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Start: ${formatDisplayDate(startDate)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (!isOldest)
                  Expanded(
                    child: _NumberField(
                      label: 'Length (days)',
                      value: row.cycleLength ?? CyclePreset.defaultCycleLength,
                      min: 1,
                      max: 90,
                      onChanged: (value) {
                        onChanged(row.copyWith(cycleLength: value));
                      },
                    ),
                  ),
                if (!isOldest) const SizedBox(width: 12),
                Expanded(
                  child: _NumberField(
                    label: 'Period P',
                    value: row.periodDuration,
                    min: 1,
                    max: 10,
                    onChanged: (value) {
                      onChanged(row.copyWith(periodDuration: value));
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey('$label-$value'),
      initialValue: '$value',
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (text) {
        final parsed = int.tryParse(text);
        if (parsed == null) return;
        onChanged(parsed.clamp(min, max));
      },
    );
  }
}

class DailyLogControls extends StatelessWidget {
  const DailyLogControls({
    super.key,
    required this.loggedDaysCount,
    required this.loggedToday,
    required this.onLoggedDaysChanged,
    required this.onLoggedTodayChanged,
  });

  final int loggedDaysCount;
  final bool loggedToday;
  final ValueChanged<int> onLoggedDaysChanged;
  final ValueChanged<bool> onLoggedTodayChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Daily logs', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Text(
          'Orthogonal to cycle insights — drives Home / Insights progress UI.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Text('Logged days: $loggedDaysCount'),
        Slider(
          value: loggedDaysCount.toDouble(),
          min: 0,
          max: 14,
          divisions: 14,
          label: '$loggedDaysCount',
          onChanged: (value) => onLoggedDaysChanged(value.round()),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Logged today'),
          value: loggedToday,
          onChanged: onLoggedTodayChanged,
        ),
      ],
    );
  }
}
