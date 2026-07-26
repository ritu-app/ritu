import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/ritu_colors.dart';

class ConfirmationScreen extends StatelessWidget {
  const ConfirmationScreen({
    super.key,
    required this.name,
    this.onContinue,
  });

  final String name;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RituColors.backgroundPage,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Hi, $name',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 38,
                      fontWeight: FontWeight.w400,
                      height: 42 / 38,
                      color: RituColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const _WavingHand(),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Ritu is ready to help you understand your cycle',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  height: 24 / 15,
                  color: RituColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                'Let’s set things up–takes about 2 minutes',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 20 / 13,
                  color: RituColors.textTertiary,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: onContinue ?? () {},
                  child: const Text('Continue'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// A hand emoji that waves a couple of times, then pauses before looping —
/// mimics a natural greeting rather than a constant robotic swing.
class _WavingHand extends StatelessWidget {
  const _WavingHand();

  @override
  Widget build(BuildContext context) {
    return Text(
          '👋',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 38,
            fontWeight: FontWeight.w400,
            height: 42 / 38,
            color: RituColors.textPrimary,
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        // Pivot from the wrist (bottom of the glyph) rather than its center,
        // and rotate in "turns" (1.0 = 360°) as flutter_animate expects.
        .rotate(
          alignment: Alignment.bottomCenter,
          begin: 0,
          end: 0.08,
          duration: 150.ms,
          curve: Curves.easeInOut,
        )
        .then()
        .rotate(
          alignment: Alignment.bottomCenter,
          begin: 0.08,
          end: -0.06,
          duration: 150.ms,
          curve: Curves.easeInOut,
        )
        .then()
        .rotate(
          alignment: Alignment.bottomCenter,
          begin: -0.06,
          end: 0.06,
          duration: 150.ms,
          curve: Curves.easeInOut,
        )
        .then()
        .rotate(
          alignment: Alignment.bottomCenter,
          begin: 0.06,
          end: 0,
          duration: 150.ms,
          curve: Curves.easeInOut,
        )
        .then()
        // Rest at neutral before the wave repeats, so it reads as a
        // deliberate greeting rather than a constant nervous twitch.
        .rotate(begin: 0, end: 0, duration: 1200.ms);
  }
}
