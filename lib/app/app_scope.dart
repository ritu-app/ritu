import 'package:flutter/material.dart';

import '../data/repositories/daily_log_repository.dart';
import '../data/repositories/period_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/symptom_repository.dart';

/// Provides repositories and app-level actions to the widget tree.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.profileRepository,
    required this.periodRepository,
    required this.symptomRepository,
    required this.dailyLogRepository,
    required this.restartApp,
    required super.child,
  });

  final ProfileRepository profileRepository;
  final PeriodRepository periodRepository;
  final SymptomRepository symptomRepository;
  final DailyLogRepository dailyLogRepository;

  /// Remounts the root bootstrap (e.g. after wiping local data).
  final VoidCallback restartApp;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree');
    return scope!;
  }

  static ProfileRepository profiles(BuildContext context) {
    return of(context).profileRepository;
  }

  static PeriodRepository periods(BuildContext context) {
    return of(context).periodRepository;
  }

  static SymptomRepository symptoms(BuildContext context) {
    return of(context).symptomRepository;
  }

  static DailyLogRepository dailyLogs(BuildContext context) {
    return of(context).dailyLogRepository;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) {
    return profileRepository != oldWidget.profileRepository ||
        periodRepository != oldWidget.periodRepository ||
        symptomRepository != oldWidget.symptomRepository ||
        dailyLogRepository != oldWidget.dailyLogRepository ||
        restartApp != oldWidget.restartApp;
  }
}
