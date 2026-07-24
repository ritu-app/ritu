import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/date_format.dart';
import '../../../theme/ritu_colors.dart';

enum RituCalendarSelectionStyle { filled, dotted }

class RituCalendar extends StatelessWidget {
  const RituCalendar({
    super.key,
    required this.month,
    required this.onMonthChanged,
    this.selectedDate,
    this.markedDates = const {},
    this.periodDates = const {},
    this.onDateSelected,
    this.selectionStyle = RituCalendarSelectionStyle.filled,
    this.maxSelectableDate,
  });

  final DateTime month;
  final ValueChanged<DateTime> onMonthChanged;
  final DateTime? selectedDate;
  final Set<DateTime> markedDates;
  final Set<DateTime> periodDates;
  final ValueChanged<DateTime>? onDateSelected;
  final RituCalendarSelectionStyle selectionStyle;

  /// Inclusive last day that can be selected. Days after this are disabled.
  final DateTime? maxSelectableDate;

  static const _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const _weekdays = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

  DateTime get _normalizedMonth => DateTime(month.year, month.month);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isMarked(DateTime day) =>
      markedDates.any((d) => _isSameDay(d, day));

  bool _isPeriod(DateTime day) =>
      periodDates.any((d) => _isSameDay(d, day));

  bool _isToday(DateTime day) {
    final now = DateTime.now();
    return _isSameDay(day, now);
  }

  bool _isSelectable(DateTime day) {
    final max = maxSelectableDate;
    if (max == null) return true;
    return !dateOnly(day).isAfter(dateOnly(max));
  }

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = _normalizedMonth;
    final daysInMonth = DateTime(firstOfMonth.year, firstOfMonth.month + 1, 0)
        .day;
    // DateTime.weekday: Mon=1..Sun=7. Convert to Sun=0..Sat=6.
    final startOffset = firstOfMonth.weekday % 7;
    final totalCells = startOffset + daysInMonth;
    final rowCount = ((totalCells + 6) / 7).floor();
    final max = maxSelectableDate == null ? null : dateOnly(maxSelectableDate!);
    final canGoForward = max == null ||
        DateTime(firstOfMonth.year, firstOfMonth.month + 1)
            .isBefore(DateTime(max.year, max.month + 1));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: RituColors.fillElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: RituColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _NavIcon(
                icon: Icons.chevron_left,
                onTap: () => onMonthChanged(
                  DateTime(firstOfMonth.year, firstOfMonth.month - 1),
                ),
              ),
              Expanded(
                child: Text(
                  '${_monthNames[firstOfMonth.month - 1]} ${firstOfMonth.year}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 24 / 15,
                    color: RituColors.textPrimary,
                  ),
                ),
              ),
              _NavIcon(
                icon: Icons.chevron_right,
                enabled: canGoForward,
                onTap: () => onMonthChanged(
                  DateTime(firstOfMonth.year, firstOfMonth.month + 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final day in _weekdays)
                SizedBox(
                  width: 30,
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      height: 14 / 10,
                      color: RituColors.textDisabled,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          for (var row = 0; row < rowCount; row++) ...[
            if (row > 0) const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var col = 0; col < 7; col++)
                  _buildDayCell(startOffset, daysInMonth, row * 7 + col),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDayCell(int startOffset, int daysInMonth, int index) {
    final dayNumber = index - startOffset + 1;
    if (dayNumber < 1 || dayNumber > daysInMonth) {
      return const SizedBox(width: 30, height: 36);
    }

    final date = DateTime(month.year, month.month, dayNumber);
    final selectable = _isSelectable(date);
    final isSelected =
        selectable && selectedDate != null && _isSameDay(selectedDate!, date);
    final isMarked = selectable && _isMarked(date);
    final isPeriod = _isPeriod(date);
    final showTodayDot = isPeriod && _isToday(date);
    final dayColor = !selectable
        ? RituColors.textDisabled
        : isPeriod
            ? RituColors.rosewood900
            : isSelected && selectionStyle == RituCalendarSelectionStyle.filled
                ? RituColors.textInverse
                : RituColors.textPrimary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: !selectable || onDateSelected == null
          ? null
          : () => onDateSelected!(date),
      child: SizedBox(
        width: 30,
        height: 36,
        child: isPeriod && selectable
            ? Center(
                child: Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: RituColors.cycleMenstrual,
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '$dayNumber',
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1,
                          color: dayColor,
                        ),
                      ),
                      if (showTodayDot)
                        const Positioned(
                          bottom: 3,
                          child: SizedBox(
                            width: 4,
                            height: 4,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: RituColors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              )
            : selectionStyle == RituCalendarSelectionStyle.filled &&
                    isSelected
                ? Center(
                    child: Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: RituColors.fillBrandPressed,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$dayNumber',
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1,
                          color: dayColor,
                        ),
                      ),
                    ),
                  )
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '$dayNumber',
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1,
                          color: dayColor,
                        ),
                      ),
                      if (isMarked ||
                          (selectionStyle ==
                                  RituCalendarSelectionStyle.dotted &&
                              isSelected))
                        const Positioned(
                          bottom: 0,
                          child: SizedBox(
                            width: 4,
                            height: 4,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: RituColors.sage500,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Icon(
        icon,
        size: 16,
        color: enabled
            ? RituColors.textDisabled
            : RituColors.textDisabled.withValues(alpha: 0.35),
      ),
    );
  }
}
