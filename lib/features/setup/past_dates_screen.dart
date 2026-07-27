import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/ritu_colors.dart';
import 'widgets/past_period_dates_editor.dart';
import 'widgets/progress_dots.dart';
import 'widgets/setup_footer.dart';

class PastDatesScreen extends StatefulWidget {
  const PastDatesScreen({
    super.key,
    this.onContinue,
    this.onSkip,
  });

  final void Function(List<DateTime> dates)? onContinue;
  final VoidCallback? onSkip;

  @override
  State<PastDatesScreen> createState() => _PastDatesScreenState();
}

class _PastDatesScreenState extends State<PastDatesScreen> {
  final _editorKey = GlobalKey<PastPeriodDatesEditorState>();
  var _hasDates = false;

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
              const ProgressDots(currentStep: 2),
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
                      PastPeriodDatesEditor(
                        key: _editorKey,
                        helperText:
                            'You can add more dates anytime in Settings',
                        onChanged: (dates) {
                          setState(() => _hasDates = dates.isNotEmpty);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SetupFooter(
                primaryLabel: 'Continue',
                primaryEnabled: _hasDates,
                onPrimary: () {
                  final dates =
                      _editorKey.currentState?.dates ?? const <DateTime>[];
                  widget.onContinue?.call(List.of(dates));
                },
                secondaryLabel: 'Skip – I’ll build from today',
                onSecondary: widget.onSkip ?? () {},
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
