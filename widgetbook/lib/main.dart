import 'package:flutter/material.dart';
import 'package:ritu/theme/ritu_theme.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'main.directories.g.dart';

void main() {
  runApp(const WidgetbookApp());
}

/// The `@widgetbook.App` annotation generates [directories] (in
/// `main.directories.g.dart`) from every `@widgetbook.UseCase` found in this
/// package. Run `dart run build_runner build -d` after adding, renaming, or
/// removing a use-case.
@widgetbook.App()
class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: directories,
      addons: [
        ViewportAddon([
          Viewports.none,
          IosViewports.iPhoneSE,
          IosViewports.iPhone13,
          AndroidViewports.samsungGalaxyS20,
        ]),
        ThemeAddon<ThemeData>(
          themes: [WidgetbookTheme(name: 'Ritu', data: buildRituTheme())],
          themeBuilder: (context, theme, child) => MaterialApp(
            theme: theme,
            debugShowCheckedModeBanner: false,
            home: child,
          ),
        ),
        TextScaleAddon(min: 0.8, max: 1.6),
      ],
    );
  }
}
