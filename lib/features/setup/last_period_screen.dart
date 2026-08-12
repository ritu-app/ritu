import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/date_format.dart';
import '../../theme/ritu_colors.dart';
import 'widgets/period_episode_form_fields.dart';
import 'widgets/progress_dots.dart';
import 'widgets/ritu_calendar.dart';
import 'widgets/setup_footer.dart';

/// Figma 163:224 — onboarding step 1: last period start + end details.
class LastPeriodInput {
  const LastPeriodInput({
    required this.startedOn,
    required this.ongoingStatus,
    this.endConfidence,
    this.endedOn,
    this.roughDurationBucket,
  });

  final DateTime startedOn;
  final PeriodOngoingStatus ongoingStatus;
  final EndConfidenceChoice? endConfidence;
  final DateTime? endedOn;
  final String? roughDurationBucket;
}

class LastPeriodScreen extends StatefulWidget {
  const LastPeriodScreen({
    super.key,
    this.onContinue,
    this.onSkip,
  });

  final void Function(LastPeriodInput input)? onContinue;
  final VoidCallback? onSkip;

  @override
  State<LastPeriodScreen> createState() => _LastPeriodScreenState();
}

class _LastPeriodScreenState extends State<LastPeriodScreen> {
  late DateTime _visibleMonth;
  DateTime? _selectedDate;
  PeriodOngoingStatus? _ongoingStatus;
  EndConfidenceChoice? _endConfidence;
  DateTime? _selectedEndDate;
  String? _roughDurationBucket;

  @override
  void initState() {
    super.initState();
    final now = dateOnly(DateTime.now());
    _visibleMonth = DateTime(now.year, now.month);
    _selectedDate = now;
  }

  void _onStartSelected(DateTime date) {
    final start = dateOnly(date);
    setState(() {
      _selectedDate = start;
      if (_selectedEndDate != null && _selectedEndDate!.isBefore(start)) {
        _selectedEndDate = null;
      }
    });
  }

  void _onOngoingStatusChanged(PeriodOngoingStatus status) {
    setState(() {
      _ongoingStatus = status;
      if (status == PeriodOngoingStatus.stillGoing) {
        _endConfidence = null;
        _selectedEndDate = null;
        _roughDurationBucket = null;
      }
    });
  }

  void _onEndConfidenceChanged(EndConfidenceChoice choice) {
    setState(() {
      _endConfidence = choice;
      if (choice == EndConfidenceChoice.exact) {
        _roughDurationBucket = null;
      } else {
        _selectedEndDate = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = dateOnly(DateTime.now());
    final selected = _selectedDate == null ? null : dateOnly(_selectedDate!);
    final canSave = periodEpisodeFormIsComplete(
      startDate: selected,
      ongoingStatus: _ongoingStatus,
      endConfidence: _endConfidence,
      selectedEndDate: _selectedEndDate,
      roughDurationBucket: _roughDurationBucket,
    );

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
                        maxSelectableDate: today,
                        onMonthChanged: (month) {
                          setState(() => _visibleMonth = month);
                        },
                        onDateSelected: _onStartSelected,
                      ),
                      const SizedBox(height: 24),
                      PeriodEpisodeFormFields(
                        ongoingStatus: _ongoingStatus,
                        onOngoingStatusChanged: _onOngoingStatusChanged,
                        endConfidence: _endConfidence,
                        onEndConfidenceChanged: _onEndConfidenceChanged,
                        selectedEndDate: _selectedEndDate,
                        onEndDatePicked: (date) {
                          setState(() => _selectedEndDate = date);
                        },
                        roughDurationBucket: _roughDurationBucket,
                        onRoughDurationBucketChanged: (bucket) {
                          setState(() => _roughDurationBucket = bucket);
                        },
                        maxEndDate: today,
                        startDate: selected,
                        startDateValid: selected != null,
                      ),
                      const SizedBox(height: 24),
                      SetupFooter(
                        primaryLabel: 'This look right',
                        primaryEnabled: canSave,
                        onPrimary: () {
                          final start = selected;
                          final status = _ongoingStatus;
                          if (start == null || status == null || !canSave) {
                            return;
                          }
                          widget.onContinue?.call(
                            LastPeriodInput(
                              startedOn: start,
                              ongoingStatus: status,
                              endConfidence: _endConfidence,
                              endedOn: _selectedEndDate,
                              roughDurationBucket: _roughDurationBucket,
                            ),
                          );
                        },
                        secondaryLabel: 'Skip – I’ll log from today',
                        onSecondary: widget.onSkip ?? () {},
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Legacy duration chips kept for onboarding past-dates / profile defaults.
enum PeriodDuration { twoToThree, fourToFive, sixToSeven, varies }

extension PeriodDurationX on PeriodDuration {
  String get label => switch (this) {
        PeriodDuration.twoToThree => '2-3 days',
        PeriodDuration.fourToFive => '4-5 days',
        PeriodDuration.sixToSeven => '6-7 days',
        PeriodDuration.varies => 'Varies',
      };

  int? get typicalDays => switch (this) {
        PeriodDuration.twoToThree => 3,
        PeriodDuration.fourToFive => 5,
        PeriodDuration.sixToSeven => 7,
        PeriodDuration.varies => null,
      };
}
