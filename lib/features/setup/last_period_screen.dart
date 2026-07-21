import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/ritu_colors.dart';
import 'widgets/choice_chips.dart';
import 'widgets/ritu_calendar.dart';
import 'widgets/progress_dots.dart';
import 'widgets/setup_footer.dart';

enum PeriodDuration { twoToThree, fourToFive, sixToSeven, varies }

extension on PeriodDuration {
  String get label => switch (this) {
        PeriodDuration.twoToThree => '2-3 days',
        PeriodDuration.fourToFive => '4-5 days',
        PeriodDuration.sixToSeven => '6-7 days',
        PeriodDuration.varies => 'Varies',
      };
}

class LastPeriodScreen extends StatefulWidget {
  const LastPeriodScreen({
    super.key,
    this.onContinue,
    this.onSkip,
  });

  final VoidCallback? onContinue;
  final VoidCallback? onSkip;

  @override
  State<LastPeriodScreen> createState() => _LastPeriodScreenState();
}

class _LastPeriodScreenState extends State<LastPeriodScreen> {
  late DateTime _visibleMonth;
  DateTime? _selectedDate;
  PeriodDuration _duration = PeriodDuration.fourToFive;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RituColors.backgroundPage,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const ProgressDots(currentStep: 1),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'What did your last period start?',
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
                        'Approximate is fine. You can always adjust later',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          height: 24 / 15,
                          color: RituColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      RituCalendar(
                        month: _visibleMonth,
                        selectedDate: _selectedDate,
                        onMonthChanged: (month) {
                          setState(() => _visibleMonth = month);
                        },
                        onDateSelected: (date) {
                          setState(() => _selectedDate = date);
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'And roughly how many days did it last?',
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          height: 24 / 18,
                          color: RituColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          for (final option in PeriodDuration.values) ...[
                            if (option != PeriodDuration.values.first)
                              const SizedBox(width: 8),
                            Expanded(
                              child: RituChoiceChip(
                                label: option.label,
                                selected: _duration == option,
                                width: double.infinity,
                                onTap: () {
                                  setState(() => _duration = option);
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SetupFooter(
                primaryLabel: 'This look right',
                onPrimary: widget.onContinue,
                secondaryLabel: 'Skip – I’ll log from today',
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
