import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ritu/core/date_format.dart';
import 'package:ritu/theme/ritu_colors.dart';

import '../models/cycle_history_draft.dart';
import '../presets/cycle_presets.dart';
import '../theme/studio_styles.dart';
import '../util/studio_labels.dart';
import 'studio_widgets.dart';

class CycleHistoryEditor extends StatelessWidget {
  const CycleHistoryEditor({
    super.key,
    required this.draft,
    required this.simulatedToday,
    required this.onDraftChanged,
  });

  final CycleHistoryDraft draft;
  final DateTime simulatedToday;
  final ValueChanged<CycleHistoryDraft> onDraftChanged;

  @override
  Widget build(BuildContext context) {
    final starts = draft.computedStarts(simulatedToday);
    final count = draft.rows.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var display = 0; display < count; display++) ...[
          if (display > 0) const SizedBox(height: 16),
          _CycleCard(
            key: ValueKey(starts[count - 1 - display]),
            index: count - 1 - display,
            count: count,
            row: draft.rows[count - 1 - display],
            startDate: starts[count - 1 - display],
            showConnector: display < count - 1,
            onPickStartDate: () => _pickStartDate(
              context,
              count - 1 - display,
              starts[count - 1 - display],
            ),
            onLengthChanged: (value) => _updateRow(
              count - 1 - display,
              draft.rows[count - 1 - display].copyWith(cycleLength: value),
            ),
            onDurationChanged: (value) => _updateRow(
              count - 1 - display,
              draft.rows[count - 1 - display].copyWith(periodDuration: value),
            ),
            onRemove: () => onDraftChanged(
              draft.removeRow(count - 1 - display, simulatedToday),
            ),
          ),
        ],
        if (count > 0) const SizedBox(height: 16),
        StudioPillButton(
          icon: LucideIcons.plus,
          label: 'Add cycle',
          onPressed: () => onDraftChanged(draft.addOldestRow()),
        ),
      ],
    );
  }

  void _updateRow(int index, CycleHistoryRow row) {
    final rows = draft.rows.toList(growable: true);
    rows[index] = row;
    onDraftChanged(draft.copyWith(rows: rows));
  }

  Future<void> _pickStartDate(
    BuildContext context,
    int index,
    DateTime currentStart,
  ) async {
    final bounds = draft.startDateBounds(
      index: index,
      simulatedToday: simulatedToday,
    );
    if (bounds.firstDate.isAfter(bounds.lastDate)) return;

    final initialDate = currentStart.isBefore(bounds.firstDate)
        ? bounds.firstDate
        : currentStart.isAfter(bounds.lastDate)
        ? bounds.lastDate
        : currentStart;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: bounds.firstDate,
      lastDate: bounds.lastDate,
      helpText: 'Period start date',
    );
    if (picked == null || !context.mounted) return;

    onDraftChanged(
      draft.withRowStartDate(
        index: index,
        newStart: dateOnly(picked),
        simulatedToday: simulatedToday,
      ),
    );
  }
}

class _CycleCard extends StatelessWidget {
  const _CycleCard({
    super.key,
    required this.index,
    required this.count,
    required this.row,
    required this.startDate,
    required this.showConnector,
    required this.onPickStartDate,
    required this.onLengthChanged,
    required this.onDurationChanged,
    required this.onRemove,
  });

  final int index;
  final int count;
  final CycleHistoryRow row;
  final DateTime startDate;
  final bool showConnector;
  final VoidCallback onPickStartDate;
  final ValueChanged<int> onLengthChanged;
  final ValueChanged<int> onDurationChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TimelineMark(showConnector: showConnector),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _cycleTitle(index, count),
                        style: StudioText.cycleTitle,
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: 'Remove ${_cycleTitle(index, count)}',
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: onRemove,
                          child: const Icon(
                            LucideIcons.x,
                            size: 16,
                            color: RituColors.neutral600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _DateField(
                  value: formatStudioPaddedDate(startDate),
                  onTap: onPickStartDate,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _CountField(
                        label: 'Cycle Length',
                        value:
                            row.cycleLength ?? CyclePreset.defaultCycleLength,
                        min: 1,
                        max: 90,
                        onChanged: onLengthChanged,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _CountField(
                        label: 'Menstrual days',
                        value: row.periodDuration,
                        min: 1,
                        max: 10,
                        onChanged: onDurationChanged,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _cycleTitle(int index, int count) {
  final number = index + 1;
  final newest = index == count - 1;
  final oldest = index == 0;
  if (newest && oldest) return 'Cycle 1 (Current cycle)';
  if (newest) return 'Cycle $number (Current cycle)';
  if (oldest) return 'Cycle $number (Oldest)';
  return 'Cycle $number';
}

class _TimelineMark extends StatelessWidget {
  const _TimelineMark({required this.showConnector});

  final bool showConnector;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 12,
      child: Column(
        children: [
          const SizedBox(height: 6),
          const DecoratedBox(
            decoration: BoxDecoration(
              color: RituColors.meadow600,
              shape: BoxShape.circle,
            ),
            child: SizedBox(width: 8, height: 8),
          ),
          if (showConnector)
            const Expanded(
              child: Center(
                child: SizedBox(
                  width: 1,
                  child: ColoredBox(color: RituColors.fillMuted),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.value, required this.onTap});

  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: RituColors.fillMuted),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(child: Text(value, style: StudioText.fieldValue)),
                const Icon(LucideIcons.calendar1, size: 20, color: studioIcon),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CountField extends StatefulWidget {
  const _CountField({
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
  State<_CountField> createState() => _CountFieldState();
}

class _CountFieldState extends State<_CountField> {
  late final TextEditingController _controller;
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.value}');
    _focus = FocusNode()..addListener(_onFocus);
  }

  @override
  void didUpdateWidget(covariant _CountField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && !_focus.hasFocus) {
      _controller.text = '${widget.value}';
    }
  }

  @override
  void dispose() {
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocus() {
    if (!_focus.hasFocus) _commit();
  }

  void _commit() {
    final parsed = int.tryParse(_controller.text);
    final next = (parsed ?? widget.value).clamp(widget.min, widget.max);
    _controller.text = '$next';
    if (next != widget.value) widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: RituColors.fillMuted),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.label, style: StudioText.microLabel),
        const SizedBox(height: 4),
        TextField(
          controller: _controller,
          focusNode: _focus,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: StudioText.fieldValue,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            filled: true,
            fillColor: RituColors.white,
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: const BorderSide(color: studioMeadow500),
            ),
          ),
          onChanged: (text) {
            final parsed = int.tryParse(text);
            if (parsed == null || parsed < widget.min || parsed > widget.max) {
              return;
            }
            if (parsed != widget.value) widget.onChanged(parsed);
          },
        ),
      ],
    );
  }
}
