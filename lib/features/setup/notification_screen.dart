import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/luna_colors.dart';
import 'widgets/progress_dots.dart';
import 'widgets/setup_footer.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({
    super.key,
    this.onTurnOn,
    this.onSkip,
  });

  final VoidCallback? onTurnOn;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LunaColors.backgroundPage,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const ProgressDots(currentStep: 4),
              const Spacer(),
              const Icon(
                Icons.notifications_none_rounded,
                size: 64,
                color: LunaColors.sage500,
              ),
              const SizedBox(height: 20),
              Text(
                'A gentle nudge each morning',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  height: 26 / 22,
                  color: LunaColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'A notification reminds you to log. Takes 30 seconds. You can turn it off anytime.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  height: 24 / 15,
                  color: LunaColors.textSecondary,
                ),
              ),
              const Spacer(),
              SetupFooter(
                primaryLabel: 'Turn on reminders',
                onPrimary: onTurnOn ?? () {},
                secondaryLabel: 'Skip for now',
                onSecondary: onSkip ?? onTurnOn ?? () {},
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
