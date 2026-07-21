import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/luna_colors.dart';

enum LunaCalendarSelectionStyle { filled, dotted }

class LunaCalendar extends StatelessWidget {
  const LunaCalendar({
    super.key,
    required this.month,
    required this.onMonthChanged,
    this.selectedDate,
    this.markedDates = const {},
    this.onDateSelected,
    this.selectionStyle = LunaCalendarSelectionStyle.filled,
  });

  final DateTime month;
  final ValueChanged<DateTime> onMonthChanged;
  final DateTime? selectedDate;
  final Set<DateTime> markedDates;
  final ValueChanged<DateTime>? onDateSelected;
  final LunaCalendarSelectionStyle selectionStyle;

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

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = _normalizedMonth;
    final daysInMonth = DateTime(firstOfMonth.year, firstOfMonth.month + 1, 0)
        .day;
    // DateTime.weekday: Mon=1..Sun=7. Convert to Sun=0..Sat=6.
    final startOffset = firstOfMonth.weekday % 7;
    final totalCells = startOffset + daysInMonth;
    final rowCount = ((totalCells + 6) / 7).floor();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: LunaColors.fillElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: LunaColors.borderSubtle),
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
                    color: LunaColors.textPrimary,
                  ),
                ),
              ),
              _NavIcon(
                icon: Icons.chevron_right,
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
                      color: LunaColors.textDisabled,
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
    final isSelected =
        selectedDate != null && _isSameDay(selectedDate!, date);
    final isMarked = _isMarked(date);

    return GestureDetector(
      onTap: onDateSelected == null ? null : () => onDateSelected!(date),
      child: SizedBox(
        width: 30,
        height: 36,
        child: selectionStyle == LunaCalendarSelectionStyle.filled &&
                isSelected
            ? Center(
                child: Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: LunaColors.fillBrandPressed,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$dayNumber',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1,
                      color: LunaColors.textInverse,
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
                      color: LunaColors.textPrimary,
                    ),
                  ),
                  if (isMarked ||
                      (selectionStyle == LunaCalendarSelectionStyle.dotted &&
                          isSelected))
                    const Positioned(
                      bottom: 0,
                      child: SizedBox(
                        width: 4,
                        height: 4,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: LunaColors.sage500,
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
  const _NavIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Icon(icon, size: 16, color: LunaColors.textDisabled),
    );
  }
}
