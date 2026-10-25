import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/ritu_palette.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, this.onGetStarted, this.onRestoreFromBackup});

  final VoidCallback? onGetStarted;
  final VoidCallback? onRestoreFromBackup;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.ritu.backgroundPage,
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
              const SizedBox(height: 24),
              TextButton(
                onPressed: onRestoreFromBackup ?? () {},
                style: TextButton.styleFrom(
                  foregroundColor: context.ritu.textTertiary,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(double.infinity, 24),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 24 / 15,
                  ),
                ),
                child: const Text('Restore from backup'),
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
          'assets/images/ritu_logo.png',
          width: 120,
          height: 120,
          filterQuality: FilterQuality.high,
        ),
        const SizedBox(height: 12),
        Text(
          'Ritu',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 56,
            fontWeight: FontWeight.w400,
            color: context.ritu.sage600,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'CYCLE JOURNAL',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: context.ritu.neutral600,
            letterSpacing: 0.96,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Container(width: 114, height: 1, color: context.ritu.divider),
        const SizedBox(height: 4),
        SizedBox(
          width: 113,
          child: Text(
            'A private journal for your cycle',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: context.ritu.neutral500,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }
}
