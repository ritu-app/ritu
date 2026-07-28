import 'package:flutter/material.dart';
import 'package:ritu/features/journal/journal_screen.dart';
import 'package:ritu/theme/ritu_colors.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'New user',
  type: JournalScreen,
  path: '[Screens]/Journal',
)
Widget journalNewUserUseCase(BuildContext context) {
  return const Scaffold(
    backgroundColor: RituColors.backgroundPage,
    body: SafeArea(child: JournalScreen()),
  );
}
