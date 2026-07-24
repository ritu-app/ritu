import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/date_format.dart';
import '../../theme/ritu_colors.dart';
import '../setup/widgets/ritu_calendar.dart';

/// Modal to change the latest period start date (Figma 11.x Period Started edit).
Future<DateTime?> showEditPeriodStartedDialog(
  BuildContext context, {
  DateTime? currentStartedOn,
}) {
  return showDialog<DateTime>(
    context: context,
    barrierColor: const Color(0xB3000000), // black @ 70%
    builder: (dialogContext) {
      return _EditPeriodStartedDialog(currentStartedOn: currentStartedOn);
    },
  );
}

class _EditPeriodStartedDialog extends StatefulWidget {
  const _EditPeriodStartedDialog({this.currentStartedOn});

  final DateTime? currentStartedOn;

  @override
  State<_EditPeriodStartedDialog> createState() =>
      _EditPeriodStartedDialogState();
}

class _EditPeriodStartedDialogState extends State<_EditPeriodStartedDialog> {
  late DateTime _visibleMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final today = dateOnly(DateTime.now());
    final initial = dateOnly(widget.currentStartedOn ?? today);
    _selectedDate = initial.isAfter(today) ? today : initial;
    _visibleMonth = DateTime(_selectedDate.year, _selectedDate.month);
  }

  void _save() {
    Navigator.of(context).pop(_selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Material(
        color: RituColors.backgroundPage,
        borderRadius: BorderRadius.circular(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'What did your last period start?',
                            style: GoogleFonts.dmSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              height: 24 / 18,
                              color: RituColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Change the start date of your latest period',
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
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      behavior: HitTestBehavior.opaque,
                      child: const Icon(
                        Icons.close,
                        size: 24,
                        color: RituColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                RituCalendar(
                  month: _visibleMonth,
                  selectedDate: _selectedDate,
                  maxSelectableDate: DateTime.now(),
                  onMonthChanged: (month) {
                    setState(() => _visibleMonth = month);
                  },
                  onDateSelected: (date) {
                    setState(() => _selectedDate = dateOnly(date));
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: RituColors.sage500,
                      foregroundColor: RituColors.white,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: const StadiumBorder(),
                      textStyle: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 20 / 13,
                      ),
                    ),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
