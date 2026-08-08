import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../theme/ritu_colors.dart';
import 'widgets/progress_dots.dart';
import 'widgets/setup_footer.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({
    super.key,
    this.onTurnOn,
    this.onSkip,
  });

  final Future<void> Function()? onTurnOn;
  final Future<void> Function()? onSkip;

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  var _busy = false;

  Future<void> _run(Future<void> Function()? action) async {
    if (_busy || action == null) return;
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
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
              const ProgressDots(currentStep: 3),
              const Spacer(),
              const Icon(
                LucideIcons.bell,
                size: 64,
                color: RituColors.sage500,
              ),
              const SizedBox(height: 20),
              Text(
                'A gentle nudge each morning',
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
                'A notification reminds you to log. Takes 30 seconds. You can turn it off anytime.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  height: 24 / 15,
                  color: RituColors.textSecondary,
                ),
              ),
              const Spacer(),
              SetupFooter(
                primaryLabel: 'Turn on reminders',
                primaryEnabled: !_busy,
                onPrimary: () => _run(widget.onTurnOn),
                secondaryLabel: 'Skip for now',
                onSecondary: () => _run(widget.onSkip ?? widget.onTurnOn),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
