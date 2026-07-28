import 'package:flutter/material.dart';
import 'package:ritu/core/date_format.dart';
import 'package:ritu/features/journal/journal_screen.dart';
import 'package:ritu/theme/ritu_colors.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/seeded_app_scope.dart';

Widget _journalScaffold(Widget child) {
  return Scaffold(
    backgroundColor: RituColors.backgroundPage,
    body: SafeArea(child: child),
  );
}

@widgetbook.UseCase(
  name: 'New user',
  type: JournalScreen,
  path: '[Screens]/Journal',
)
Widget journalNewUserUseCase(BuildContext context) {
  return SeededAppScope(
    seed: seedOnboardedProfile,
    builder: (context) => _journalScaffold(const JournalScreen()),
  );
}

@widgetbook.UseCase(
  name: 'After first save',
  type: JournalScreen,
  path: '[Screens]/Journal',
)
Widget journalAfterFirstSaveUseCase(BuildContext context) {
  return SeededAppScope(
    seed: (repos) async {
      await seedOnboardedProfile(repos);
      await repos.journalEntries.upsert(
        loggedOn: DateTime.now(),
        body:
            'Felt really foggy today, couldn’t concentrate at all. Also weirdly emotional for no reason.',
      );
    },
    builder: (context) => _journalScaffold(const JournalScreen()),
  );
}

@widgetbook.UseCase(
  name: 'With past entries',
  type: JournalScreen,
  path: '[Screens]/Journal',
)
Widget journalWithPastEntriesUseCase(BuildContext context) {
  return SeededAppScope(
    seed: (repos) async {
      await seedOnboardedProfile(repos);
      await repos.journalEntries.upsert(
        loggedOn: DateTime.now(),
        body:
            'Felt really foggy today, couldn’t concentrate at all. Also weirdly emotional for no reason.',
      );
      await repos.journalEntries.upsert(
        loggedOn: dateOnly(DateTime.now()).subtract(const Duration(days: 1)),
        body:
            'Felt more energetic today. Went for a morning walk and had a productive day at work. Mild bloating in the evening.',
      );
      await repos.journalEntries.upsert(
        loggedOn: dateOnly(DateTime.now()).subtract(const Duration(days: 2)),
        body:
            'Had a burst of energy today. Took a brisk walk in the morning and accomplished a lot at work. Noticed slight stomach discomfort by evening.',
      );
    },
    builder: (context) => _journalScaffold(const JournalScreen()),
  );
}
