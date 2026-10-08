import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ritu/theme/ritu_colors.dart';

/// Icon stroke used by the studio chrome (Figma lucide exports).
const Color studioIcon = Color(0xFF4C4744);

/// Card outline. Slightly cooler than [RituColors.borderSubtle].
const Color studioCardBorder = Color(0xFFEBEBEA);

/// Meadow/500 — cycle-day slider fill.
const Color studioMeadow500 = Color(0xFF8DBE9A);

const LinearGradient studioGradient = LinearGradient(
  begin: Alignment(0.84, 0.54),
  end: Alignment(-0.84, -0.54),
  stops: [0.0075, 0.1337, 0.2784, 0.4767, 0.9949],
  colors: [
    Color.fromRGBO(232, 218, 223, 0),
    Color.fromRGBO(232, 218, 223, 0.16),
    Color.fromRGBO(239, 228, 228, 0.459),
    Color.fromRGBO(252, 245, 238, 1),
    Color.fromRGBO(238, 252, 244, 1),
  ],
);

class StudioBackdrop extends StatelessWidget {
  const StudioBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: RituColors.backgroundPage,
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: studioGradient),
        child: child,
      ),
    );
  }
}

abstract final class StudioText {
  static TextStyle displayTitle = GoogleFonts.dmSerifDisplay(
    fontSize: 38,
    fontWeight: FontWeight.w400,
    height: 42 / 38,
    color: RituColors.textPrimary,
  );

  static TextStyle wordmark = GoogleFonts.dmSans(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 26 / 22,
    color: RituColors.textPrimary,
  );

  static TextStyle eyebrow = GoogleFonts.dmSans(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 24 / 15,
    letterSpacing: 2.55,
    color: RituColors.textSecondary,
  );

  static TextStyle link = GoogleFonts.dmSans(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 24 / 15,
    color: RituColors.fillBrandPressed,
  );

  static TextStyle sectionLabel = GoogleFonts.dmSans(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 24 / 15,
    color: RituColors.textTertiary,
  );

  static TextStyle sectionBody = GoogleFonts.dmSans(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 24 / 15,
    color: RituColors.textPrimary,
  );

  static TextStyle cardTitle = GoogleFonts.dmSans(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 24 / 15,
    color: RituColors.textPrimary,
  );

  static TextStyle cardSummary = GoogleFonts.dmSans(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 20 / 13,
    color: RituColors.textSecondary,
  );

  static TextStyle fieldLabel = GoogleFonts.dmSans(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 18 / 11,
    color: RituColors.textTertiary,
  );

  static TextStyle fieldValue = GoogleFonts.dmSans(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 20 / 13,
    color: RituColors.textPrimary,
  );

  static TextStyle option = GoogleFonts.dmSans(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 20 / 13,
    color: RituColors.textPrimary,
  );

  static TextStyle caption = GoogleFonts.dmSans(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 16 / 11,
    color: RituColors.textSecondary,
  );

  static TextStyle hint = GoogleFonts.dmSans(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 16 / 11,
    color: RituColors.textTertiary,
  );

  static TextStyle microLabel = GoogleFonts.dmSans(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 14 / 10,
    color: RituColors.textTertiary,
  );

  static TextStyle cycleTitle = GoogleFonts.dmSans(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 16 / 11,
    color: RituColors.textPrimary,
  );

  static TextStyle segmentIdle = GoogleFonts.dmSans(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 20 / 13,
    color: RituColors.sage600,
  );

  static TextStyle readout = GoogleFonts.dmSans(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 24 / 15,
    color: RituColors.textPrimary,
  );

  static TextStyle readoutLabel = GoogleFonts.dmSans(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 24 / 15,
    color: RituColors.textSecondary,
  );

  static TextStyle noteBody = GoogleFonts.dmSans(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 20 / 13,
    color: RituColors.textSecondary,
  );

  static TextStyle reset = GoogleFonts.dmSans(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 24 / 15,
    color: RituColors.sage600,
  );

  static TextStyle footer = GoogleFonts.dmSans(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 24 / 15,
    color: RituColors.textPrimary,
  );
}

BoxDecoration studioCardDecoration() {
  return BoxDecoration(
    color: RituColors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: studioCardBorder),
  );
}
