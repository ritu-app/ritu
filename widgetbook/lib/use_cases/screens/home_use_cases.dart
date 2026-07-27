import 'package:flutter/material.dart';
import 'package:ritu/data/repositories/period_repository.dart';
import 'package:ritu/features/home/home_screen.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/seeded_app_scope.dart';

final _loggingSince = DateTime.now().subtract(const Duration(days: 10));

@widgetbook.UseCase(
  name: 'Not logged today',
  type: HomeScreen,
  path: '[Screens]/Home',
)
Widget homeNotLoggedUseCase(BuildContext context) {
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
    },
    builder: (context) => HomeScreen(name: 'Maya', loggingSince: _loggingSince),
  );
}

@widgetbook.UseCase(
  name: 'Logged today',
  type: HomeScreen,
  path: '[Screens]/Home',
)
Widget homeLoggedTodayUseCase(BuildContext context) {
  return SeededAppScope(
    seed: (repos) async {
      await seedOnboardedProfile(repos);
      await repos.periods.upsertPeriod(
        startedOn: DateTime.now().subtract(const Duration(days: 12)),
        source: PeriodSources.onboardingLast,
      );
      await repos.dailyLogs.upsert(
        loggedOn: DateTime.now(),
        flowIntensity: 'Light',
        moods: const ['Calm', 'Content'],
        energyLevel: 'Moderate',
        sleepQuality: 'Good',
        symptoms: const ['Bloating'],
      );
      // A couple of prior days so the streak flame shows as active.
      await repos.dailyLogs.upsert(
        loggedOn: DateTime.now().subtract(const Duration(days: 1)),
        flowIntensity: 'Light',
      );
      await repos.dailyLogs.upsert(
        loggedOn: DateTime.now().subtract(const Duration(days: 2)),
        flowIntensity: 'Medium',
      );
    },
    builder: (context) => HomeScreen(name: 'Maya', loggingSince: _loggingSince),
  );
}

@widgetbook.UseCase(
  name: 'No period logged yet',
  type: HomeScreen,
  path: '[Screens]/Home',
)
Widget homeEmptyUseCase(BuildContext context) {
  return SeededAppScope(
    seed: (repos) => seedOnboardedProfile(repos, name: 'Maya'),
    builder: (context) => HomeScreen(name: 'Maya', loggingSince: _loggingSince),
  );
}
