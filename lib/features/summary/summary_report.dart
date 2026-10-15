import '../../core/cycle/classification.dart';
import '../../core/cycle/cycle_classification.dart';
import '../../core/cycle/cycle_lengths.dart';
import '../../core/cycle/cycle_phase.dart';
import '../../core/cycle/phase_ranges.dart';
import '../../core/date_format.dart';
import '../../data/models/daily_log_entry.dart';
import '../../data/models/journal_entry.dart';
import '../../data/models/period_log.dart';
import 'summary_time_range.dart';

/// Which sections the generate-summary sheet asked to include.
class SummaryIncludes {
  const SummaryIncludes({
    required this.cycleLength,
    required this.moodPatterns,
    required this.energyPatterns,
    required this.bodySignals,
    required this.sleepLogs,
    required this.wellbeingScore,
    required this.journalEntries,
  });

  final bool cycleLength;
  final bool moodPatterns;
  final bool energyPatterns;
  final bool bodySignals;
  final bool sleepLogs;
  final bool wellbeingScore;
  final bool journalEntries;

  bool get showsPhaseTable => moodPatterns || energyPatterns || sleepLogs;
}

/// Inputs for one summary PDF.
class SummaryReportRequest {
  const SummaryReportRequest({
    required this.window,
    required this.generatedOn,
    required this.includes,
    this.journalIds = const {},
  });

  final SummaryDateWindow window;
  final DateTime generatedOn;
  final SummaryIncludes includes;

  /// Empty means every journal entry in [window], when journal entries
  /// are included.
  final Set<int> journalIds;
}

enum SummaryFindingKind { flag, note, consistent }

class SummaryFinding {
  const SummaryFinding({required this.kind, required this.text});

  final SummaryFindingKind kind;
  final String text;
}

class SummaryStat {
  const SummaryStat({required this.value, required this.label});

  final String value;
  final String label;
}

class CycleLengthRow {
  const CycleLengthRow({
    required this.start,
    required this.length,
    required this.periodDuration,
  });

  final DateTime start;
  final String length;
  final String periodDuration;
}

class PhasePatternRow {
  const PhasePatternRow({
    required this.phase,
    required this.mood,
    required this.energy,
    required this.sleep,
  });

  final CyclePhase phase;
  final String mood;
  final String energy;
  final String sleep;
}

class BodySignalRow {
  const BodySignalRow({
    required this.signal,
    required this.daysLogged,
    required this.timing,
  });

  final String signal;
  final int daysLogged;
  final String timing;
}

class WellbeingBar {
  const WellbeingBar({required this.phase, required this.score});

  final CyclePhase phase;
  final double score;
}

class SummaryJournalBlock {
  const SummaryJournalBlock({required this.loggedOn, required this.body});

  final DateTime loggedOn;
  final String body;
}

class SummaryReport {
  const SummaryReport({
    required this.dateRangeLabel,
    required this.classificationLabel,
    required this.summary,
    required this.stats,
    required this.findings,
    required this.wellbeing,
    required this.cycles,
    required this.phasePatterns,
    required this.bodySignals,
    required this.journals,
    required this.generatedOn,
    required this.includes,
  });

  final String dateRangeLabel;
  final String classificationLabel;
  final String summary;
  final List<SummaryStat> stats;
  final List<SummaryFinding> findings;
  final List<WellbeingBar> wellbeing;
  final List<CycleLengthRow> cycles;
  final List<PhasePatternRow> phasePatterns;
  final List<BodySignalRow> bodySignals;
  final List<SummaryJournalBlock> journals;
  final DateTime generatedOn;
  final SummaryIncludes includes;
}

const _energyRank = {
  'Drained': 0,
  'Low': 1,
  'Moderate': 2,
  'High': 3,
  'Vibrant': 4,
};

const _phaseOrder = [
  CyclePhase.menstrual,
  CyclePhase.follicular,
  CyclePhase.ovulatory,
  CyclePhase.luteal,
];

/// Builds the summary shown in the PDF from on-device logs.
SummaryReport buildSummaryReport({
  required SummaryReportRequest request,
  required List<DailyLogEntry> logs,
  required List<PeriodLog> periods,
  required List<JournalEntry> journals,
}) {
  final window = request.window;
  final includes = request.includes;
  final spans = _spans(periods);
  final lengths = cycleLengthsFromStarts(
    sortPeriodStartsOldestFirst([
      for (final period in periods) period.startedOn,
    ]),
  );
  final classification = classifyCycleLengths(lengths);
  final mean = classification.mean;

  final inWindow = [
    for (final log in logs)
      if (window.contains(log.loggedOn)) log,
  ];
  final overlapping = [
    for (final span in spans)
      if (_overlaps(span, window)) span,
  ];
  final completed = [
    for (final span in overlapping)
      if (span.lengthDays != null) span,
  ];

  final phased = <DailyLogEntry, CyclePhase>{};
  for (final log in inWindow) {
    final span = _spanContaining(spans, log.loggedOn);
    if (span == null) continue;
    final phase = _phase(span, log.loggedOn, request.generatedOn, mean);
    if (phase != null) phased[log] = phase;
  }

  final findings = _findings(
    logs: inWindow,
    phased: phased,
    spans: spans,
    completedInWindow: completed.length,
    classification: classification,
  );

  final rangeLabel = summaryDateRangeLabel(window);
  final summary = _summary(
    rangeLabel: rangeLabel,
    recordedCycles: completed.length,
    findings: findings,
    stable: classification.classification == CycleClassification.regular,
  );

  final stats = <SummaryStat>[
    if (includes.cycleLength && completed.isNotEmpty)
      SummaryStat(
        value: _formatMean(
          completed.map((span) => span.lengthDays!).reduce((a, b) => a + b) /
              completed.length,
        ),
        label: 'Avg cycle length',
      ),
    SummaryStat(value: '${overlapping.length}', label: 'Cycles analysed'),
    SummaryStat(value: '${inWindow.length}', label: 'Days logged'),
    SummaryStat(
      value: _consistency(window, inWindow.length),
      label: 'Log consistency',
    ),
  ];

  return SummaryReport(
    dateRangeLabel: rangeLabel,
    classificationLabel: _classificationLabel(classification.classification),
    summary: summary,
    stats: stats,
    findings: findings,
    wellbeing: includes.wellbeingScore ? _wellbeing(phased) : const [],
    cycles: includes.cycleLength
        ? [
            for (final span in overlapping)
              CycleLengthRow(
                start: span.start,
                length: span.lengthDays == null
                    ? 'Current'
                    : '${span.lengthDays} days',
                periodDuration: _periodLabel(span, request.generatedOn),
              ),
          ]
        : const [],
    phasePatterns: includes.showsPhaseTable ? _phaseRows(phased) : const [],
    bodySignals: includes.bodySignals
        ? _bodySignals(inWindow, spans, request.generatedOn, mean)
        : const [],
    journals: includes.journalEntries
        ? _journals(journals, window, request.journalIds)
        : const [],
    generatedOn: request.generatedOn,
    includes: includes,
  );
}

/// Concrete dates covered by [window], e.g. `June 1–August 20, 2026`.
String summaryDateRangeLabel(SummaryDateWindow window) {
  final start = window.start;
  if (start == null) return 'Selected range';
  return _fullRange(dateOnly(start), dateOnly(window.end));
}

String phaseShortLabel(CyclePhase phase) => switch (phase) {
  CyclePhase.menstrual => 'Menstrual',
  CyclePhase.follicular => 'Follicular',
  CyclePhase.ovulatory => 'Ovulatory',
  CyclePhase.luteal => 'Luteal',
};

class _CycleSpan {
  const _CycleSpan({
    required this.start,
    required this.endedOn,
    required this.nextStart,
  });

  final DateTime start;
  final DateTime? endedOn;
  final DateTime? nextStart;

  int? get lengthDays {
    final next = nextStart;
    if (next == null) return null;
    return next.difference(start).inDays;
  }

  int cycleDay(DateTime day) => dateOnly(day).difference(start).inDays + 1;

  bool contains(DateTime day) {
    final date = dateOnly(day);
    if (date.isBefore(start)) return false;
    final next = nextStart;
    if (next != null && !date.isBefore(next)) return false;
    return true;
  }

  int? periodDays(DateTime today) {
    final end = endedOn;
    if (end != null) {
      if (end.isBefore(start)) return 1;
      return end.difference(start).inDays + 1;
    }
    if (nextStart != null) return null;
    final through = dateOnly(today);
    if (through.isBefore(start)) return null;
    return through.difference(start).inDays + 1;
  }
}

List<_CycleSpan> _spans(List<PeriodLog> periods) {
  final sorted = [...periods]
    ..sort((a, b) => dateOnly(a.startedOn).compareTo(dateOnly(b.startedOn)));
  return [
    for (var i = 0; i < sorted.length; i++)
      _CycleSpan(
        start: dateOnly(sorted[i].startedOn),
        endedOn: sorted[i].endedOn == null
            ? null
            : dateOnly(sorted[i].endedOn!),
        nextStart: i + 1 < sorted.length
            ? dateOnly(sorted[i + 1].startedOn)
            : null,
      ),
  ];
}

bool _overlaps(_CycleSpan span, SummaryDateWindow window) {
  final start = window.start;
  if (start == null) return false;
  final cycleEnd = span.nextStart == null
      ? dateOnly(window.end)
      : span.nextStart!.subtract(const Duration(days: 1));
  return !cycleEnd.isBefore(dateOnly(start)) &&
      !span.start.isAfter(dateOnly(window.end));
}

_CycleSpan? _spanContaining(List<_CycleSpan> spans, DateTime day) {
  for (final span in spans) {
    if (span.contains(day)) return span;
  }
  return null;
}

CyclePhase? _phase(
  _CycleSpan span,
  DateTime day,
  DateTime today,
  double? meanLength,
) {
  final period = span.periodDays(today);
  if (period == null) return null;
  final cycleDay = span.cycleDay(day);
  if (cycleDay <= period) return CyclePhase.menstrual;
  final length = span.lengthDays ?? meanLength?.round();
  if (length == null || length <= period || cycleDay > length) return null;
  return computePhaseRanges(
    periodDuration: period,
    cycleLength: length,
  ).phaseForDay(cycleDay);
}

List<SummaryFinding> _findings({
  required List<DailyLogEntry> logs,
  required Map<DailyLogEntry, CyclePhase> phased,
  required List<_CycleSpan> spans,
  required int completedInWindow,
  required ClassificationResult classification,
}) {
  final findings = <SummaryFinding>[];

  final flag = _flag(logs, spans, completedInWindow);
  if (flag != null) findings.add(flag);

  final note = _energyNote(phased);
  if (note != null) findings.add(note);

  final consistent = _consistent(phased, classification);
  if (consistent != null) findings.add(consistent);

  return findings;
}

SummaryFinding? _flag(
  List<DailyLogEntry> logs,
  List<_CycleSpan> spans,
  int completedInWindow,
) {
  final daysBySignal = <String, Set<DateTime>>{};
  for (final log in logs) {
    final day = dateOnly(log.loggedOn);
    for (final symptom in log.symptoms) {
      daysBySignal.putIfAbsent(symptom, () => {}).add(day);
    }
  }
  if (daysBySignal.isEmpty) return null;

  final ranked = daysBySignal.entries.toList()
    ..sort((a, b) {
      final byCount = b.value.length.compareTo(a.value.length);
      if (byCount != 0) return byCount;
      return a.key.compareTo(b.key);
    });
  final top = ranked.first;
  if (top.value.length < 3) return null;

  final cycleDays = <int>[];
  final cyclesSeen = <DateTime>{};
  for (final day in top.value) {
    final span = _spanContaining(spans, day);
    if (span == null) continue;
    cycleDays.add(span.cycleDay(day));
    cyclesSeen.add(span.start);
  }

  final timing = cycleDays.isEmpty ? null : _daySpan(cycleDays);
  final where = timing == null
      ? 'on ${top.value.length} days in this range'
      : 'on $timing of the cycle';
  final across = completedInWindow == 0
      ? ''
      : ', in ${cyclesSeen.length} of $completedInWindow recorded cycles';

  return SummaryFinding(
    kind: SummaryFindingKind.flag,
    text: '${top.key} was logged $where$across — worth mentioning to a doctor.',
  );
}

SummaryFinding? _energyNote(Map<DailyLogEntry, CyclePhase> phased) {
  final ranks = <CyclePhase, List<int>>{};
  for (final entry in phased.entries) {
    final rank = _energyRank[entry.key.energyLevel];
    if (rank == null) continue;
    ranks.putIfAbsent(entry.value, () => []).add(rank);
  }
  double? average(CyclePhase phase) {
    final values = ranks[phase];
    if (values == null || values.isEmpty) return null;
    return values.reduce((a, b) => a + b) / values.length;
  }

  final luteal = average(CyclePhase.luteal);
  final earlier = [
    average(CyclePhase.menstrual),
    average(CyclePhase.follicular),
    average(CyclePhase.ovulatory),
  ].whereType<double>().toList();
  if (luteal != null && earlier.isNotEmpty) {
    final baseline = earlier.reduce((a, b) => a + b) / earlier.length;
    if (baseline - luteal >= 1) {
      return const SummaryFinding(
        kind: SummaryFindingKind.note,
        text: 'Energy is lower in the luteal phase than earlier in the cycle.',
      );
    }
  }

  final counts = <String, int>{};
  for (final log in phased.keys) {
    final energy = log.energyLevel;
    if (energy == null) continue;
    counts[energy] = (counts[energy] ?? 0) + 1;
  }
  if (counts.isEmpty) return null;
  final topCount = counts.values.reduce((a, b) => a > b ? a : b);
  if (topCount < 2) return null;
  final mode = _mode(counts);
  if (mode == null) return null;
  return SummaryFinding(
    kind: SummaryFindingKind.note,
    text: 'Energy is most often $mode on logged days.',
  );
}

SummaryFinding? _consistent(
  Map<DailyLogEntry, CyclePhase> phased,
  ClassificationResult classification,
) {
  final sample = classification.sample;
  if (classification.classification == CycleClassification.regular &&
      sample.length >= 3) {
    final min = sample.reduce((a, b) => a < b ? a : b);
    final max = sample.reduce((a, b) => a > b ? a : b);
    final span = min == max ? '$min days' : '$min–$max days';
    return SummaryFinding(
      kind: SummaryFindingKind.consistent,
      text: 'Cycle length stayed within $span.',
    );
  }

  final moodCounts = <CyclePhase, Map<String, int>>{};
  for (final entry in phased.entries) {
    final counts = moodCounts.putIfAbsent(entry.value, () => {});
    for (final mood in entry.key.moods) {
      counts[mood] = (counts[mood] ?? 0) + 1;
    }
  }
  for (final phase in _phaseOrder) {
    final mode = _mode(moodCounts[phase] ?? const {});
    final count = moodCounts[phase]?[mode] ?? 0;
    if (mode != null && count >= 3) {
      return SummaryFinding(
        kind: SummaryFindingKind.consistent,
        text:
            '$mode is the most common mood in the ${phaseShortLabel(phase).toLowerCase()} phase.',
      );
    }
  }
  return null;
}

String _summary({
  required String rangeLabel,
  required int recordedCycles,
  required List<SummaryFinding> findings,
  required bool stable,
}) {
  if (recordedCycles == 0) {
    return 'This summary covers $rangeLabel. '
        'A completed cycle does not fall in this window yet, so the sections below use the days you logged.';
  }

  final flags = findings.where((f) => f.kind == SummaryFindingKind.flag).length;
  final patterns = findings
      .where((f) => f.kind == SummaryFindingKind.consistent)
      .length;
  final parts = <String>[
    if (flags > 0)
      '${_count(flags, 'finding', 'findings')} worth mentioning to a doctor',
    if (patterns > 0)
      _count(patterns, 'consistent pattern', 'consistent patterns'),
  ];
  final identified = parts.isEmpty
      ? 'no repeating pattern in the selected logs'
      : parts.join(' and ');
  final stableSentence = stable
      ? ' Cycle length has remained stable throughout.'
      : '';
  return 'Across ${_count(recordedCycles, 'recorded cycle', 'recorded cycles')}, '
      'this journal identified $identified.$stableSentence';
}

List<WellbeingBar> _wellbeing(Map<DailyLogEntry, CyclePhase> phased) {
  final scores = <CyclePhase, List<int>>{};
  for (final entry in phased.entries) {
    final score = entry.key.wellbeing;
    if (score == null) continue;
    scores.putIfAbsent(entry.value, () => []).add(score);
  }
  return [
    for (final phase in _phaseOrder)
      if (scores[phase] != null)
        WellbeingBar(
          phase: phase,
          score: scores[phase]!.reduce((a, b) => a + b) / scores[phase]!.length,
        ),
  ];
}

List<PhasePatternRow> _phaseRows(Map<DailyLogEntry, CyclePhase> phased) {
  final grouped = <CyclePhase, List<DailyLogEntry>>{};
  for (final entry in phased.entries) {
    grouped.putIfAbsent(entry.value, () => []).add(entry.key);
  }
  return [
    for (final phase in _phaseOrder)
      if (grouped[phase] != null)
        PhasePatternRow(
          phase: phase,
          mood:
              _mode(_countValues(grouped[phase]!.expand((log) => log.moods))) ??
              '—',
          energy:
              _mode(
                _countValues([
                  for (final log in grouped[phase]!)
                    if (log.energyLevel != null) log.energyLevel!,
                ]),
              ) ??
              '—',
          sleep:
              _mode(
                _countValues([
                  for (final log in grouped[phase]!)
                    if (log.sleepQuality != null) log.sleepQuality!,
                ]),
              ) ??
              '—',
        ),
  ];
}

List<BodySignalRow> _bodySignals(
  List<DailyLogEntry> logs,
  List<_CycleSpan> spans,
  DateTime today,
  double? mean,
) {
  final days = <String, Set<DateTime>>{};
  final cycleDays = <String, List<int>>{};
  for (final log in logs) {
    final day = dateOnly(log.loggedOn);
    for (final symptom in log.symptoms) {
      days.putIfAbsent(symptom, () => {}).add(day);
      final span = _spanContaining(spans, day);
      if (span == null) continue;
      if (_phase(span, day, today, mean) == null && span.cycleDay(day) < 1) {
        continue;
      }
      cycleDays.putIfAbsent(symptom, () => []).add(span.cycleDay(day));
    }
  }
  final rows =
      [
        for (final entry in days.entries)
          BodySignalRow(
            signal: entry.key,
            daysLogged: entry.value.length,
            timing: _daySpan(cycleDays[entry.key] ?? const []),
          ),
      ]..sort((a, b) {
        final byDays = b.daysLogged.compareTo(a.daysLogged);
        if (byDays != 0) return byDays;
        return a.signal.compareTo(b.signal);
      });
  return rows;
}

List<SummaryJournalBlock> _journals(
  List<JournalEntry> journals,
  SummaryDateWindow window,
  Set<int> ids,
) {
  final chosen = [
    for (final entry in journals)
      if (window.contains(entry.loggedOn) &&
          (ids.isEmpty || ids.contains(entry.id)))
        entry,
  ]..sort((a, b) => a.loggedOn.compareTo(b.loggedOn));
  return [
    for (final entry in chosen)
      SummaryJournalBlock(loggedOn: entry.loggedOn, body: entry.body),
  ];
}

String _periodLabel(_CycleSpan span, DateTime today) {
  final days = span.periodDays(today);
  if (days == null) return '—';
  if (span.endedOn == null) return 'Ongoing';
  return days == 1 ? '1 day' : '$days days';
}

String _consistency(SummaryDateWindow window, int loggedDays) {
  final start = window.start;
  if (start == null) return '—';
  final span = dateOnly(window.end).difference(dateOnly(start)).inDays + 1;
  if (span <= 0) return '—';
  final percent = (loggedDays / span * 100).round().clamp(0, 100);
  return '$percent%';
}

String _formatMean(double mean) {
  final rounded = (mean * 10).round() / 10;
  if (rounded == rounded.roundToDouble()) return '${rounded.round()}';
  return rounded.toStringAsFixed(1);
}

String _classificationLabel(CycleClassification classification) =>
    switch (classification) {
      CycleClassification.regular => 'Regular classification',
      CycleClassification.variable => 'Variable classification',
      CycleClassification.unpredictable => 'Unpredictable classification',
      CycleClassification.unclassified => 'Not classified yet',
    };

String _count(int count, String singular, String plural) =>
    count == 1 ? '1 $singular' : '$count $plural';

String? _mode(Map<String, int> counts) {
  if (counts.isEmpty) return null;
  final top = counts.values.reduce((a, b) => a > b ? a : b);
  if (top < 1) return null;
  final names = [
    for (final entry in counts.entries)
      if (entry.value == top) entry.key,
  ]..sort();
  return names.join(', ');
}

Map<String, int> _countValues(Iterable<String> values) {
  final counts = <String, int>{};
  for (final value in values) {
    counts[value] = (counts[value] ?? 0) + 1;
  }
  return counts;
}

String _daySpan(List<int> days) {
  if (days.isEmpty) return '—';
  final sorted = [...days]..sort();
  if (sorted.first == sorted.last) return 'day ${sorted.first}';
  return 'days ${sorted.first}–${sorted.last}';
}

String _fullRange(DateTime start, DateTime end) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  if (start.year == end.year && start.month == end.month) {
    return '${months[start.month - 1]} ${start.day}–${end.day}, ${start.year}';
  }
  if (start.year == end.year) {
    return '${months[start.month - 1]} ${start.day}–${months[end.month - 1]} ${end.day}, ${end.year}';
  }
  return '${months[start.month - 1]} ${start.day}, ${start.year}–${months[end.month - 1]} ${end.day}, ${end.year}';
}
