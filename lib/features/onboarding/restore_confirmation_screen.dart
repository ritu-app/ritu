import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/ritu_palette.dart';
import 'confirmation_screen.dart';

/// Figma 1242:5301 — shown after a backup is restored.
class RestoreConfirmationScreen extends StatelessWidget {
  const RestoreConfirmationScreen({
    super.key,
    required this.name,
    this.onContinue,
  });

  final String name;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final display = GoogleFonts.dmSerifDisplay(
      fontSize: 38,
      fontWeight: FontWeight.w400,
      height: 42 / 38,
      color: context.ritu.textPrimary,
    );

    return Scaffold(
      backgroundColor: context.ritu.backgroundPage,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const Spacer(),
              const WavingHand(),
              Text('Welcome back', textAlign: TextAlign.center, style: display),
              Text(name, textAlign: TextAlign.center, style: display),
              const SizedBox(height: 8),
              Text(
                'Your data has been fully restored',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  height: 24 / 15,
                  color: context.ritu.textSecondary,
                ),
              ),
              const Spacer(),
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
