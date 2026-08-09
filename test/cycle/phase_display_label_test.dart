import 'package:flutter_test/flutter_test.dart';
import 'package:ritu/core/cycle/cycle_phase.dart';

void main() {
  group('phaseDisplayLabel', () {
    test('exact labels for Regular', () {
      expect(phaseDisplayLabel(CyclePhase.menstrual), 'Menstrual phase');
      expect(phaseDisplayLabel(CyclePhase.follicular), 'Follicular phase');
      expect(phaseDisplayLabel(CyclePhase.ovulatory), 'Ovulatory phase');
      expect(phaseDisplayLabel(CyclePhase.luteal), 'Luteal phase');
    });

    test('estimated Variable labels prefix ~ except menstrual', () {
      expect(
        phaseDisplayLabel(CyclePhase.menstrual, estimated: true),
        'Menstrual phase',
      );
      expect(
        phaseDisplayLabel(CyclePhase.follicular, estimated: true),
        '~Follicular phase',
      );
      expect(
        phaseDisplayLabel(CyclePhase.ovulatory, estimated: true),
        '~Ovulatory phase',
      );
      expect(
        phaseDisplayLabel(CyclePhase.luteal, estimated: true),
        '~Luteal phase',
      );
    });
  });
}
