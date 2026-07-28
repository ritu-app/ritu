import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/daily_log_repository.dart';
import '../data/repositories/period_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/symptom_repository.dart';
import 'repository_providers.dart';

/// Read repositories from a [BuildContext] below a [ProviderScope].
extension RepositoryAccess on BuildContext {
  ProfileRepository get profiles =>
      ProviderScope.containerOf(this).read(profileRepositoryProvider);

  PeriodRepository get periods =>
      ProviderScope.containerOf(this).read(periodRepositoryProvider);

  SymptomRepository get symptoms =>
      ProviderScope.containerOf(this).read(symptomRepositoryProvider);

  DailyLogRepository get dailyLogs =>
      ProviderScope.containerOf(this).read(dailyLogRepositoryProvider);
}
