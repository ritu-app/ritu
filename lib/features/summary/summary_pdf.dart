import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/cycle/cycle_phase.dart';
import '../../core/date_format.dart';
import 'summary_report.dart';

const _ink = PdfColor.fromInt(0xFF322F2D);
const _muted = PdfColor.fromInt(0xFF69635F);
const _line = PdfColor.fromInt(0xFFE6E1DC);
const _card = PdfColor.fromInt(0xFFF7F4F1);
const _flag = PdfColor.fromInt(0xFFC45C5C);
const _note = PdfColor.fromInt(0xFFB09149);
const _steady = PdfColor.fromInt(0xFF5F8F7A);

const _phaseColor = {
  CyclePhase.menstrual: PdfColor.fromInt(0xFFC98A8A),
  CyclePhase.follicular: PdfColor.fromInt(0xFF6FA17C),
  CyclePhase.ovulatory: PdfColor.fromInt(0xFFB09149),
  CyclePhase.luteal: PdfColor.fromInt(0xFF7E7393),
};

/// A4 summary PDF for [report]. Fonts are the bundled DM Sans and DM Serif files.
Future<Uint8List> buildSummaryPdf(SummaryReport report) async {
  final regular = pw.Font.ttf(
    await rootBundle.load('assets/fonts/DMSans-Regular.ttf'),
  );
  final semibold = pw.Font.ttf(
    await rootBundle.load('assets/fonts/DMSans-SemiBold.ttf'),
  );
  final italic = pw.Font.ttf(
    await rootBundle.load('assets/fonts/DMSans-Italic.ttf'),
  );
  final serif = pw.Font.ttf(
    await rootBundle.load('assets/fonts/DMSerifDisplay-Regular.ttf'),
  );

  final doc = pw.Document(
    theme: pw.ThemeData.withFont(
      base: regular,
      bold: semibold,
      italic: italic,
      boldItalic: semibold,
    ),
  );

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(40, 36, 40, 48),
      footer: (context) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 10),
        child: pw.Text(
          'This report reflects patterns observed in self-reported data logged in the Ritu app. It is not a medical diagnosis.',
          style: const pw.TextStyle(
            fontSize: 8,
            color: _muted,
            fontStyle: pw.FontStyle.italic,
          ),
        ),
      ),
      build: (context) => [
        _header(report, serif),
        pw.SizedBox(height: 18),
        pw.Text(
          'Cycle Summary',
          style: pw.TextStyle(font: serif, fontSize: 20, color: _ink),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          '${report.dateRangeLabel} · ${report.classificationLabel}',
          style: const pw.TextStyle(fontSize: 10, color: _muted),
        ),
        pw.SizedBox(height: 16),
        _sectionLabel('Summary'),
        pw.SizedBox(height: 4),
        pw.Text(
          report.summary,
          style: const pw.TextStyle(fontSize: 11, color: _ink, lineSpacing: 3),
        ),
        pw.SizedBox(height: 14),
        _stats(report.stats, semibold),
        if (report.findings.isNotEmpty) ...[
          pw.SizedBox(height: 16),
          _sectionLabel('Key findings'),
          pw.SizedBox(height: 8),
          for (final finding in report.findings) ...[
            _finding(finding),
            pw.SizedBox(height: 6),
          ],
        ],
        if (report.includes.wellbeingScore) ...[
          pw.SizedBox(height: 12),
          _sectionLabel('Wellbeing by cycle phase'),
          pw.SizedBox(height: 8),
          if (report.wellbeing.isEmpty)
            _empty('No wellbeing scores in this range.')
          else
            for (final bar in report.wellbeing) ...[
              _wellbeingBar(bar),
              pw.SizedBox(height: 6),
            ],
        ],
        if (report.includes.cycleLength) ...[
          pw.SizedBox(height: 16),
          _sectionLabel('Cycle length record'),
          pw.SizedBox(height: 8),
          if (report.cycles.isEmpty)
            _empty('No cycles in this range.')
          else
            _table(
              headers: const ['Start date', 'Length', 'Period duration'],
              rows: [
                for (final cycle in report.cycles)
                  [
                    formatShortMonthDayYear(cycle.start),
                    cycle.length,
                    cycle.periodDuration,
                  ],
              ],
            ),
        ],
        if (report.includes.showsPhaseTable) ...[
          pw.SizedBox(height: 16),
          _sectionLabel('Mood, energy & sleep by phase'),
          pw.SizedBox(height: 8),
          if (report.phasePatterns.isEmpty)
            _empty('No phased logs in this range.')
          else
            _table(
              headers: [
                'Phase',
                if (report.includes.moodPatterns) 'Most common mood',
                if (report.includes.energyPatterns) 'Energy',
                if (report.includes.sleepLogs) 'Sleep',
              ],
              rows: [
                for (final row in report.phasePatterns)
                  [
                    phaseShortLabel(row.phase),
                    if (report.includes.moodPatterns) row.mood,
                    if (report.includes.energyPatterns) row.energy,
                    if (report.includes.sleepLogs) row.sleep,
                  ],
              ],
            ),
        ],
        if (report.includes.bodySignals) ...[
          pw.SizedBox(height: 16),
          _sectionLabel('Body signals logged'),
          pw.SizedBox(height: 8),
          if (report.bodySignals.isEmpty)
            _empty('No body signals in this range.')
          else
            _table(
              headers: const ['Signal', 'Days logged', 'Most common timing'],
              rows: [
                for (final row in report.bodySignals)
                  [row.signal, '${row.daysLogged}', row.timing],
              ],
            ),
        ],
        if (report.includes.journalEntries) ...[
          pw.SizedBox(height: 16),
          _sectionLabel('Journal entries'),
          pw.SizedBox(height: 8),
          if (report.journals.isEmpty)
            _empty('No journal entries in this range.')
          else
            for (final entry in report.journals) ...[
              pw.Text(
                formatJournalEntryDate(entry.loggedOn),
                style: pw.TextStyle(font: semibold, fontSize: 11, color: _ink),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                entry.body,
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: _ink,
                  lineSpacing: 2,
                ),
              ),
              pw.SizedBox(height: 10),
            ],
        ],
      ],
    ),
  );

  return doc.save();
}

pw.Widget _header(SummaryReport report, pw.Font serif) {
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Ritu',
            style: pw.TextStyle(font: serif, fontSize: 18, color: _ink),
          ),
          pw.Text(
            'Personal health journal',
            style: const pw.TextStyle(fontSize: 9, color: _muted),
          ),
        ],
      ),
      pw.Spacer(),
      pw.Text(
        'Generated ${formatShortMonthDayYear(report.generatedOn)}',
        style: const pw.TextStyle(fontSize: 9, color: _muted),
      ),
    ],
  );
}

pw.Widget _sectionLabel(String text) {
  return pw.Text(
    text.toUpperCase(),
    style: pw.TextStyle(
      fontSize: 9,
      fontWeight: pw.FontWeight.bold,
      color: _ink,
      letterSpacing: 0.7,
    ),
  );
}

pw.Widget _empty(String text) {
  return pw.Text(text, style: const pw.TextStyle(fontSize: 10, color: _muted));
}

pw.Widget _stats(List<SummaryStat> stats, pw.Font semibold) {
  return pw.Row(
    children: [
      for (var i = 0; i < stats.length; i++) ...[
        if (i > 0) pw.SizedBox(width: 6),
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: pw.BoxDecoration(
              color: _card,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  stats[i].value,
                  style: pw.TextStyle(
                    font: semibold,
                    fontSize: 14,
                    color: _ink,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  stats[i].label,
                  style: const pw.TextStyle(fontSize: 8, color: _muted),
                ),
              ],
            ),
          ),
        ),
      ],
    ],
  );
}

pw.Widget _finding(SummaryFinding finding) {
  final label = switch (finding.kind) {
    SummaryFindingKind.flag => 'Flag',
    SummaryFindingKind.note => 'Note',
    SummaryFindingKind.consistent => 'Consistent',
  };
  final color = switch (finding.kind) {
    SummaryFindingKind.flag => _flag,
    SummaryFindingKind.note => _note,
    SummaryFindingKind.consistent => _steady,
  };
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.SizedBox(
        width: 72,
        child: pw.Text(
          label.toUpperCase(),
          style: pw.TextStyle(
            fontSize: 8,
            fontWeight: pw.FontWeight.bold,
            color: color,
            letterSpacing: 0.4,
          ),
        ),
      ),
      pw.Expanded(
        child: pw.Text(
          finding.text,
          style: const pw.TextStyle(fontSize: 10, color: _ink, lineSpacing: 2),
        ),
      ),
    ],
  );
}

pw.Widget _wellbeingBar(WellbeingBar bar) {
  final ratio = (bar.score / 10).clamp(0.0, 1.0);
  final fillFlex = (ratio * 100).round();
  final trackFlex = 100 - fillFlex;
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.center,
    children: [
      pw.SizedBox(
        width: 72,
        child: pw.Text(
          phaseShortLabel(bar.phase),
          style: const pw.TextStyle(fontSize: 10, color: _ink),
        ),
      ),
      pw.Expanded(
        child: pw.Row(
          children: [
            if (fillFlex > 0)
              pw.Expanded(
                flex: fillFlex,
                child: pw.Container(
                  height: 8,
                  decoration: pw.BoxDecoration(
                    color: _phaseColor[bar.phase],
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                ),
              ),
            if (trackFlex > 0)
              pw.Expanded(
                flex: trackFlex,
                child: pw.Container(
                  height: 8,
                  decoration: pw.BoxDecoration(
                    color: const PdfColor.fromInt(0xFFEFEFEF),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                ),
              ),
          ],
        ),
      ),
      pw.SizedBox(width: 8),
      pw.SizedBox(
        width: 36,
        child: pw.Text(
          '${bar.score.toStringAsFixed(1)}/10',
          textAlign: pw.TextAlign.right,
          style: const pw.TextStyle(fontSize: 9, color: _muted),
        ),
      ),
    ],
  );
}

pw.Widget _table({
  required List<String> headers,
  required List<List<String>> rows,
}) {
  return pw.TableHelper.fromTextArray(
    headers: headers,
    data: rows,
    headerStyle: pw.TextStyle(
      fontSize: 8,
      fontWeight: pw.FontWeight.bold,
      color: _muted,
    ),
    cellStyle: const pw.TextStyle(fontSize: 9, color: _ink),
    headerDecoration: const pw.BoxDecoration(color: _card),
    headerAlignment: pw.Alignment.centerLeft,
    cellAlignment: pw.Alignment.centerLeft,
    cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
    border: const pw.TableBorder(
      top: pw.BorderSide(color: _line, width: 0.4),
      bottom: pw.BorderSide(color: _line, width: 0.4),
      horizontalInside: pw.BorderSide(color: _line, width: 0.4),
    ),
  );
}
