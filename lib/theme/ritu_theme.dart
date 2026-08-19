import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'ritu_colors.dart';

ThemeData buildRituTheme() {
  final textTheme = GoogleFonts.dmSansTextTheme().apply(
    bodyColor: RituColors.neutral600,
    displayColor: RituColors.sage600,
  );

  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: RituColors.backgroundPage,
    colorScheme: ColorScheme.light(
      primary: RituColors.sage500,
      onPrimary: RituColors.white,
      surface: RituColors.backgroundPage,
      onSurface: RituColors.sage600,
    ),
    textTheme: textTheme,
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: RituColors.backgroundPage,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: RituColors.sage500,
        foregroundColor: RituColors.white,
        disabledBackgroundColor: RituColors.sage500.withValues(alpha: 0.4),
        disabledForegroundColor: RituColors.white,
        minimumSize: const Size(double.infinity, 48),
        padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 12),
        shape: const StadiumBorder(),
        textStyle: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          height: 24 / 15,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: RituColors.fillElevated,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 24 / 15,
        color: RituColors.textDisabled,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: RituColors.borderSubtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: RituColors.sage500),
      ),
    ),
  );
}
