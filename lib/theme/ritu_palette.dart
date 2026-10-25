import 'package:flutter/material.dart';

import 'ritu_colors.dart';

/// Semantic colors for one brightness.
///
/// Light values are the colors the app already ships, so light mode stays
/// put. Dark values come from the Figma semantic boards (background, text,
/// icon, border, fill, cycle, and the dark gradient pairs).
///
/// A few light product colors differ from the board's bound primitive and
/// stay as they are: fill-attention, fill-critical, icon attention, icon
/// critical, icon info, and blush-embrace stop 1. Heatmap and terracotta
/// button colors are the same in both palettes because the boards do not
/// include them. Border-focus dark (mist-sage-300) was not in the variable
/// export, so it is not a field yet.
///
/// Gold text that used [gradientGh2] as a flat color should use
/// [textAttention]. The gradient fields themselves swap to the dark gradient
/// pairs (soft-horizon to ember-sage, verdant-bloom to forest-twilight,
/// rose-whisper to rose-ember, meadow-light to midnight-meadow, golden-hour
/// to amber-glow, moonlit-lilac to twilight-lavender, blush-embrace to
/// terracotta-hearth).
class RituPalette extends ThemeExtension<RituPalette> {
  const RituPalette({
    required this.brightness,
    required this.backgroundPage,
    required this.sage500,
    required this.sage600,
    required this.meadow600,
    required this.textPositive,
    required this.borderPositive,
    required this.neutral500,
    required this.neutral600,
    required this.textSecondary,
    required this.textDisabled,
    required this.textMuted,
    required this.textPrimary,
    required this.textTertiary,
    required this.textInverse,
    required this.textQuaternary,
    required this.textOnAccent,
    required this.textOnBrand,
    required this.textAttention,
    required this.textInfo,
    required this.borderSubtle,
    required this.borderDefault,
    required this.borderStrong,
    required this.borderDisabled,
    required this.borderBrand,
    required this.borderAttention,
    required this.borderCritical,
    required this.borderInfo,
    required this.fillElevated,
    required this.fillSecondary,
    required this.fillSecondaryHover,
    required this.fillMuted,
    required this.fillSubtle,
    required this.fillAccent,
    required this.fillAccentHover,
    required this.fillBrandHover,
    required this.fillBrandPressed,
    required this.terracottaButton,
    required this.fillInfo,
    required this.fillPositive,
    required this.fillPositiveSecondary,
    required this.fillAttention,
    required this.fillAttentionSecondary,
    required this.fillCritical,
    required this.fillCriticalSecondary,
    required this.fillInfoSecondary,
    required this.iconPrimary,
    required this.iconSecondary,
    required this.iconTertiary,
    required this.iconDisabled,
    required this.iconBrand,
    required this.iconInverse,
    required this.iconPositive,
    required this.iconAttention,
    required this.iconInfo,
    required this.iconCritical,
    required this.textCritical,
    required this.heatmapLow,
    required this.heatmapOkay,
    required this.heatmapHigh,
    required this.heatmapNoData,
    required this.cycleMenstrual,
    required this.cycleFollicular,
    required this.cycleOvulation,
    required this.cycleLuteal,
    required this.rosewood900,
    required this.gradientSh1,
    required this.gradientSh2,
    required this.gradientSh3,
    required this.gradientMl1,
    required this.gradientMl2,
    required this.gradientRw1,
    required this.gradientRw2,
    required this.gradientGh1,
    required this.gradientGh2,
    required this.gradientLilac1,
    required this.gradientLilac2,
    required this.gradientBe1,
    required this.gradientBe2,
    required this.gradientVb1,
    required this.gradientVb2,
    required this.gradientVb3,
    required this.white,
    required this.divider,
    required this.backgroundElevated,
    required this.backgroundSubtle,
    required this.backgroundBrand,
    required this.backgroundAccent,
    required this.backgroundInverse,
    required this.backgroundOverlay,
    required this.barrier,
  });

  static const light = RituPalette(
    brightness: Brightness.light,
    backgroundPage: RituColors.backgroundPage,
    sage500: RituColors.sage500,
    sage600: RituColors.sage600,
    meadow600: RituColors.meadow600,
    textPositive: RituColors.textPositive,
    borderPositive: RituColors.borderPositive,
    neutral500: RituColors.neutral500,
    neutral600: RituColors.neutral600,
    textSecondary: RituColors.textSecondary,
    textDisabled: RituColors.textDisabled,
    textMuted: RituColors.textMuted,
    textPrimary: RituColors.textPrimary,
    textTertiary: RituColors.textTertiary,
    textInverse: RituColors.textInverse,
    textQuaternary: Color(0xFFC8C1BC),
    textOnAccent: Color(0xFF322F2D),
    textOnBrand: Color(0xFFFFFFFF),
    textAttention: Color(0xFFB09149),
    textInfo: Color(0xFF7E7393),
    borderSubtle: RituColors.borderSubtle,
    borderDefault: Color(0xFFE2DDD8),
    borderStrong: Color(0xFFC8C1BC),
    borderDisabled: RituColors.borderDisabled,
    borderBrand: Color(0xFF5F8F7A),
    borderAttention: Color(0xFFF2D38B),
    borderCritical: RituColors.borderCritical,
    borderInfo: Color(0xFFB9AECF),
    fillElevated: RituColors.fillElevated,
    fillSecondary: RituColors.fillSecondary,
    fillSecondaryHover: RituColors.fillSecondaryHover,
    fillMuted: RituColors.fillMuted,
    fillSubtle: RituColors.fillSubtle,
    fillAccent: RituColors.fillAccent,
    fillAccentHover: Color(0xFFE9CCC0),
    fillBrandHover: Color(0xFF4F7765),
    fillBrandPressed: RituColors.fillBrandPressed,
    terracottaButton: RituColors.terracottaButton,
    fillInfo: RituColors.fillInfo,
    fillPositive: Color(0xFFCFEFD5),
    fillPositiveSecondary: RituColors.fillPositiveSecondary,
    fillAttention: RituColors.fillAttention,
    fillAttentionSecondary: RituColors.fillAttentionSecondary,
    fillCritical: RituColors.fillCritical,
    fillCriticalSecondary: RituColors.fillCriticalSecondary,
    fillInfoSecondary: RituColors.fillInfoSecondary,
    iconPrimary: Color(0xFF4C4744),
    iconSecondary: Color(0xFF8A827D),
    iconTertiary: Color(0xFFA9A19B),
    iconDisabled: Color(0xFFC8C1BC),
    iconBrand: Color(0xFF5F8F7A),
    iconInverse: Color(0xFFFCFBFA),
    iconPositive: Color(0xFF6FA17C),
    iconAttention: RituColors.iconAttention,
    iconInfo: RituColors.iconInfo,
    iconCritical: RituColors.iconCritical,
    textCritical: RituColors.textCritical,
    heatmapLow: RituColors.heatmapLow,
    heatmapOkay: RituColors.heatmapOkay,
    heatmapHigh: RituColors.heatmapHigh,
    heatmapNoData: RituColors.heatmapNoData,
    cycleMenstrual: RituColors.cycleMenstrual,
    cycleFollicular: Color(0xFF8DBE9A),
    cycleOvulation: Color(0xFFF2D38B),
    cycleLuteal: Color(0xFFB9AECF),
    rosewood900: RituColors.rosewood900,
    gradientSh1: RituColors.gradientSh1,
    gradientSh2: RituColors.gradientSh2,
    gradientSh3: RituColors.gradientSh3,
    gradientMl1: RituColors.gradientMl1,
    gradientMl2: RituColors.gradientMl2,
    gradientRw1: RituColors.gradientRw1,
    gradientRw2: RituColors.gradientRw2,
    gradientGh1: RituColors.gradientGh1,
    gradientGh2: RituColors.gradientGh2,
    gradientLilac1: RituColors.gradientLilac1,
    gradientLilac2: RituColors.gradientLilac2,
    gradientBe1: RituColors.gradientBe1,
    gradientBe2: RituColors.gradientBe2,
    gradientVb1: RituColors.gradientVb1,
    gradientVb2: RituColors.gradientVb2,
    gradientVb3: RituColors.gradientVb3,
    white: RituColors.white,
    divider: RituColors.divider,
    backgroundElevated: Color(0xFFFCFBFA),
    backgroundSubtle: Color(0xFFF7FAF8),
    backgroundBrand: Color(0xFF5F8F7A),
    backgroundAccent: Color(0xFFFBF4F1),
    backgroundInverse: Color(0xFF322F2D),
    backgroundOverlay: Color(0xFF322F2D),
    barrier: Color(0xB3000000),
  );

  static const dark = RituPalette(
    brightness: Brightness.dark,
    backgroundPage: Color(0xFF1D1B1A),
    sage500: Color(0xFF4F7765),
    sage600: Color(0xFFB9D3C0),
    meadow600: Color(0xFFA1D1AA),
    textPositive: Color(0xFFA1D1AA),
    borderPositive: Color(0xFFA1D1AA),
    neutral500: Color(0xFFC8C1BC),
    neutral600: Color(0xFFE2DDD8),
    textSecondary: Color(0xFFE2DDD8),
    textDisabled: Color(0xFF69635F),
    textMuted: Color(0xFF575554),
    textPrimary: Color(0xFFFCFBFA),
    textTertiary: Color(0xFFC8C1BC),
    textInverse: Color(0xFF322F2D),
    textQuaternary: Color(0xFF8A827D),
    textOnAccent: Color(0xFFFCFBFA),
    textOnBrand: Color(0xFFFFFFFF),
    textAttention: Color(0xFFF5D985),
    textInfo: Color(0xFFC4B9D9),
    borderSubtle: Color(0xFF4C4744),
    borderDefault: Color(0xFF69635F),
    borderStrong: Color(0xFF8A827D),
    borderDisabled: Color(0xFF3F3A3A),
    borderBrand: Color(0xFFB9D3C0),
    borderAttention: Color(0xFFF5D985),
    borderCritical: Color(0xFFD59D9D),
    borderInfo: Color(0xFFC4B9D9),
    fillElevated: Color(0xFF322F2D),
    fillSecondary: Color(0xFF344E42),
    fillSecondaryHover: Color(0xFF416252),
    fillMuted: Color(0xFF252321),
    fillSubtle: Color(0xFF1D1B1A),
    fillAccent: Color(0xFFA27865),
    fillAccentHover: Color(0xFFC19680),
    fillBrandHover: Color(0xFF5F8F7A),
    fillBrandPressed: Color(0xFF92B1A3),
    terracottaButton: Color(0xFF825E4D),
    fillInfo: Color(0xFF7E7393),
    fillPositive: Color(0xFF6FA17C),
    fillPositiveSecondary: Color(0xFF30473A),
    fillAttention: Color(0xFFD7B764),
    fillAttentionSecondary: Color(0xFF624D22),
    fillCritical: Color(0xFFB16F6F),
    fillCriticalSecondary: Color(0xFF583333),
    fillInfoSecondary: Color(0xFF474056),
    iconPrimary: Color(0xFFFCFBFA),
    iconSecondary: Color(0xFFE2DDD8),
    iconTertiary: Color(0xFFC8C1BC),
    iconDisabled: Color(0xFF8A827D),
    iconBrand: Color(0xFF92B1A3),
    iconInverse: Color(0xFF322F2D),
    iconPositive: Color(0xFFA1D1AA),
    iconAttention: Color(0xFFF5D985),
    iconInfo: Color(0xFFC4B9D9),
    iconCritical: Color(0xFFD59D9D),
    textCritical: Color(0xFFE2B5B5),
    heatmapLow: Color(0xFFDDBEAD),
    heatmapOkay: Color(0xFFF5D985),
    heatmapHigh: Color(0xFFA1D1AA),
    heatmapNoData: Color(0xFFDADADA),
    cycleMenstrual: Color(0xFFD59D9D),
    cycleFollicular: Color(0xFFA1D1AA),
    cycleOvulation: Color(0xFFF5D985),
    cycleLuteal: Color(0xFFC4B9D9),
    rosewood900: Color(0xFF583333),
    gradientSh1: Color(0xFF304941),
    gradientSh2: Color(0xFF56685B),
    gradientSh3: Color(0xFF987665),
    gradientMl1: Color(0xFFA1D1AA),
    gradientMl2: Color(0xFF55776A),
    gradientRw1: Color(0xFFD59D9D),
    gradientRw2: Color(0xFF7A5A63),
    gradientGh1: Color(0xFFF2D38B),
    gradientGh2: Color(0xFFB88E52),
    gradientLilac1: Color(0xFFB9AECF),
    gradientLilac2: Color(0xFF75688F),
    gradientBe1: Color(0xFFE4C6B8),
    gradientBe2: Color(0xFFA88072),
    gradientVb1: Color(0xFF304941),
    gradientVb2: Color(0xFF4F7765),
    gradientVb3: Color(0xFF708978),
    white: Color(0xFFFFFFFF),
    divider: Color(0xFF4C4744),
    backgroundElevated: Color(0xFF4C4744),
    backgroundSubtle: Color(0xFF322F2D),
    backgroundBrand: Color(0xFF416252),
    backgroundAccent: Color(0xFF61453A),
    backgroundInverse: Color(0xFFFCFBFA),
    backgroundOverlay: Color(0xFF1D1B1A),
    barrier: Color(0xB31D1B1A),
  );

  final Brightness brightness;
  final Color backgroundPage;
  final Color sage500;
  final Color sage600;
  final Color meadow600;
  final Color textPositive;
  final Color borderPositive;
  final Color neutral500;
  final Color neutral600;
  final Color textSecondary;
  final Color textDisabled;
  final Color textMuted;
  final Color textPrimary;
  final Color textTertiary;
  final Color textInverse;
  final Color textQuaternary;
  final Color textOnAccent;
  final Color textOnBrand;
  final Color textAttention;
  final Color textInfo;
  final Color borderSubtle;
  final Color borderDefault;
  final Color borderStrong;
  final Color borderDisabled;
  final Color borderBrand;
  final Color borderAttention;
  final Color borderCritical;
  final Color borderInfo;
  final Color fillElevated;
  final Color fillSecondary;
  final Color fillSecondaryHover;
  final Color fillMuted;
  final Color fillSubtle;
  final Color fillAccent;
  final Color fillAccentHover;
  final Color fillBrandHover;
  final Color fillBrandPressed;
  final Color terracottaButton;
  final Color fillInfo;
  final Color fillPositive;
  final Color fillPositiveSecondary;
  final Color fillAttention;
  final Color fillAttentionSecondary;
  final Color fillCritical;
  final Color fillCriticalSecondary;
  final Color fillInfoSecondary;
  final Color iconPrimary;
  final Color iconSecondary;
  final Color iconTertiary;
  final Color iconDisabled;
  final Color iconBrand;
  final Color iconInverse;
  final Color iconPositive;
  final Color iconAttention;
  final Color iconInfo;
  final Color iconCritical;
  final Color textCritical;
  final Color heatmapLow;
  final Color heatmapOkay;
  final Color heatmapHigh;
  final Color heatmapNoData;
  final Color cycleMenstrual;
  final Color cycleFollicular;
  final Color cycleOvulation;
  final Color cycleLuteal;
  final Color rosewood900;
  final Color gradientSh1;
  final Color gradientSh2;
  final Color gradientSh3;
  final Color gradientMl1;
  final Color gradientMl2;
  final Color gradientRw1;
  final Color gradientRw2;
  final Color gradientGh1;
  final Color gradientGh2;
  final Color gradientLilac1;
  final Color gradientLilac2;
  final Color gradientBe1;
  final Color gradientBe2;
  final Color gradientVb1;
  final Color gradientVb2;
  final Color gradientVb3;
  final Color white;
  final Color divider;
  final Color backgroundElevated;
  final Color backgroundSubtle;
  final Color backgroundBrand;
  final Color backgroundAccent;
  final Color backgroundInverse;
  final Color backgroundOverlay;
  final Color barrier;

  @override
  RituPalette copyWith({
    Brightness? brightness,
    Color? backgroundPage,
    Color? sage500,
    Color? sage600,
    Color? meadow600,
    Color? textPositive,
    Color? borderPositive,
    Color? neutral500,
    Color? neutral600,
    Color? textSecondary,
    Color? textDisabled,
    Color? textMuted,
    Color? textPrimary,
    Color? textTertiary,
    Color? textInverse,
    Color? textQuaternary,
    Color? textOnAccent,
    Color? textOnBrand,
    Color? textAttention,
    Color? textInfo,
    Color? borderSubtle,
    Color? borderDefault,
    Color? borderStrong,
    Color? borderDisabled,
    Color? borderBrand,
    Color? borderAttention,
    Color? borderCritical,
    Color? borderInfo,
    Color? fillElevated,
    Color? fillSecondary,
    Color? fillSecondaryHover,
    Color? fillMuted,
    Color? fillSubtle,
    Color? fillAccent,
    Color? fillAccentHover,
    Color? fillBrandHover,
    Color? fillBrandPressed,
    Color? terracottaButton,
    Color? fillInfo,
    Color? fillPositive,
    Color? fillPositiveSecondary,
    Color? fillAttention,
    Color? fillAttentionSecondary,
    Color? fillCritical,
    Color? fillCriticalSecondary,
    Color? fillInfoSecondary,
    Color? iconPrimary,
    Color? iconSecondary,
    Color? iconTertiary,
    Color? iconDisabled,
    Color? iconBrand,
    Color? iconInverse,
    Color? iconPositive,
    Color? iconAttention,
    Color? iconInfo,
    Color? iconCritical,
    Color? textCritical,
    Color? heatmapLow,
    Color? heatmapOkay,
    Color? heatmapHigh,
    Color? heatmapNoData,
    Color? cycleMenstrual,
    Color? cycleFollicular,
    Color? cycleOvulation,
    Color? cycleLuteal,
    Color? rosewood900,
    Color? gradientSh1,
    Color? gradientSh2,
    Color? gradientSh3,
    Color? gradientMl1,
    Color? gradientMl2,
    Color? gradientRw1,
    Color? gradientRw2,
    Color? gradientGh1,
    Color? gradientGh2,
    Color? gradientLilac1,
    Color? gradientLilac2,
    Color? gradientBe1,
    Color? gradientBe2,
    Color? gradientVb1,
    Color? gradientVb2,
    Color? gradientVb3,
    Color? white,
    Color? divider,
    Color? backgroundElevated,
    Color? backgroundSubtle,
    Color? backgroundBrand,
    Color? backgroundAccent,
    Color? backgroundInverse,
    Color? backgroundOverlay,
    Color? barrier,
  }) {
    return RituPalette(
      brightness: brightness ?? this.brightness,
      backgroundPage: backgroundPage ?? this.backgroundPage,
      sage500: sage500 ?? this.sage500,
      sage600: sage600 ?? this.sage600,
      meadow600: meadow600 ?? this.meadow600,
      textPositive: textPositive ?? this.textPositive,
      borderPositive: borderPositive ?? this.borderPositive,
      neutral500: neutral500 ?? this.neutral500,
      neutral600: neutral600 ?? this.neutral600,
      textSecondary: textSecondary ?? this.textSecondary,
      textDisabled: textDisabled ?? this.textDisabled,
      textMuted: textMuted ?? this.textMuted,
      textPrimary: textPrimary ?? this.textPrimary,
      textTertiary: textTertiary ?? this.textTertiary,
      textInverse: textInverse ?? this.textInverse,
      textQuaternary: textQuaternary ?? this.textQuaternary,
      textOnAccent: textOnAccent ?? this.textOnAccent,
      textOnBrand: textOnBrand ?? this.textOnBrand,
      textAttention: textAttention ?? this.textAttention,
      textInfo: textInfo ?? this.textInfo,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderDefault: borderDefault ?? this.borderDefault,
      borderStrong: borderStrong ?? this.borderStrong,
      borderDisabled: borderDisabled ?? this.borderDisabled,
      borderBrand: borderBrand ?? this.borderBrand,
      borderAttention: borderAttention ?? this.borderAttention,
      borderCritical: borderCritical ?? this.borderCritical,
      borderInfo: borderInfo ?? this.borderInfo,
      fillElevated: fillElevated ?? this.fillElevated,
      fillSecondary: fillSecondary ?? this.fillSecondary,
      fillSecondaryHover: fillSecondaryHover ?? this.fillSecondaryHover,
      fillMuted: fillMuted ?? this.fillMuted,
      fillSubtle: fillSubtle ?? this.fillSubtle,
      fillAccent: fillAccent ?? this.fillAccent,
      fillAccentHover: fillAccentHover ?? this.fillAccentHover,
      fillBrandHover: fillBrandHover ?? this.fillBrandHover,
      fillBrandPressed: fillBrandPressed ?? this.fillBrandPressed,
      terracottaButton: terracottaButton ?? this.terracottaButton,
      fillInfo: fillInfo ?? this.fillInfo,
      fillPositive: fillPositive ?? this.fillPositive,
      fillPositiveSecondary:
          fillPositiveSecondary ?? this.fillPositiveSecondary,
      fillAttention: fillAttention ?? this.fillAttention,
      fillAttentionSecondary:
          fillAttentionSecondary ?? this.fillAttentionSecondary,
      fillCritical: fillCritical ?? this.fillCritical,
      fillCriticalSecondary:
          fillCriticalSecondary ?? this.fillCriticalSecondary,
      fillInfoSecondary: fillInfoSecondary ?? this.fillInfoSecondary,
      iconPrimary: iconPrimary ?? this.iconPrimary,
      iconSecondary: iconSecondary ?? this.iconSecondary,
      iconTertiary: iconTertiary ?? this.iconTertiary,
      iconDisabled: iconDisabled ?? this.iconDisabled,
      iconBrand: iconBrand ?? this.iconBrand,
      iconInverse: iconInverse ?? this.iconInverse,
      iconPositive: iconPositive ?? this.iconPositive,
      iconAttention: iconAttention ?? this.iconAttention,
      iconInfo: iconInfo ?? this.iconInfo,
      iconCritical: iconCritical ?? this.iconCritical,
      textCritical: textCritical ?? this.textCritical,
      heatmapLow: heatmapLow ?? this.heatmapLow,
      heatmapOkay: heatmapOkay ?? this.heatmapOkay,
      heatmapHigh: heatmapHigh ?? this.heatmapHigh,
      heatmapNoData: heatmapNoData ?? this.heatmapNoData,
      cycleMenstrual: cycleMenstrual ?? this.cycleMenstrual,
      cycleFollicular: cycleFollicular ?? this.cycleFollicular,
      cycleOvulation: cycleOvulation ?? this.cycleOvulation,
      cycleLuteal: cycleLuteal ?? this.cycleLuteal,
      rosewood900: rosewood900 ?? this.rosewood900,
      gradientSh1: gradientSh1 ?? this.gradientSh1,
      gradientSh2: gradientSh2 ?? this.gradientSh2,
      gradientSh3: gradientSh3 ?? this.gradientSh3,
      gradientMl1: gradientMl1 ?? this.gradientMl1,
      gradientMl2: gradientMl2 ?? this.gradientMl2,
      gradientRw1: gradientRw1 ?? this.gradientRw1,
      gradientRw2: gradientRw2 ?? this.gradientRw2,
      gradientGh1: gradientGh1 ?? this.gradientGh1,
      gradientGh2: gradientGh2 ?? this.gradientGh2,
      gradientLilac1: gradientLilac1 ?? this.gradientLilac1,
      gradientLilac2: gradientLilac2 ?? this.gradientLilac2,
      gradientBe1: gradientBe1 ?? this.gradientBe1,
      gradientBe2: gradientBe2 ?? this.gradientBe2,
      gradientVb1: gradientVb1 ?? this.gradientVb1,
      gradientVb2: gradientVb2 ?? this.gradientVb2,
      gradientVb3: gradientVb3 ?? this.gradientVb3,
      white: white ?? this.white,
      divider: divider ?? this.divider,
      backgroundElevated: backgroundElevated ?? this.backgroundElevated,
      backgroundSubtle: backgroundSubtle ?? this.backgroundSubtle,
      backgroundBrand: backgroundBrand ?? this.backgroundBrand,
      backgroundAccent: backgroundAccent ?? this.backgroundAccent,
      backgroundInverse: backgroundInverse ?? this.backgroundInverse,
      backgroundOverlay: backgroundOverlay ?? this.backgroundOverlay,
      barrier: barrier ?? this.barrier,
    );
  }

  @override
  RituPalette lerp(ThemeExtension<RituPalette>? other, double t) {
    if (other is! RituPalette) return this;
    return RituPalette(
      brightness: t < 0.5 ? brightness : other.brightness,
      backgroundPage: Color.lerp(backgroundPage, other.backgroundPage, t)!,
      sage500: Color.lerp(sage500, other.sage500, t)!,
      sage600: Color.lerp(sage600, other.sage600, t)!,
      meadow600: Color.lerp(meadow600, other.meadow600, t)!,
      textPositive: Color.lerp(textPositive, other.textPositive, t)!,
      borderPositive: Color.lerp(borderPositive, other.borderPositive, t)!,
      neutral500: Color.lerp(neutral500, other.neutral500, t)!,
      neutral600: Color.lerp(neutral600, other.neutral600, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textInverse: Color.lerp(textInverse, other.textInverse, t)!,
      textQuaternary: Color.lerp(textQuaternary, other.textQuaternary, t)!,
      textOnAccent: Color.lerp(textOnAccent, other.textOnAccent, t)!,
      textOnBrand: Color.lerp(textOnBrand, other.textOnBrand, t)!,
      textAttention: Color.lerp(textAttention, other.textAttention, t)!,
      textInfo: Color.lerp(textInfo, other.textInfo, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      borderDisabled: Color.lerp(borderDisabled, other.borderDisabled, t)!,
      borderBrand: Color.lerp(borderBrand, other.borderBrand, t)!,
      borderAttention: Color.lerp(borderAttention, other.borderAttention, t)!,
      borderCritical: Color.lerp(borderCritical, other.borderCritical, t)!,
      borderInfo: Color.lerp(borderInfo, other.borderInfo, t)!,
      fillElevated: Color.lerp(fillElevated, other.fillElevated, t)!,
      fillSecondary: Color.lerp(fillSecondary, other.fillSecondary, t)!,
      fillSecondaryHover: Color.lerp(
        fillSecondaryHover,
        other.fillSecondaryHover,
        t,
      )!,
      fillMuted: Color.lerp(fillMuted, other.fillMuted, t)!,
      fillSubtle: Color.lerp(fillSubtle, other.fillSubtle, t)!,
      fillAccent: Color.lerp(fillAccent, other.fillAccent, t)!,
      fillAccentHover: Color.lerp(fillAccentHover, other.fillAccentHover, t)!,
      fillBrandHover: Color.lerp(fillBrandHover, other.fillBrandHover, t)!,
      fillBrandPressed: Color.lerp(
        fillBrandPressed,
        other.fillBrandPressed,
        t,
      )!,
      terracottaButton: Color.lerp(
        terracottaButton,
        other.terracottaButton,
        t,
      )!,
      fillInfo: Color.lerp(fillInfo, other.fillInfo, t)!,
      fillPositive: Color.lerp(fillPositive, other.fillPositive, t)!,
      fillPositiveSecondary: Color.lerp(
        fillPositiveSecondary,
        other.fillPositiveSecondary,
        t,
      )!,
      fillAttention: Color.lerp(fillAttention, other.fillAttention, t)!,
      fillAttentionSecondary: Color.lerp(
        fillAttentionSecondary,
        other.fillAttentionSecondary,
        t,
      )!,
      fillCritical: Color.lerp(fillCritical, other.fillCritical, t)!,
      fillCriticalSecondary: Color.lerp(
        fillCriticalSecondary,
        other.fillCriticalSecondary,
        t,
      )!,
      fillInfoSecondary: Color.lerp(
        fillInfoSecondary,
        other.fillInfoSecondary,
        t,
      )!,
      iconPrimary: Color.lerp(iconPrimary, other.iconPrimary, t)!,
      iconSecondary: Color.lerp(iconSecondary, other.iconSecondary, t)!,
      iconTertiary: Color.lerp(iconTertiary, other.iconTertiary, t)!,
      iconDisabled: Color.lerp(iconDisabled, other.iconDisabled, t)!,
      iconBrand: Color.lerp(iconBrand, other.iconBrand, t)!,
      iconInverse: Color.lerp(iconInverse, other.iconInverse, t)!,
      iconPositive: Color.lerp(iconPositive, other.iconPositive, t)!,
      iconAttention: Color.lerp(iconAttention, other.iconAttention, t)!,
      iconInfo: Color.lerp(iconInfo, other.iconInfo, t)!,
      iconCritical: Color.lerp(iconCritical, other.iconCritical, t)!,
      textCritical: Color.lerp(textCritical, other.textCritical, t)!,
      heatmapLow: Color.lerp(heatmapLow, other.heatmapLow, t)!,
      heatmapOkay: Color.lerp(heatmapOkay, other.heatmapOkay, t)!,
      heatmapHigh: Color.lerp(heatmapHigh, other.heatmapHigh, t)!,
      heatmapNoData: Color.lerp(heatmapNoData, other.heatmapNoData, t)!,
      cycleMenstrual: Color.lerp(cycleMenstrual, other.cycleMenstrual, t)!,
      cycleFollicular: Color.lerp(cycleFollicular, other.cycleFollicular, t)!,
      cycleOvulation: Color.lerp(cycleOvulation, other.cycleOvulation, t)!,
      cycleLuteal: Color.lerp(cycleLuteal, other.cycleLuteal, t)!,
      rosewood900: Color.lerp(rosewood900, other.rosewood900, t)!,
      gradientSh1: Color.lerp(gradientSh1, other.gradientSh1, t)!,
      gradientSh2: Color.lerp(gradientSh2, other.gradientSh2, t)!,
      gradientSh3: Color.lerp(gradientSh3, other.gradientSh3, t)!,
      gradientMl1: Color.lerp(gradientMl1, other.gradientMl1, t)!,
      gradientMl2: Color.lerp(gradientMl2, other.gradientMl2, t)!,
      gradientRw1: Color.lerp(gradientRw1, other.gradientRw1, t)!,
      gradientRw2: Color.lerp(gradientRw2, other.gradientRw2, t)!,
      gradientGh1: Color.lerp(gradientGh1, other.gradientGh1, t)!,
      gradientGh2: Color.lerp(gradientGh2, other.gradientGh2, t)!,
      gradientLilac1: Color.lerp(gradientLilac1, other.gradientLilac1, t)!,
      gradientLilac2: Color.lerp(gradientLilac2, other.gradientLilac2, t)!,
      gradientBe1: Color.lerp(gradientBe1, other.gradientBe1, t)!,
      gradientBe2: Color.lerp(gradientBe2, other.gradientBe2, t)!,
      gradientVb1: Color.lerp(gradientVb1, other.gradientVb1, t)!,
      gradientVb2: Color.lerp(gradientVb2, other.gradientVb2, t)!,
      gradientVb3: Color.lerp(gradientVb3, other.gradientVb3, t)!,
      white: Color.lerp(white, other.white, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      backgroundElevated: Color.lerp(
        backgroundElevated,
        other.backgroundElevated,
        t,
      )!,
      backgroundSubtle: Color.lerp(
        backgroundSubtle,
        other.backgroundSubtle,
        t,
      )!,
      backgroundBrand: Color.lerp(backgroundBrand, other.backgroundBrand, t)!,
      backgroundAccent: Color.lerp(
        backgroundAccent,
        other.backgroundAccent,
        t,
      )!,
      backgroundInverse: Color.lerp(
        backgroundInverse,
        other.backgroundInverse,
        t,
      )!,
      backgroundOverlay: Color.lerp(
        backgroundOverlay,
        other.backgroundOverlay,
        t,
      )!,
      barrier: Color.lerp(barrier, other.barrier, t)!,
    );
  }
}

extension RituPaletteContext on BuildContext {
  /// Active palette. Falls back to light when a test theme has no extension.
  RituPalette get ritu =>
      Theme.of(this).extension<RituPalette>() ?? RituPalette.light;
}
