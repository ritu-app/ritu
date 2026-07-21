import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/ritu_colors.dart';
import 'widgets/choice_chips.dart';
import 'widgets/ritu_calendar.dart';
import 'widgets/progress_dots.dart';
import 'widgets/setup_footer.dart';

class PastDatesScreen extends StatefulWidget {
  const PastDatesScreen({
    super.key,
    this.onContinue,
    this.onSkip,
  });

  final VoidCallback? onContinue;
  final VoidCallback? onSkip;

  @override
  State<PastDatesScreen> createState() => _PastDatesScreenState();
}

class _PastDatesScreenState extends State<PastDatesScreen> {
  late DateTime _visibleMonth;
  final List<DateTime> _dates = [];
  bool _showCalendar = false;

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

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _chipLabel(DateTime date) =>
      '${_monthAbbr[date.month - 1]} ${date.day}';

  void _toggleDate(DateTime date) {
    setState(() {
      final index = _dates.indexWhere((d) => _isSameDay(d, date));
      if (index >= 0) {
        _dates.removeAt(index);
      } else {
        _dates.add(date);
        _dates.sort();
      }
      _showCalendar = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = _dates.isNotEmpty;

    return Scaffold(
      backgroundColor: RituColors.backgroundPage,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const ProgressDots(currentStep: 3),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Do you have past period dates?',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          height: 26 / 22,
                          color: RituColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'It helps Ritu understand your cycle right away. Completely optional.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          height: 24 / 15,
                          color: RituColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_dates.isNotEmpty && !_showCalendar) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final date in _dates)
                              RituDateChip(
                                label: _chipLabel(date),
                                onRemove: () {
                                  setState(() {
                                    _dates.removeWhere(
                                      (d) => _isSameDay(d, date),
                                    );
                                  });
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (_showCalendar) ...[
                        RituCalendar(
                          month: _visibleMonth,
                          markedDates: _dates.toSet(),
                          selectionStyle: RituCalendarSelectionStyle.dotted,
                          onMonthChanged: (month) {
                            setState(() => _visibleMonth = month);
                          },
                          onDateSelected: _toggleDate,
                        ),
                        const SizedBox(height: 16),
                      ],
                      OutlinedPillButton(
                        label: 'Add a date',
                        onPressed: () {
                          setState(() => _showCalendar = !_showCalendar);
                        },
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'You can add more dates anytime in Settings',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 20 / 13,
                          color: RituColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SetupFooter(
                primaryLabel: 'Continue',
                primaryEnabled: canContinue,
                onPrimary: widget.onContinue,
                secondaryLabel: 'Skip – I’ll build from today',
                onSecondary: widget.onSkip ?? widget.onContinue ?? () {},
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
