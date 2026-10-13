import 'package:flutter_test/flutter_test.dart';
import 'package:ritu/data/models/daily_log_entry.dart';
import 'package:ritu/features/insights/insight_history.dart';
import 'package:ritu/features/insights/most_logged.dart';

void main() {
  final today = DateTime(2026, 9, 4);

  DailyLogEntry log({
    required int day,
    List<String> moods = const [],
    String? energyLevel,
    List<String> symptoms = const [],
  }) {
    return DailyLogEntry(
      id: day,
      loggedOn: DateTime(2026, 9, day),
      createdAt: today,
      updatedAt: today,
      moods: moods,
      energyLevel: energyLevel,
      symptoms: symptoms,
    );
  }

  final logs = [
    log(day: 1, moods: ['Calm', 'Sad'], energyLevel: 'Low', symptoms: ['Acne']),
    log(day: 2, moods: ['Calm'], energyLevel: 'High', symptoms: ['Acne', 'Cramps']),
    log(day: 3, moods: ['Irritable'], energyLevel: 'High', symptoms: ['Cramps']),
    log(day: 4, moods: ['Calm'], energyLevel: ' ', symptoms: ['  ']),
    log(day: 5, moods: ['Future'], energyLevel: 'Vibrant'),
  ];

  test('ranks moods, energy, and signals and keeps the top four', () {
    expect(
      mostLoggedLabels(logs: logs, today: today, lens: InsightLens.mood),
      ['Calm', 'Irritable', 'Sad'],
    );
    expect(
      mostLoggedLabels(logs: logs, today: today, lens: InsightLens.energy),
      ['High', 'Low'],
    );
    expect(
      mostLoggedLabels(logs: logs, today: today, lens: InsightLens.body),
      ['Acne', 'Cramps'],
    );
    expect(
      mostLoggedLabels(logs: logs, today: today, lens: InsightLens.overview),
      isEmpty,
    );
  });

  test('stops at four labels when more are tied', () {
    final many = [
      for (var day = 1; day <= 5; day++)
        log(
          day: day,
          moods: ['Echo', 'Delta', 'Charlie', 'Bravo', 'Alpha'],
        ),
    ];

    expect(
      mostLoggedLabels(logs: many, today: today, lens: InsightLens.mood),
      ['Alpha', 'Bravo', 'Charlie', 'Delta'],
    );
  });
}
