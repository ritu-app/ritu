import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/daily_log_entry.dart';
import '../../data/models/journal_entry.dart';
import '../../data/models/period_log.dart';
import '../../theme/ritu_palette.dart';
import 'summary_pdf.dart';
import 'summary_report.dart';

typedef SummaryPdfShare = Future<void> Function(Uint8List bytes);

/// Full-screen wait while the summary PDF is built (Figma 972-3615).
class PreparingSummaryScreen extends StatefulWidget {
  const PreparingSummaryScreen({
    super.key,
    required this.request,
    required this.logs,
    required this.periods,
    required this.journals,
    this.sharePdf,
  });

  final SummaryReportRequest request;
  final List<DailyLogEntry> logs;
  final List<PeriodLog> periods;
  final List<JournalEntry> journals;

  /// When omitted, the PDF is written to a temp file and opened in the
  /// system share sheet.
  final SummaryPdfShare? sharePdf;

  @override
  State<PreparingSummaryScreen> createState() => _PreparingSummaryScreenState();
}

class _PreparingSummaryScreenState extends State<PreparingSummaryScreen> {
  static const _steps = [
    'Collecting your log data',
    'Finding recurring patterns',
    'Organising your history',
    'Almost ready......',
  ];

  Timer? _timer;
  var _completed = 0;
  Uint8List? _bytes;
  var _sharing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _generate();
    _timer = Timer.periodic(const Duration(milliseconds: 700), _tick);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _generate() async {
    try {
      final report = buildSummaryReport(
        request: widget.request,
        logs: widget.logs,
        periods: widget.periods,
        journals: widget.journals,
      );
      final bytes = await buildSummaryPdf(report);
      if (!mounted) return;
      setState(() => _bytes = bytes);
    } catch (error) {
      if (!mounted) return;
      _timer?.cancel();
      setState(() => _error = 'The summary could not be prepared.');
    }
  }

  void _tick(Timer timer) {
    if (!mounted || _error != null) return;
    if (_completed < _steps.length - 1) {
      setState(() => _completed++);
      return;
    }
    final bytes = _bytes;
    if (bytes == null || _sharing) return;
    _sharing = true;
    timer.cancel();
    setState(() => _completed = _steps.length);
    _finish(bytes);
  }

  Future<void> _finish(Uint8List bytes) async {
    try {
      final share = widget.sharePdf ?? (data) => _shareFile(context, data);
      await share(bytes);
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'The summary could not be shared.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.ritu.backgroundPage,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 36, 16, 24),
          child: Column(
            children: [
              Text(
                'Preparing your summary',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  height: 34 / 28,
                  color: context.ritu.textPrimary,
                ),
              ),
              const SizedBox(height: 38),
              const SizedBox(
                height: 320,
                width: double.infinity,
                child: Image(
                  image: AssetImage('assets/images/summary_preparing.png'),
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 9),
              Center(
                child: SizedBox(
                  width: 252,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < _steps.length; i++) ...[
                        _StepRow(label: _steps[i], done: i < _completed),
                        if (i < _steps.length - 1)
                          Padding(
                            padding: EdgeInsets.only(left: 11),
                            child: SizedBox(
                              width: 2,
                              height: 22,
                              child: ColoredBox(color: context.ritu.sage500),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
              const Spacer(),
              if (_error != null) ...[
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 20 / 13,
                    color: context.ritu.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Go back'),
                ),
              ] else
                Text(
                  'This may take a few moments',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 20 / 13,
                    color: context.ritu.textSecondary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.label, required this.done});

  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        done
            ? Icon(
                LucideIcons.circleCheck,
                size: 24,
                color: context.ritu.sage500,
              )
            : Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: context.ritu.sage600, width: 1.5),
                ),
              ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 24 / 15,
              color: context.ritu.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> _shareFile(BuildContext context, Uint8List bytes) async {
  final size = MediaQuery.sizeOf(context);
  final origin = Rect.fromCenter(
    center: Offset(size.width / 2, size.height / 2),
    width: 1,
    height: 1,
  );
  final dir = await getTemporaryDirectory();
  final stamp = DateTime.now().toIso8601String().split('T').first;
  final file = File(p.join(dir.path, 'ritu-summary-$stamp.pdf'));
  await file.writeAsBytes(bytes, flush: true);
  await Share.shareXFiles(
    [XFile(file.path, mimeType: 'application/pdf')],
    subject: 'Ritu cycle summary',
    sharePositionOrigin: origin,
  );
}
