import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'luna_colors.dart';

ThemeData buildLunaTheme() {
  final textTheme = GoogleFonts.dmSansTextTheme().apply(
    bodyColor: LunaColors.neutral600,
    displayColor: LunaColors.sage600,
  );

  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: LunaColors.backgroundPage,
    colorScheme: ColorScheme.light(
      primary: LunaColors.sage500,
      onPrimary: LunaColors.white,
      surface: LunaColors.backgroundPage,
      onSurface: LunaColors.sage600,
    ),
    textTheme: textTheme,
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: LunaColors.backgroundPage,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: LunaColors.sage500,
        foregroundColor: LunaColors.white,
        disabledBackgroundColor: LunaColors.sage500.withValues(alpha: 0.4),
        disabledForegroundColor: LunaColors.white,
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
      fillColor: LunaColors.fillElevated,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 24 / 15,
        color: LunaColors.textDisabled,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: LunaColors.borderSubtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: LunaColors.sage500),
      ),
    ),
  );
}
