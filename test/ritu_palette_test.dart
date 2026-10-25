import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ritu/data/models/app_appearance.dart';
import 'package:ritu/theme/ritu_colors.dart';
import 'package:ritu/theme/ritu_palette.dart';
import 'package:ritu/theme/ritu_theme.dart';

void main() {
  test('light palette keeps the colors screens already use', () {
    expect(RituPalette.light.textPrimary, RituColors.textPrimary);
    expect(RituPalette.light.fillAttention, RituColors.fillAttention);
    expect(RituPalette.light.fillCritical, RituColors.fillCritical);
    expect(RituPalette.light.sage500, RituColors.sage500);
    expect(RituPalette.light.iconAttention, RituColors.iconAttention);
    expect(RituPalette.light.gradientBe1, RituColors.gradientBe1);
    expect(RituPalette.light.barrier, const Color(0xB3000000));
  });

  test('dark palette follows the semantic boards', () {
    expect(RituPalette.dark.backgroundPage, const Color(0xFF1D1B1A));
    expect(RituPalette.dark.textPrimary, const Color(0xFFFCFBFA));
    expect(RituPalette.dark.textSecondary, const Color(0xFFE2DDD8));
    expect(RituPalette.dark.fillSecondary, const Color(0xFF344E42));
    expect(RituPalette.dark.fillBrandPressed, const Color(0xFF92B1A3));
    expect(RituPalette.dark.borderDefault, const Color(0xFF69635F));
    expect(RituPalette.dark.cycleMenstrual, const Color(0xFFD59D9D));
    expect(RituPalette.dark.cycleOvulation, const Color(0xFFF5D985));
    expect(RituPalette.dark.textAttention, const Color(0xFFF5D985));
    expect(RituPalette.dark.gradientSh1, const Color(0xFF304941));
    expect(RituPalette.dark.gradientSh3, const Color(0xFF987665));
    expect(RituPalette.dark.gradientVb2, const Color(0xFF4F7765));
    expect(RituPalette.dark.barrier, const Color(0xB31D1B1A));
    expect(RituPalette.dark.fillSubtle, const Color(0xFF1D1B1A));
    expect(RituPalette.dark.textDisabled, const Color(0xFF69635F));
    expect(RituPalette.dark.textQuaternary, const Color(0xFF8A827D));
    expect(RituPalette.dark.textOnBrand, const Color(0xFFFFFFFF));
    expect(RituPalette.dark.heatmapLow, RituColors.heatmapLow);
  });

  test('appearance maps onto theme mode', () {
    expect(themeModeFor(AppAppearance.system), ThemeMode.system);
    expect(themeModeFor(AppAppearance.light), ThemeMode.light);
    expect(themeModeFor(AppAppearance.dark), ThemeMode.dark);
  });

  testWidgets('a screen reads the palette from the theme', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildRituTheme(RituPalette.dark),
        home: Builder(
          builder: (context) => ColoredBox(
            key: const Key('page'),
            color: context.ritu.backgroundPage,
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );

    final box = tester.widget<ColoredBox>(find.byKey(const Key('page')));
    expect(box.color, RituPalette.dark.backgroundPage);
  });
}
