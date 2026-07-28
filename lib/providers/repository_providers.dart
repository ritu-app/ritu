import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/daily_log_repository.dart';
import '../data/repositories/drift/drift_daily_log_repository.dart';
import '../data/repositories/drift/drift_period_repository.dart';
import '../data/repositories/drift/drift_profile_repository.dart';
import '../data/repositories/drift/drift_symptom_repository.dart';
import '../data/repositories/period_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/symptom_repository.dart';
import 'database_provider.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return DriftProfileRepository(ref.watch(databaseProvider));
});

final periodRepositoryProvider = Provider<PeriodRepository>((ref) {
  return DriftPeriodRepository(ref.watch(databaseProvider));
});

final symptomRepositoryProvider = Provider<SymptomRepository>((ref) {
  return DriftSymptomRepository(ref.watch(databaseProvider));
});

final dailyLogRepositoryProvider = Provider<DailyLogRepository>((ref) {
  return DriftDailyLogRepository(ref.watch(databaseProvider));
});
