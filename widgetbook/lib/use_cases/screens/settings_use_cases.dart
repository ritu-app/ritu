import 'package:flutter/material.dart';
import 'package:ritu/data/repositories/period_repository.dart';
import 'package:ritu/features/settings/custom_symptoms_screen.dart';
import 'package:ritu/features/settings/period_history_screen.dart';
import 'package:ritu/features/settings/period_started_screen.dart';
import 'package:ritu/features/settings/settings_screen.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/seeded_app_scope.dart';

@widgetbook.UseCase(
  name: 'With history',
  type: SettingsScreen,
  path: '[Screens]/Settings',
)
Widget settingsWithHistoryUseCase(BuildContext context) {
  return SeededAppScope(
    seed: (repos) async {
      await seedOnboardedProfile(repos);
      await repos.periods.upsertPeriod(
        startedOn: DateTime.now().subtract(const Duration(days: 12)),
        source: PeriodSources.onboardingLast,
      );
      await repos.periods.addPastStart(
        startedOn: DateTime.now().subtract(const Duration(days: 40)),
        typicalPeriodDays: 5,
      );
      await repos.symptoms.addSymptom('Jaw tension');
    },
    builder: (context) => const SettingsScreen(),
  );
}

@widgetbook.UseCase(
  name: 'Empty state',
  type: SettingsScreen,
  path: '[Screens]/Settings',
)
Widget settingsEmptyUseCase(BuildContext context) {
  return SeededAppScope(
    seed: (repos) => seedOnboardedProfile(repos),
    builder: (context) => const SettingsScreen(),
  );
}

@widgetbook.UseCase(
  name: 'Default',
  type: PeriodStartedScreen,
  path: '[Screens]/Settings',
)
Widget periodStartedUseCase(BuildContext context) {
  return SeededAppScope(
    seed: (repos) async {
      await seedOnboardedProfile(repos);
      await repos.periods.upsertPeriod(
        startedOn: DateTime.now().subtract(const Duration(days: 12)),
        source: PeriodSources.onboardingLast,
      );
    },
    builder: (context) => const PeriodStartedScreen(),
  );
}

@widgetbook.UseCase(
  name: 'With past dates',
  type: PeriodHistoryScreen,
  path: '[Screens]/Settings',
)
Widget periodHistoryUseCase(BuildContext context) {
  return SeededAppScope(
    seed: (repos) async {
      await seedOnboardedProfile(repos);
      await repos.periods.upsertPeriod(
        startedOn: DateTime.now().subtract(const Duration(days: 12)),
        source: PeriodSources.onboardingLast,
      );
      await repos.periods.addPastStart(
        startedOn: DateTime.now().subtract(const Duration(days: 40)),
        typicalPeriodDays: 5,
      );
      await repos.periods.addPastStart(
        startedOn: DateTime.now().subtract(const Duration(days: 68)),
        typicalPeriodDays: 5,
      );
    },
    builder: (context) => const PeriodHistoryScreen(),
  );
}

@widgetbook.UseCase(
  name: 'Empty state',
  type: CustomSymptomsScreen,
  path: '[Screens]/Settings',
)
Widget customSymptomsEmptyUseCase(BuildContext context) {
  return SeededAppScope(
    seed: (repos) => seedOnboardedProfile(repos),
    builder: (context) => const CustomSymptomsScreen(),
  );
}

@widgetbook.UseCase(
  name: 'With symptoms',
  type: CustomSymptomsScreen,
  path: '[Screens]/Settings',
)
Widget customSymptomsWithDataUseCase(BuildContext context) {
  return SeededAppScope(
    seed: (repos) async {
      await seedOnboardedProfile(repos);
      await repos.symptoms.addSymptom('Jaw tension');
      await repos.symptoms.addSymptom('Cold hands');
    },
    builder: (context) => const CustomSymptomsScreen(),
  );
}
