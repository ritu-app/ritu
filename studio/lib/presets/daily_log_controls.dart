import 'package:ritu/core/date_format.dart';
import 'package:ritu/data/repositories/memory/memory_daily_log_repository.dart';

import '../scope/ritu_repos.dart';

Future<void> applyDailyLogState({
  required RituRepos repos,
  required DateTime simulatedToday,
  required int loggedDaysCount,
  required bool loggedToday,
}) async {
  final dailyLogs = repos.dailyLogs as MemoryDailyLogRepository;
  await dailyLogs.clearAll();

  if (loggedDaysCount <= 0) return;

  final today = dateOnly(simulatedToday);
  final startOffset = loggedToday ? 0 : 1;

  for (var i = 0; i < loggedDaysCount; i++) {
    await dailyLogs.upsert(
      loggedOn: today.subtract(Duration(days: startOffset + i)),
      flowIntensity: 'Light',
      moods: const ['Calm'],
    );
  }
}
