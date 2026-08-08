import 'package:flutter/material.dart';

import 'models/cycle_history_draft.dart';
import 'panels/control_panel.dart';
import 'panels/debug_panel.dart';
import 'panels/preview_panel.dart';
import 'presets/cycle_presets.dart';
import 'scope/studio_scope.dart';

void main() {
  runApp(const CycleStudioApp());
}

class CycleStudioApp extends StatelessWidget {
  const CycleStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cycle Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5F8F7A)),
        useMaterial3: true,
      ),
      home: const StudioScope(child: CycleStudioShell()),
    );
  }
}

class CycleStudioShell extends StatefulWidget {
  const CycleStudioShell({super.key});

  @override
  State<CycleStudioShell> createState() => _CycleStudioShellState();
}

class _CycleStudioShellState extends State<CycleStudioShell> {
  late CycleHistoryDraft _historyDraft =
      CycleHistoryDraft.fromPreset(CyclePreset.regular);
  var _loggedDaysCount = 0;
  var _loggedToday = false;
  var _journalTodayBody = '';
  var _pastJournalCount = 0;

  void _syncDailyLogs() {
    context.studioController.applyDailyLogs(
      loggedDaysCount: _loggedDaysCount,
      loggedToday: _loggedToday,
    );
  }

  void _syncJournal() {
    context.studioController.applyJournal(
      todayBody: _journalTodayBody,
      pastEntryCount: _pastJournalCount,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controlPanel = ControlPanel(
      historyDraft: _historyDraft,
      onHistoryDraftChanged: (draft) {
        setState(() => _historyDraft = draft);
      },
      loggedDaysCount: _loggedDaysCount,
      loggedToday: _loggedToday,
      onLoggedDaysChanged: (count) {
        setState(() => _loggedDaysCount = count);
        _syncDailyLogs();
      },
      onLoggedTodayChanged: (logged) {
        setState(() => _loggedToday = logged);
        _syncDailyLogs();
      },
      journalTodayBody: _journalTodayBody,
      pastJournalCount: _pastJournalCount,
      onJournalTodayBodyChanged: (body) {
        setState(() => _journalTodayBody = body);
        _syncJournal();
      },
      onPastJournalCountChanged: (count) {
        setState(() => _pastJournalCount = count);
        _syncJournal();
      },
    );

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final stackControls = constraints.maxWidth < 900;

          if (stackControls) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: constraints.maxHeight * 0.42,
                  child: ColoredBox(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    child: controlPanel,
                  ),
                ),
                const Divider(height: 1),
                Expanded(child: _PreviewAndDebugRow()),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 380,
                child: ColoredBox(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  child: controlPanel,
                ),
              ),
              const VerticalDivider(width: 1),
              const Expanded(child: _PreviewAndDebugRow()),
            ],
          );
        },
      ),
    );
  }
}

/// Preview and debug side by side — preview scroll stays inside the device frame.
class _PreviewAndDebugRow extends StatelessWidget {
  const _PreviewAndDebugRow();

  static const _debugWidth = 300.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Expanded(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: PreviewPanel(),
          ),
        ),
        const VerticalDivider(width: 1),
        SizedBox(
          width: _debugWidth,
          child: ColoredBox(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            child: const SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: DebugPanel(),
            ),
          ),
        ),
      ],
    );
  }
}
