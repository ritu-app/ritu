import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/luna_colors.dart';

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
      backgroundColor: LunaColors.backgroundPage,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const Spacer(),
              Text(
                'Hi, $name 👋',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 38,
                  fontWeight: FontWeight.w400,
                  height: 42 / 38,
                  color: LunaColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Luna is ready to help you understand your cycle',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  height: 24 / 15,
                  color: LunaColors.textSecondary,
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
                  color: LunaColors.textTertiary,
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
