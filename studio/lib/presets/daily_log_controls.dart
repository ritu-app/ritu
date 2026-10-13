import 'package:ritu/core/date_format.dart';
import 'package:ritu/data/repositories/memory/memory_daily_log_repository.dart';

import '../scope/ritu_repos.dart';

const _moods = ['Calm', 'Happy', 'Content', 'Focused', 'Restless', 'Flat'];
const _flows = ['Light', 'Medium', 'Spotting', 'Heavy'];
const _energies = ['Drained', 'Low', 'Moderate', 'High', 'Vibrant'];
const _symptomSets = <List<String>>[
  [],
  ['Headache'],
  ['Bloating', 'Headache'],
  ['Acne'],
];

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
    await _seedDay(dailyLogs, day: today, salt: generation);
  }

  for (var i = 0; i < loggedDaysCount; i++) {
    final offset = i + 1;
    await _seedDay(
      dailyLogs,
      day: today.subtract(Duration(days: offset)),
      salt: generation + offset,
    );
  }
}

Future<void> _seedDay(
  MemoryDailyLogRepository dailyLogs, {
  required DateTime day,
  required int salt,
}) {
  final mood = _moods[salt % _moods.length];
  return dailyLogs.upsert(
    loggedOn: day,
    flowIntensity: _flows[salt % _flows.length],
    moods: [mood, if (salt % 5 == 0) 'Irritable'],
    energyLevel: _energies[salt % _energies.length],
    wellbeing: (salt * 3) % 11,
    symptoms: _symptomSets[salt % _symptomSets.length],
  );
}
