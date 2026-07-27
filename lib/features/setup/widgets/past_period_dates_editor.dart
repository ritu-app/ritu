import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/date_format.dart';
import '../../../theme/ritu_colors.dart';
import 'choice_chips.dart';
import 'ritu_calendar.dart';
import 'setup_footer.dart';

/// Shared chips + calendar UI for adding past period start dates
/// (onboarding past-dates step and Settings → Period History).
///
/// The calendar stays visible at all times. Tapping a day only stages it as
/// a pending selection; it's only added (and persisted via [onDateAdded])
/// once the user presses "Add a date".
class PastPeriodDatesEditor extends StatefulWidget {
  const PastPeriodDatesEditor({
    super.key,
    this.initialDates = const [],
    this.maxSelectableDate,
    this.helperText,
    this.onChanged,
    this.onDateAdded,
    this.onDateRemoved,
  });

  final List<DateTime> initialDates;

  /// Inclusive last selectable day (defaults to today).
  final DateTime? maxSelectableDate;

  final String? helperText;
  final ValueChanged<List<DateTime>>? onChanged;

  /// Called when a date is newly added (after local list update).
  final Future<void> Function(DateTime date)? onDateAdded;

  /// Called when a date pill is removed.
  final Future<void> Function(DateTime date)? onDateRemoved;

  @override
  State<PastPeriodDatesEditor> createState() => PastPeriodDatesEditorState();
}

class PastPeriodDatesEditorState extends State<PastPeriodDatesEditor> {
  late DateTime _visibleMonth;
  late List<DateTime> _dates;
  DateTime? _pendingDate;
  var _busy = false;

  static const _monthAbbr = [
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

  List<DateTime> get dates => List.unmodifiable(_dates);

  DateTime get _maxDate =>
      dateOnly(widget.maxSelectableDate ?? DateTime.now());

  @override
  void initState() {
    super.initState();
    _dates = widget.initialDates.map(dateOnly).toList()..sort();
    final focus = _dates.isNotEmpty ? _dates.last : _maxDate;
    _visibleMonth = DateTime(focus.year, focus.month);
  }

  void _notify() => widget.onChanged?.call(List.of(_dates));

  String _chipLabel(DateTime date) =>
      '${_monthAbbr[date.month - 1]} ${date.day}';

  void _selectDate(DateTime date) {
    if (_busy) return;
    final day = dateOnly(date);
    if (day.isAfter(_maxDate)) return;
    if (_dates.any((d) => isSameCalendarDay(d, day))) return;

    setState(() {
      _pendingDate = _pendingDate != null && isSameCalendarDay(_pendingDate!, day)
          ? null
          : day;
    });
  }

  Future<void> _confirmAdd() async {
    final day = _pendingDate;
    if (day == null || _busy) return;

    setState(() {
      _busy = true;
      _dates.add(day);
      _dates.sort();
      _pendingDate = null;
    });
    _notify();

    try {
      await widget.onDateAdded?.call(day);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _removeDate(DateTime date) async {
    if (_busy) return;
    final day = dateOnly(date);

    setState(() {
      _busy = true;
      _dates.removeWhere((d) => isSameCalendarDay(d, day));
    });
    _notify();

    try {
      await widget.onDateRemoved?.call(day);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_dates.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final date in _dates)
                RituDateChip(
                  label: _chipLabel(date),
                  onRemove: () => _removeDate(date),
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        RituCalendar(
          month: _visibleMonth,
          selectedDate: _pendingDate,
          markedDates: _dates.toSet(),
          maxSelectableDate: _maxDate,
          onMonthChanged: (month) {
            setState(() => _visibleMonth = month);
          },
          onDateSelected: _selectDate,
        ),
        const SizedBox(height: 16),
        OutlinedPillButton(
          label: 'Add a date',
          onPressed: _busy || _pendingDate == null ? null : _confirmAdd,
        ),
        if (widget.helperText != null) ...[
          const SizedBox(height: 12),
          Text(
            widget.helperText!,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 18 / 13,
              color: RituColors.textTertiary,
            ),
          ),
        ],
      ],
    );
  }
}
