import 'package:ritu/core/date_format.dart';
import 'package:ritu/data/repositories/memory/memory_daily_log_repository.dart';

import '../scope/ritu_repos.dart';

const _moods = ['Calm', 'Happy', 'Content', 'Focused', 'Restless', 'Flat'];
const _flows = ['Light', 'Medium', 'Spotting', 'Heavy'];

Future<void> applyDailyLogState({
  required RituRepos repos,
  required DateTime simulatedToday,
  required int loggedDaysCount,
  required bool loggedToday,
  int generation = 0,
}) async {
  final dailyLogs = repos.dailyLogs as MemoryDailyLogRepository;
  await dailyLogs.clearAll();

  final today = dateOnly(simulatedToday);
  if (loggedToday) {
    await dailyLogs.upsert(
      loggedOn: today,
      flowIntensity: _flows[generation % _flows.length],
      moods: [_moods[generation % _moods.length]],
    );
  }

  for (var i = 0; i < loggedDaysCount; i++) {
    final offset = i + 1;
    await dailyLogs.upsert(
      loggedOn: today.subtract(Duration(days: offset)),
      flowIntensity: _flows[(generation + offset) % _flows.length],
      moods: [_moods[(generation + offset) % _moods.length]],
    );
  }
}
