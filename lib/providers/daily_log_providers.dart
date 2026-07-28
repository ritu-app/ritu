import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/date_format.dart';
import '../data/models/daily_log_entry.dart';
import 'repository_providers.dart';

final todayLogProvider = StreamProvider<DailyLogEntry?>((ref) {
  return ref.watch(dailyLogRepositoryProvider).watchByDate(DateTime.now());
});

final dailyLogByDateProvider = StreamProvider.family<DailyLogEntry?, DateTime>((
  ref,
  date,
) {
  return ref.watch(dailyLogRepositoryProvider).watchByDate(dateOnly(date));
});

final totalLoggedDaysProvider = StreamProvider<int>((ref) {
  return ref.watch(dailyLogRepositoryProvider).watchTotalLoggedDays();
});

final currentStreakProvider = StreamProvider<int>((ref) {
  return ref.watch(dailyLogRepositoryProvider).watchCurrentStreak();
});
