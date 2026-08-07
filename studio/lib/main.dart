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

  void _syncDailyLogs() {
    context.studioController.applyDailyLogs(
      loggedDaysCount: _loggedDaysCount,
      loggedToday: _loggedToday,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final stackVertically = constraints.maxWidth < 900;
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
          );

          if (stackVertically) {
            return Column(
              children: [
                SizedBox(
                  height: constraints.maxHeight * 0.45,
                  child: controlPanel,
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      SizedBox(
                        height: 720,
                        child: const PreviewPanel(),
                      ),
                      const SizedBox(height: 16),
                      const DebugPanel(),
                    ],
                  ),
                ),
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
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    SizedBox(
                      height: 760,
                      child: const PreviewPanel(),
                    ),
                    const SizedBox(height: 20),
                    const DebugPanel(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
