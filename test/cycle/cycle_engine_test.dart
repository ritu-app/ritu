import 'package:flutter_test/flutter_test.dart';
import 'package:ritu/core/cycle/cycle.dart';

void main() {
  group('selectCycleSample', () {
    test('returns empty below 3 cycles', () {
      expect(selectCycleSample([28, 27]), isEmpty);
    });

    test('uses all lengths when fewer than 6', () {
      expect(selectCycleSample([21, 35, 23]), [21, 35, 23]);
      expect(selectCycleSample([21, 35, 23, 33]), [21, 35, 23, 33]);
    });

    test('uses rolling 6 most recent', () {
      final lengths = [40, 30, 28, 27, 29, 28, 27, 28];
      expect(selectCycleSample(lengths), [28, 27, 29, 28, 27, 28]);
    });
  });

  group('classifyCycleLengths — spec §4', () {
    test('Regular: MAD ≈ 0.56 (spec table rounds mean to 27.8 → 0.6)', () {
      final result = classifyCycleLengths([28, 27, 29, 28, 27, 28]);
      expect(result.classification, CycleClassification.regular);
      expect(result.mad, closeTo(0.556, 0.01));
      expect(result.mean, closeTo(27.833, 0.01));
    });

    test('Variable: MAD 5.0', () {
      final result = classifyCycleLengths([21, 35, 23, 33, 25, 31]);
      expect(result.classification, CycleClassification.variable);
      expect(result.mad, closeTo(5.0, 0.01));
      expect(result.mean, closeTo(28.0, 0.01));
    });

    test('Unpredictable: MAD ≈ 10.33 (spec table rounds mean to 32.7 → 10.3)', () {
      final result = classifyCycleLengths([21, 46, 24, 43, 22, 40]);
      expect(result.classification, CycleClassification.unpredictable);
      expect(result.mad, closeTo(10.333, 0.01));
    });

    test('Unclassified below 3 cycles', () {
      final result = classifyCycleLengths([28, 27]);
      expect(result.classification, CycleClassification.unclassified);
      expect(result.sample, isEmpty);
    });
  });

  group('insightsModeForCompletedCycles', () {
    test('partial below 3, full at 3+', () {
      expect(insightsModeForCompletedCycles(0), InsightsMode.partial);
      expect(insightsModeForCompletedCycles(2), InsightsMode.partial);
      expect(insightsModeForCompletedCycles(3), InsightsMode.full);
      expect(insightsModeForCompletedCycles(6), InsightsMode.full);
    });
  });

  group('computePhaseRanges — spec §3', () {
    test('P=5, C=28 baseline', () {
      final ranges = computePhaseRanges(periodDuration: 5, cycleLength: 28);
      expect(ranges.tier, PhaseTier.normal);
      expect(ranges.menstrual, const DayRange(start: 1, end: 5));
      expect(ranges.follicular, const DayRange(start: 6, end: 11));
      expect(ranges.ovulatory, const DayRange(start: 12, end: 14));
      expect(ranges.luteal, const DayRange(start: 15, end: 28));
    });

    test('P=3, C=23 short cycle', () {
      final ranges = computePhaseRanges(periodDuration: 3, cycleLength: 23);
      expect(ranges.tier, PhaseTier.normal);
      expect(ranges.menstrual, const DayRange(start: 1, end: 3));
      expect(ranges.follicular, const DayRange(start: 4, end: 6));
      expect(ranges.ovulatory, const DayRange(start: 7, end: 9));
      expect(ranges.luteal, const DayRange(start: 10, end: 23));
    });

    test('P=7, C=35 long cycle', () {
      final ranges = computePhaseRanges(periodDuration: 7, cycleLength: 35);
      expect(ranges.menstrual, const DayRange(start: 1, end: 7));
      expect(ranges.follicular, const DayRange(start: 8, end: 18));
      expect(ranges.ovulatory, const DayRange(start: 19, end: 21));
      expect(ranges.luteal, const DayRange(start: 22, end: 35));
    });
  });

  group('computePhaseRanges — spec §4 Tier B', () {
    test('P=5, C=21 compresses follicular', () {
      final ranges = computePhaseRanges(periodDuration: 5, cycleLength: 21);
      expect(ranges.tier, PhaseTier.compressed);
      expect(ranges.menstrual, const DayRange(start: 1, end: 5));
      expect(ranges.follicular, isNull);
      expect(ranges.ovulatory, const DayRange(start: 6, end: 7));
      expect(ranges.luteal, const DayRange(start: 8, end: 21));
    });
  });

  group('computePhaseRanges — spec §4 Tier C', () {
    test('available < 15 yields irregular', () {
      final ranges = computePhaseRanges(periodDuration: 5, cycleLength: 18);
      expect(ranges.tier, PhaseTier.irregular);
      expect(ranges.follicular, isNull);
      expect(ranges.ovulatory, isNull);
      expect(ranges.luteal, isNull);
    });

    test('C <= P yields irregular', () {
      final ranges = computePhaseRanges(periodDuration: 5, cycleLength: 5);
      expect(ranges.tier, PhaseTier.irregular);
    });
  });

  group('phaseForDay', () {
    test('maps cycle day to phase in baseline cycle', () {
      final ranges = computePhaseRanges(periodDuration: 5, cycleLength: 28);
      expect(ranges.phaseForDay(3), CyclePhase.menstrual);
      expect(ranges.phaseForDay(8), CyclePhase.follicular);
      expect(ranges.phaseForDay(13), CyclePhase.ovulatory);
      expect(ranges.phaseForDay(20), CyclePhase.luteal);
    });
  });

  group('variableCycleLengthMidpoint — spec §6', () {
    test('rounds half up: 24+33 → 29', () {
      expect(variableCycleLengthMidpoint([24, 28, 33]), 29);
    });
  });

  group('ovulatoryUncertaintyWidth — spec §6.4 Method 2', () {
    test('shortest 24, longest 33 → 11 days', () {
      expect(ovulatoryUncertaintyWidth([24, 28, 33]), 11);
    });
  });

  group('cycleDayForDate', () {
    test('returns 1-based day from latest applicable period', () {
      final episodes = [
        PeriodEpisode(
          startedOn: DateTime(2026, 5, 30),
          endedOn: DateTime(2026, 6, 3),
        ),
      ];
      expect(
        cycleDayForDate(
          date: DateTime(2026, 6, 18),
          episodesNewestFirst: episodes,
        ),
        20,
      );
    });
  });

  group('cycleLengthsFromStarts', () {
    test('computes consecutive start differences', () {
      expect(
        cycleLengthsFromStarts([
          DateTime(2026, 1, 1),
          DateTime(2026, 1, 29),
          DateTime(2026, 2, 26),
        ]),
        [28, 28],
      );
    });
  });
}
