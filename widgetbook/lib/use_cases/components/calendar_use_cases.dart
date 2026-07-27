import 'package:flutter/material.dart';
import 'package:ritu/core/date_format.dart';
import 'package:ritu/features/setup/widgets/ritu_calendar.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Default selection',
  type: RituCalendar,
  path: '[Components]/Calendar',
)
Widget rituCalendarDefaultUseCase(BuildContext context) {
  return const _CalendarPreview();
}

/// Mirrors the "Period Started" screen, which blocks selecting future dates.
@widgetbook.UseCase(
  name: 'Max selectable date (no future dates)',
  type: RituCalendar,
  path: '[Components]/Calendar',
)
Widget rituCalendarMaxSelectableUseCase(BuildContext context) {
  return _CalendarPreview(maxSelectableDate: dateOnly(DateTime.now()));
}

/// Mirrors the "Period History" screen, which uses dotted selection and
/// removable date chips instead of a filled circle.
@widgetbook.UseCase(
  name: 'Dotted selection style',
  type: RituCalendar,
  path: '[Components]/Calendar',
)
Widget rituCalendarDottedUseCase(BuildContext context) {
  return const _CalendarPreview(
    selectionStyle: RituCalendarSelectionStyle.dotted,
  );
}

/// Shows the red-ish "estimated bleed range" preview text used while
/// picking a period start date, before the range is confirmed.
@widgetbook.UseCase(
  name: 'Preview dates (estimated range)',
  type: RituCalendar,
  path: '[Components]/Calendar',
)
Widget rituCalendarPreviewDatesUseCase(BuildContext context) {
  final now = DateTime.now();
  final selected = DateTime(now.year, now.month, now.day);
  final preview = {
    for (var i = 1; i <= 4; i++) selected.add(Duration(days: i)),
  };

  return _CalendarPreview(selectedDate: selected, previewDates: preview);
}

class _CalendarPreview extends StatefulWidget {
  const _CalendarPreview({
    this.selectedDate,
    this.previewDates = const {},
    this.selectionStyle = RituCalendarSelectionStyle.filled,
    this.maxSelectableDate,
  });

  final DateTime? selectedDate;
  final Set<DateTime> previewDates;
  final RituCalendarSelectionStyle selectionStyle;
  final DateTime? maxSelectableDate;

  @override
  State<_CalendarPreview> createState() => _CalendarPreviewState();
}

class _CalendarPreviewState extends State<_CalendarPreview> {
  late DateTime _month;
  DateTime? _selected;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _selected = widget.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: RituCalendar(
        month: _month,
        onMonthChanged: (m) => setState(() => _month = m),
        selectedDate: _selected,
        onDateSelected: (d) => setState(() => _selected = d),
        previewDates: widget.previewDates,
        selectionStyle: widget.selectionStyle,
        maxSelectableDate: widget.maxSelectableDate,
      ),
    );
  }
}
