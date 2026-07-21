import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/luna_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, this.onGetStarted});

  final VoidCallback? onGetStarted;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LunaColors.backgroundPage,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const Spacer(flex: 2),
              const _BrandBlock(),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: onGetStarted ?? () {},
                  child: const Text('Get started'),
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

class _BrandBlock extends StatelessWidget {
  const _BrandBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/luna_logo.png',
          width: 120,
          height: 120,
          filterQuality: FilterQuality.high,
        ),
        const SizedBox(height: 12),
        Text(
          'Luna',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 48,
            fontWeight: FontWeight.w400,
            color: LunaColors.sage600,
            height: 1,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'CYCLE JOURNAL',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: LunaColors.neutral600,
            letterSpacing: 0.96,
            height: 1,
          ),
        ),
        const SizedBox(height: 7),
        Container(
          width: 114,
          height: 1,
          color: LunaColors.divider,
        ),
        const SizedBox(height: 7),
        Text(
          'A private journal for your cycle',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: LunaColors.neutral500,
            height: 1.25,
          ),
        ),
      ],
    );
  }
}
