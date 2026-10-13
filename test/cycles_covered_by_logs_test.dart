import 'package:flutter_test/flutter_test.dart';
import 'package:ritu/features/insights/cycles_covered_by_logs.dart';

void main() {
  final starts = [
    DateTime(2026, 6, 1),
    DateTime(2026, 6, 29),
    DateTime(2026, 7, 27),
    DateTime(2026, 8, 24),
  ];

  test('counts zero when there are no period starts', () {
    expect(
      cyclesCoveredByLogs(
        logDates: [DateTime(2026, 9, 1)],
        periodStarts: const [],
      ),
      0,
    );
  });

  test('counts each cycle that contains a log once', () {
    expect(
      cyclesCoveredByLogs(
        logDates: [
          DateTime(2026, 8, 24),
          DateTime(2026, 9, 6),
        ],
        periodStarts: starts,
      ),
      1,
    );

    expect(
      cyclesCoveredByLogs(
        logDates: [
          DateTime(2026, 8, 20),
          DateTime(2026, 8, 24),
          DateTime(2026, 9, 1),
        ],
        periodStarts: starts,
      ),
      2,
    );

    expect(
      cyclesCoveredByLogs(
        logDates: [
          DateTime(2026, 6, 1),
          DateTime(2026, 7, 1),
          DateTime(2026, 8, 1),
          DateTime(2026, 9, 1),
        ],
        periodStarts: starts,
      ),
      4,
    );
  });

  test('ignores logs before the first period and duplicate starts', () {
    expect(
      cyclesCoveredByLogs(
        logDates: [DateTime(2026, 5, 20), DateTime(2026, 6, 2)],
        periodStarts: [starts.first, starts.first],
      ),
      1,
    );
  });
}
