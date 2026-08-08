import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/date_format.dart';
import '../../theme/ritu_colors.dart';
import '../setup/widgets/ritu_calendar.dart';

/// Figma 865:3405 — Calender bottom sheet for filtering All entries by day.
Future<DateTime?> showJournalCalendarSheet(
  BuildContext context, {
  DateTime? selectedDate,
  DateTime? maxSelectableDate,
  Set<DateTime> entryDates = const {},
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0xB3000000),
    isScrollControlled: true,
    builder: (sheetContext) => _JournalCalendarSheet(
      selectedDate: selectedDate,
      maxSelectableDate: maxSelectableDate,
      entryDates: entryDates,
    ),
  );
}

class _JournalCalendarSheet extends StatefulWidget {
  const _JournalCalendarSheet({
    this.selectedDate,
    this.maxSelectableDate,
    this.entryDates = const {},
  });

  final DateTime? selectedDate;
  final DateTime? maxSelectableDate;
  final Set<DateTime> entryDates;

  @override
  State<_JournalCalendarSheet> createState() => _JournalCalendarSheetState();
}

class _JournalCalendarSheetState extends State<_JournalCalendarSheet> {
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    final anchor = widget.selectedDate ??
        widget.maxSelectableDate ??
        dateOnly(DateTime.now());
    _visibleMonth = DateTime(anchor.year, anchor.month);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: RituColors.backgroundPage,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        side: BorderSide(color: RituColors.borderSubtle),
      ),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      // Spelling matches Figma label.
                      'Calender',
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 24 / 18,
                        color: RituColors.textPrimary,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    behavior: HitTestBehavior.opaque,
                    child: const SizedBox(
                      width: 24,
                      height: 24,
                      child: Icon(
                        LucideIcons.x,
                        size: 24,
                        color: RituColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              RituCalendar(
                month: _visibleMonth,
                selectedDate: widget.selectedDate,
                entryDates: widget.entryDates,
                maxSelectableDate: widget.maxSelectableDate,
                onMonthChanged: (month) => setState(() => _visibleMonth = month),
                onDateSelected: (date) =>
                    Navigator.of(context).pop(dateOnly(date)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
