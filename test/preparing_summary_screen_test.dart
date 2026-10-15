import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ritu/features/summary/preparing_summary_screen.dart';
import 'package:ritu/features/summary/summary_report.dart';
import 'package:ritu/features/summary/summary_time_range.dart';
import 'package:ritu/theme/ritu_theme.dart';

void main() {
  testWidgets('walks the checklist and shares the PDF', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Uint8List? shared;
    final request = SummaryReportRequest(
      window: SummaryDateWindow(
        start: DateTime(2026, 4, 1),
        end: DateTime(2026, 4, 10),
      ),
      generatedOn: DateTime(2026, 4, 10),
      includes: const SummaryIncludes(
        cycleLength: true,
        moodPatterns: false,
        energyPatterns: false,
        bodySignals: false,
        sleepLogs: false,
        wellbeingScore: false,
        journalEntries: false,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: buildRituTheme(),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => PreparingSummaryScreen(
                    request: request,
                    logs: const [],
                    periods: const [],
                    journals: const [],
                    sharePdf: (bytes) async {
                      shared = bytes;
                    },
                  ),
                ),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Preparing your summary'), findsOneWidget);
    expect(find.text('Collecting your log data'), findsOneWidget);
    expect(find.text('This may take a few moments'), findsOneWidget);
    expect(tester.getSize(find.byType(Image)).height, 320);

    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 700));
    }

    expect(shared, isNotNull);
    expect(String.fromCharCodes(shared!.take(4)), '%PDF');
    expect(find.text('Open'), findsOneWidget);
  });
}
