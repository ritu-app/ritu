import 'package:flutter_test/flutter_test.dart';
import 'package:ritu/core/cycle/unclassified_status_copy.dart';

void main() {
  group('unclassifiedStatusTrailingLabel', () {
    test('No history yet before a full week of logs', () {
      expect(
        unclassifiedStatusTrailingLabel(periodStartCount: 1, loggedDays: 0),
        'No history yet',
      );
      expect(
        unclassifiedStatusTrailingLabel(periodStartCount: 1, loggedDays: 6),
        'No history yet',
      );
    });

    test('weeks logged follow daily logs, not calendar days', () {
      expect(
        unclassifiedStatusTrailingLabel(periodStartCount: 1, loggedDays: 7),
        '1 week logged',
      );
      expect(
        unclassifiedStatusTrailingLabel(periodStartCount: 1, loggedDays: 13),
        '1 week logged',
      );
      expect(
        unclassifiedStatusTrailingLabel(periodStartCount: 1, loggedDays: 14),
        '2 weeks logged',
      );
    });

    test('cycles so far once a second period is logged', () {
      expect(
        unclassifiedStatusTrailingLabel(periodStartCount: 2, loggedDays: 7),
        '2 cycles so far',
      );
      expect(
        unclassifiedStatusTrailingLabel(periodStartCount: 3, loggedDays: 0),
        '3 cycles so far',
      );
    });
  });

  group('showQuietPreclassificationPrompt', () {
    test('starts once the open cycle reaches 45 days', () {
      expect(
        showQuietPreclassificationPrompt(periodStartCount: 1, cycleDay: 44),
        isFalse,
      );
      expect(
        showQuietPreclassificationPrompt(periodStartCount: 1, cycleDay: 45),
        isTrue,
      );
      expect(
        showQuietPreclassificationPrompt(periodStartCount: 1, cycleDay: 46),
        isTrue,
      );
    });

    test('stays off with no period to be late against', () {
      expect(
        showQuietPreclassificationPrompt(periodStartCount: 0, cycleDay: 60),
        isFalse,
      );
    });
  });
}
