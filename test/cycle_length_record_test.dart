import 'package:flutter_test/flutter_test.dart';
import 'package:ritu/features/insights/cycle_length_record.dart';

void main() {
  test('lists completed cycles oldest first, then the open cycle', () {
    final rows = cycleLengthRecord(
      periodStarts: [
        DateTime(2026, 8, 16),
        DateTime(2026, 6, 10),
        DateTime(2026, 7, 1),
      ],
    );

    expect(rows.map((row) => row.span), [
      'Jun → Jul 2026',
      'Jul → Aug 2026',
      'Aug 2026 → ongoing',
    ]);
    expect(rows.map((row) => row.length), [
      '21 days',
      '46 days',
      'In progress',
    ]);
    expect(rows.last.inProgress, isTrue);
  });

  test('includes the start year when a cycle crosses years', () {
    final rows = cycleLengthRecord(
      periodStarts: [DateTime(2025, 12, 1), DateTime(2026, 1, 15)],
    );

    expect(rows.first.span, 'Dec 2025 → Jan 2026');
    expect(rows.first.length, '45 days');
  });

  test('uses the singular day label for a one-day cycle', () {
    final rows = cycleLengthRecord(
      periodStarts: [DateTime(2026, 6, 1), DateTime(2026, 6, 2)],
    );

    expect(rows.first.length, '1 day');
  });

  test('is empty without period starts', () {
    expect(cycleLengthRecord(periodStarts: const []), isEmpty);
  });
}
