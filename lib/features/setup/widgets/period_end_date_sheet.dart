import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/date_format.dart';
import '../../../theme/ritu_colors.dart';
import 'ritu_calendar.dart';

/// Bottom sheet for picking an exact period end date (Figma 1123:5335).
Future<DateTime?> showPeriodEndDateSheet({
  required BuildContext context,
  required DateTime startedOn,
  required DateTime maxEndDate,
  DateTime? initialEndDate,
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    backgroundColor: RituColors.fillElevated,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => _PeriodEndDateSheet(
      startedOn: dateOnly(startedOn),
      maxEndDate: dateOnly(maxEndDate),
      initialEndDate:
          initialEndDate == null ? null : dateOnly(initialEndDate),
    ),
  );
}

class _PeriodEndDateSheet extends StatefulWidget {
  const _PeriodEndDateSheet({
    required this.startedOn,
    required this.maxEndDate,
    this.initialEndDate,
  });

  final DateTime startedOn;
  final DateTime maxEndDate;
  final DateTime? initialEndDate;

  @override
  State<_PeriodEndDateSheet> createState() => _PeriodEndDateSheetState();
}

class _PeriodEndDateSheetState extends State<_PeriodEndDateSheet> {
  late DateTime _visibleMonth;
  DateTime? _selectedEnd;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialEndDate;
    _selectedEnd = initial;
    _visibleMonth = DateTime(
      (initial ?? widget.startedOn).year,
      (initial ?? widget.startedOn).month,
    );
  }

  int? get _inclusiveDays {
    final end = _selectedEnd;
    if (end == null) return null;
    return dateOnly(end).difference(widget.startedOn).inDays + 1;
  }

  bool get _showLongPeriodWarning {
    final days = _inclusiveDays;
    return days != null && days > 10;
  }

  Set<DateTime> get _rangePreviewDates {
    final end = _selectedEnd;
    if (end == null) return const {};
    final days = <DateTime>{};
    var cursor = widget.startedOn.add(const Duration(days: 1));
    final last = dateOnly(end).subtract(const Duration(days: 1));
    while (!cursor.isAfter(last)) {
      days.add(cursor);
      cursor = cursor.add(const Duration(days: 1));
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'When did your last period end?',
                          style: GoogleFonts.dmSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            height: 24 / 18,
                            color: RituColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Started: ${formatDisplayDate(widget.startedOn)}',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            height: 20 / 13,
                            color: RituColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      LucideIcons.x,
                      size: 24,
                      color: RituColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: RituCalendar(
                month: _visibleMonth,
                selectedDate: _selectedEnd,
                anchorDate: widget.startedOn,
                previewDates: _rangePreviewDates,
                minSelectableDate: widget.startedOn,
                maxSelectableDate: widget.maxEndDate,
                onMonthChanged: (month) => setState(() => _visibleMonth = month),
                onDateSelected: (date) {
                  setState(() => _selectedEnd = dateOnly(date));
                },
              ),
            ),
            if (_showLongPeriodWarning) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: RituColors.fillCritical,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'That’s a $_inclusiveDays-day period – longer than typical. '
                    'Save anyway?',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      height: 20 / 13,
                      color: RituColors.textCritical,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                height: 48,
                width: double.infinity,
                child: FilledButton(
                  onPressed: _selectedEnd == null
                      ? null
                      : () => Navigator.of(context).pop(_selectedEnd),
                  style: FilledButton.styleFrom(
                    backgroundColor: RituColors.sage500,
                    disabledBackgroundColor:
                        RituColors.sage500.withValues(alpha: 0.4),
                    foregroundColor: RituColors.white,
                    disabledForegroundColor: RituColors.white,
                    elevation: 0,
                    shape: const StadiumBorder(),
                    textStyle: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 24 / 15,
                    ),
                  ),
                  child: const Text('Save date'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
