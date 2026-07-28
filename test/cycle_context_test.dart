import 'package:flutter_test/flutter_test.dart';

import 'package:ritu/core/cycle_context.dart';
import 'package:ritu/core/date_format.dart';
import 'package:ritu/data/models/period_log.dart';

void main() {
  test('formatJournalEntryContextLine includes cycle day without phase', () {
    final entryDate = DateTime(2026, 6, 18);
    final periods = [
      PeriodLog(
        id: 1,
        startedOn: DateTime(2026, 5, 30),
        source: 'test',
        createdAt: DateTime(2026, 5, 30),
        updatedAt: DateTime(2026, 5, 30),
      ),
    ];

    expect(
      formatJournalEntryContextLine(entryDate, periods),
      '2026 • Day 20',
    );
  });

  test('formatJournalEntryModalTitle formats month and day', () {
    expect(
      formatJournalEntryModalTitle(DateTime(2026, 6, 18)),
      'June 18',
    );
  });

  test('formatJournalEntryDate uses bullet separator', () {
    expect(
      formatJournalEntryDate(DateTime(2026, 6, 17)),
      'June 17 • 2026',
    );
  });
}
