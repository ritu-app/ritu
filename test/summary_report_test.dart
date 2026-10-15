import 'package:flutter_test/flutter_test.dart';
import 'package:ritu/data/models/daily_log_entry.dart';
import 'package:ritu/data/models/journal_entry.dart';
import 'package:ritu/data/models/period_log.dart';
import 'package:ritu/features/summary/summary_pdf.dart';
import 'package:ritu/features/summary/summary_report.dart';
import 'package:ritu/features/summary/summary_time_range.dart';

void main() {
  final today = DateTime(2026, 4, 10);
  final window = SummaryDateWindow(start: DateTime(2026, 1, 1), end: today);

  PeriodLog period(int id, DateTime start, DateTime end) {
    return PeriodLog(
      id: id,
      startedOn: start,
      endedOn: end,
      source: PeriodSources.calendar,
      createdAt: start,
      updatedAt: end,
    );
  }

  DailyLogEntry log({
    required int id,
    required DateTime day,
    List<String> moods = const [],
    String? energy,
    String? sleep,
    int? wellbeing,
    List<String> symptoms = const [],
  }) {
    return DailyLogEntry(
      id: id,
      loggedOn: day,
      createdAt: day,
      updatedAt: day,
      moods: moods,
      energyLevel: energy,
      sleepQuality: sleep,
      wellbeing: wellbeing,
      symptoms: symptoms,
    );
  }

  final periods = [
    period(1, DateTime(2026, 1, 1), DateTime(2026, 1, 5)),
    period(2, DateTime(2026, 1, 29), DateTime(2026, 2, 2)),
    period(3, DateTime(2026, 2, 26), DateTime(2026, 3, 2)),
    period(4, DateTime(2026, 3, 26), DateTime(2026, 3, 30)),
  ];

  final logs = [
    log(
      id: 1,
      day: DateTime(2026, 1, 2),
      moods: const ['Calm'],
      energy: 'High',
      sleep: 'Good',
      wellbeing: 4,
      symptoms: const ['Headache'],
    ),
    log(
      id: 2,
      day: DateTime(2026, 1, 3),
      wellbeing: 5,
      symptoms: const ['Headache'],
    ),
    log(id: 3, day: DateTime(2026, 1, 7), energy: 'High', wellbeing: 8),
    log(id: 4, day: DateTime(2026, 1, 21), energy: 'Low', wellbeing: 5),
    log(
      id: 5,
      day: DateTime(2026, 1, 30),
      symptoms: const ['Headache'],
      wellbeing: 6,
    ),
  ];

  final journals = [
    JournalEntry(
      id: 7,
      loggedOn: DateTime(2026, 1, 17),
      body: 'A quiet morning.',
      createdAt: today,
      updatedAt: today,
    ),
    JournalEntry(
      id: 8,
      loggedOn: DateTime(2025, 12, 1),
      body: 'Outside the range.',
      createdAt: today,
      updatedAt: today,
    ),
  ];

  SummaryReport report({Set<int> journalIds = const {}, bool journal = true}) {
    return buildSummaryReport(
      request: SummaryReportRequest(
        window: window,
        generatedOn: today,
        journalIds: journalIds,
        includes: SummaryIncludes(
          cycleLength: true,
          moodPatterns: true,
          energyPatterns: true,
          bodySignals: true,
          sleepLogs: true,
          wellbeingScore: true,
          journalEntries: journal,
        ),
      ),
      logs: logs,
      periods: periods,
      journals: journals,
    );
  }

  test('summarises cycles, a symptom cluster, and the journal', () {
    final built = report();

    expect(built.dateRangeLabel, 'January 1–April 10, 2026');
    expect(built.classificationLabel, 'Regular classification');
    expect(built.summary, contains('3 recorded cycles'));
    expect(built.summary, contains('1 finding worth mentioning to a doctor'));
    expect(built.summary, contains('Cycle length has remained stable'));
    expect(
      built.findings.map((finding) => finding.text).join('\n'),
      contains('Headache was logged on days 2–3 of the cycle'),
    );
    expect(
      built.findings.map((finding) => finding.text),
      contains(
        'Energy is lower in the luteal phase than earlier in the cycle.',
      ),
    );
    expect(
      built.findings.map((finding) => finding.text),
      contains('Cycle length stayed within 28 days.'),
    );
    expect(built.stats.map((stat) => stat.label), contains('Avg cycle length'));
    expect(built.cycles.last.length, 'Current');
    expect(built.journals.map((entry) => entry.body), ['A quiet morning.']);
    expect(built.wellbeing, isNotEmpty);
  });

  test('keeps only the journal entries the user picked', () {
    final built = report(journalIds: {8});

    expect(built.journals, isEmpty);
  });

  test('pdf bytes are a PDF document', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final bytes = await buildSummaryPdf(report(journal: false));

    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });
}
