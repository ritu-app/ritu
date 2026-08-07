import 'package:flutter_test/flutter_test.dart';
import 'package:ritu/core/cycle/unclassified_status_copy.dart';

void main() {
  group('unclassifiedStatusTrailingLabel', () {
    test('No history yet before 2 weeks on first cycle', () {
      expect(
        unclassifiedStatusTrailingLabel(periodStartCount: 1, cycleDay: 7),
        'No history yet',
      );
      expect(
        unclassifiedStatusTrailingLabel(periodStartCount: 1, cycleDay: 13),
        'No history yet',
      );
    });

    test('weeks logged from day 14 on first cycle', () {
      expect(
        unclassifiedStatusTrailingLabel(periodStartCount: 1, cycleDay: 14),
        '2 weeks logged',
      );
      expect(
        unclassifiedStatusTrailingLabel(periodStartCount: 1, cycleDay: 21),
        '3 weeks logged',
      );
    });

    test('cycles so far once a second period is logged', () {
      expect(
        unclassifiedStatusTrailingLabel(periodStartCount: 2, cycleDay: 12),
        '2 cycles so far',
      );
      expect(
        unclassifiedStatusTrailingLabel(periodStartCount: 3, cycleDay: 5),
        '3 cycles so far',
      );
    });

    test('missing cycle day still yields No history yet on first cycle', () {
      expect(
        unclassifiedStatusTrailingLabel(periodStartCount: 1, cycleDay: null),
        'No history yet',
      );
    });
  });
}
