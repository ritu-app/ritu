import 'package:flutter_test/flutter_test.dart';
import 'package:ritu/data/models/daily_log_entry.dart';
import 'package:ritu/features/insights/insight_history.dart';

void main() {
  DailyLogEntry log(
    DateTime day, {
    int? wellbeing,
    String? energyLevel,
    List<String> moods = const [],
    List<String> symptoms = const [],
  }) {
    return DailyLogEntry(
      id: day.millisecondsSinceEpoch,
      loggedOn: day,
      createdAt: day,
      updatedAt: day,
      wellbeing: wellbeing,
      energyLevel: energyLevel,
      moods: moods,
      symptoms: symptoms,
    );
  }

  test('starts at the first log and keeps gaps through today', () {
    final strips = buildInsightHistory(
      logs: [
        log(DateTime(2026, 9, 10), wellbeing: 2),
        log(DateTime(2026, 9, 12), wellbeing: 9),
        log(DateTime(2026, 9, 20), wellbeing: 5),
      ],
      today: DateTime(2026, 9, 12),
      lens: InsightLens.overview,
    );

    expect(strips, hasLength(1));
    expect(strips.single.label, 'Sep');
    expect(strips.single.levels, [
      InsightLevel.low,
      InsightLevel.none,
      InsightLevel.high,
    ]);
  });

  test('splits months and adds the year when the span crosses a year', () {
    final strips = buildInsightHistory(
      logs: [log(DateTime(2025, 12, 30), wellbeing: 8)],
      today: DateTime(2026, 1, 2),
      lens: InsightLens.overview,
    );

    expect(strips.map((strip) => strip.label), ['Dec 2025', 'Jan 2026']);
    expect(strips[0].levels, [InsightLevel.high, InsightLevel.none]);
    expect(strips[1].levels, [InsightLevel.none, InsightLevel.none]);
  });

  test('returns nothing when every log is after today', () {
    final strips = buildInsightHistory(
      logs: [log(DateTime(2026, 9, 20), wellbeing: 8)],
      today: DateTime(2026, 9, 12),
      lens: InsightLens.overview,
    );
    expect(strips, isEmpty);
  });

  test('buckets wellbeing, mood, energy, and body signals', () {
    final days = [
      log(
        DateTime(2026, 9, 1),
        wellbeing: 0,
        energyLevel: 'Drained',
        moods: ['Sad'],
        symptoms: ['Headache', 'Acne'],
      ),
      log(
        DateTime(2026, 9, 2),
        wellbeing: 3,
        energyLevel: 'Low',
        moods: ['Restless'],
        symptoms: ['Bloating', 'Headache', 'Nausea'],
      ),
      log(
        DateTime(2026, 9, 3),
        wellbeing: 4,
        energyLevel: 'Moderate',
        moods: ['Calm', 'Anxious'],
        symptoms: ['Headache'],
      ),
      log(
        DateTime(2026, 9, 4),
        wellbeing: 6,
        energyLevel: 'Moderate',
        moods: ['Happy', 'Sad'],
      ),
      log(
        DateTime(2026, 9, 5),
        wellbeing: 7,
        energyLevel: 'High',
        moods: ['Content', 'Focused'],
      ),
      log(
        DateTime(2026, 9, 6),
        wellbeing: 10,
        energyLevel: 'Vibrant',
        moods: ['Happy'],
      ),
      log(DateTime(2026, 9, 7), moods: ['Sleepy']),
    ];

    List<InsightLevel> levels(InsightLens lens) {
      return buildInsightHistory(
        logs: days,
        today: DateTime(2026, 9, 7),
        lens: lens,
      ).single.levels;
    }

    expect(levels(InsightLens.overview), [
      InsightLevel.low,
      InsightLevel.low,
      InsightLevel.mid,
      InsightLevel.mid,
      InsightLevel.high,
      InsightLevel.high,
      InsightLevel.none,
    ]);
    expect(levels(InsightLens.energy), [
      InsightLevel.low,
      InsightLevel.low,
      InsightLevel.mid,
      InsightLevel.mid,
      InsightLevel.high,
      InsightLevel.high,
      InsightLevel.none,
    ]);
    expect(levels(InsightLens.mood), [
      InsightLevel.low,
      InsightLevel.low,
      InsightLevel.mid,
      InsightLevel.mid,
      InsightLevel.high,
      InsightLevel.high,
      InsightLevel.none,
    ]);
    expect(levels(InsightLens.body), [
      InsightLevel.low,
      InsightLevel.low,
      InsightLevel.mid,
      InsightLevel.high,
      InsightLevel.high,
      InsightLevel.high,
      InsightLevel.high,
    ]);
  });
}
