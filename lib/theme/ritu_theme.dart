import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/models/app_appearance.dart';
import 'ritu_palette.dart';

ThemeMode themeModeFor(AppAppearance appearance) => switch (appearance) {
  AppAppearance.system => ThemeMode.system,
  AppAppearance.light => ThemeMode.light,
  AppAppearance.dark => ThemeMode.dark,
};

ThemeData buildRituTheme([RituPalette palette = RituPalette.light]) {
  final textTheme = GoogleFonts.dmSansTextTheme().apply(
    bodyColor: palette.neutral600,
    displayColor: palette.sage600,
  );
  final overlay = palette.brightness == Brightness.dark
      ? SystemUiOverlayStyle.light
      : SystemUiOverlayStyle.dark;

  return ThemeData(
    useMaterial3: true,
    brightness: palette.brightness,
    extensions: [palette],
    scaffoldBackgroundColor: palette.backgroundPage,
    colorScheme: ColorScheme(
      brightness: palette.brightness,
      primary: palette.sage500,
      onPrimary: palette.white,
      secondary: palette.sage600,
      onSecondary: palette.white,
      error: palette.textCritical,
      onError: palette.textInverse,
      surface: palette.backgroundPage,
      onSurface: palette.sage600,
    ),
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      systemOverlayStyle: overlay,
      backgroundColor: palette.backgroundPage,
      foregroundColor: palette.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: palette.sage500,
        foregroundColor: palette.white,
        disabledBackgroundColor: palette.sage500.withValues(alpha: 0.4),
        disabledForegroundColor: palette.white,
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
      fillColor: palette.fillElevated,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 24 / 15,
        color: palette.textDisabled,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: palette.borderSubtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: palette.sage500),
      ),
    ),
  );
}
