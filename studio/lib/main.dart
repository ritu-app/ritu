import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ritu/core/date_format.dart';
import 'package:ritu/core/home_greeting.dart';
import 'package:ritu/theme/ritu_colors.dart';
import 'package:ritu/theme/ritu_theme.dart';
import 'package:url_launcher/url_launcher.dart';

import 'models/cycle_history_draft.dart';
import 'panels/console_column.dart';
import 'panels/control_panel.dart';
import 'panels/logged_data_section.dart';
import 'panels/preview_panel.dart';
import 'panels/scenario_readout.dart';
import 'presets/logged_density.dart';
import 'presets/studio_scenario.dart';
import 'scope/studio_scope.dart';
import 'theme/studio_styles.dart';
import 'util/studio_labels.dart';

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
      theme: buildRituTheme(),
      home: const StudioBackdrop(child: StudioScope(child: CycleStudioShell())),
    );
  }
}

class CycleStudioShell extends StatefulWidget {
  const CycleStudioShell({super.key});

  @override
  State<CycleStudioShell> createState() => _CycleStudioShellState();
}

class _CycleStudioShellState extends State<CycleStudioShell> {
  static final _githubUri = Uri.parse('https://github.com/ritu-app/ritu');
  static final _supportUri = Uri(scheme: 'mailto', path: 'support@ritu.care');

  late CycleHistoryDraft _historyDraft = StudioScenario.regularCycle
      .historyDraft();
  var _scenario = StudioScenario.regularCycle;
  var _logDensity = DailyLogDensity.none;
  var _journalDensity = JournalDensity.off;
  var _loggedToday = false;
  var _logGeneration = 0;
  ConsoleSection? _expanded;
  final List<String> _changes = [];

  void _toggle(ConsoleSection section) {
    setState(() {
      _expanded = _expanded == section ? null : section;
    });
  }

  void _note(String message) {
    setState(() {
      if (_changes.isNotEmpty && _changes.first == message) return;
      _changes.insert(0, message);
      if (_changes.length > 5) {
        _changes.removeRange(5, _changes.length);
      }
    });
  }

  void _syncLoggedData() {
    final controller = context.studioController;
    controller.applyDailyLogs(
      loggedDaysCount: _logDensity.days,
      loggedToday: _loggedToday,
      generation: _logGeneration,
    );
    controller.applyJournal(
      todayBody: loggedJournalBody(_journalDensity, _logGeneration),
      pastEntryCount: _journalDensity.pastCount,
      generation: _logGeneration,
    );
  }

  void _onDate(DateTime picked) {
    final controller = context.studioController;
    final previous = dateOnly(controller.simulatedToday);
    final next = dateOnly(picked);
    final delta = next.difference(previous).inDays;
    controller.setSimulatedToday(next);
    final maxDay = _scenario.maxCycleDay;
    final naturalDay = _historyDraft.currentCycleDay + delta;
    if (delta != 0 && naturalDay > maxDay) {
      final updated = _historyDraft.withCurrentCycleDay(
        cycleDay: maxDay,
        simulatedToday: next,
      );
      setState(() => _historyDraft = updated);
      controller.applyHistory(updated);
    } else if (delta != 0) {
      setState(() {
        _historyDraft = _historyDraft.copyWith(
          currentCycleDay: naturalDay.clamp(1, maxDay),
        );
      });
    }
    if (previous != next) {
      _note(
        'Changed simulated ${formatStudioMonthDay(previous)} to ${formatStudioMonthDay(next)}',
      );
    }
  }

  void _onWindow(GreetingTimeWindow window) {
    context.studioController.setGreetingTimeWindow(window);
    _note('Changed time of day to ${greetingWindowShortLabel(window)}');
  }

  void _onCycleDay(int day) {
    final controller = context.studioController;
    final updated = _historyDraft.withCurrentCycleDay(
      cycleDay: day.clamp(1, _scenario.maxCycleDay),
      simulatedToday: controller.simulatedToday,
    );
    setState(() => _historyDraft = updated);
    controller.applyHistory(updated);
  }

  void _onCycleDayCommit(int day) {
    _note('Changed cycle day to $day');
  }

  Future<void> _onScenario(StudioScenario scenario) async {
    final draft = scenario.historyDraft();
    setState(() {
      _scenario = scenario;
      _historyDraft = draft;
    });
    await context.studioController.applyHistory(draft);
    if (!mounted) return;
    _note('Switched to ${scenario.shortLabel}');
  }

  void _onHistory(CycleHistoryDraft draft) {
    final message = switch (draft.rows.length.compareTo(
      _historyDraft.rows.length,
    )) {
      > 0 => 'Added a cycle',
      < 0 => 'Removed a cycle',
      _ => 'Updated a cycle',
    };
    setState(() => _historyDraft = draft);
    context.studioController.applyHistory(draft);
    _note(message);
  }

  Future<void> _onExport() async {
    await exportStudioBackup(context);
    if (!mounted) return;
    _note('Exported the scenario');
  }

  Future<void> _reset() async {
    final controller = context.studioController;
    final today = dateOnly(DateTime.now());
    controller.setSimulatedToday(today);
    controller.setGreetingTimeWindow(greetingTimeWindowFor(DateTime.now()));
    final regular = StudioScenario.regularCycle.historyDraft();
    setState(() {
      _scenario = StudioScenario.regularCycle;
      _historyDraft = regular;
      _logDensity = DailyLogDensity.none;
      _journalDensity = JournalDensity.off;
      _loggedToday = false;
      _logGeneration = 0;
      _expanded = null;
      _changes.clear();
    });
    await controller.applyHistory(regular);
    await controller.applyDailyLogs(
      loggedDaysCount: 0,
      loggedToday: false,
      generation: 0,
    );
    await controller.applyJournal(
      todayBody: '',
      pastEntryCount: 0,
      generation: 0,
    );
  }

  Future<void> _openLink(Uri uri) async {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Couldn’t open that link')));
    }
  }

  void _getTheApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('App Store listing coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.studioController;
    final window = greetingTimeWindowFor(controller.simulatedClock);

    final console = ConsoleColumn(
      expanded: _expanded,
      onToggle: _toggle,
      date: controller.simulatedToday,
      window: window,
      historyDraft: _historyDraft,
      onDate: _onDate,
      onWindow: _onWindow,
      onCycleDay: _onCycleDay,
      onCycleDayCommit: _onCycleDayCommit,
      scenario: _scenario,
      onScenario: _onScenario,
      onHistoryDraftChanged: _onHistory,
      logDensity: _logDensity,
      journalDensity: _journalDensity,
      loggedToday: _loggedToday,
      onLogDensity: (density) {
        setState(() => _logDensity = density);
        _syncLoggedData();
        _note('Changed daily log to ${density.label}');
      },
      onJournalDensity: (density) {
        setState(() => _journalDensity = density);
        _syncLoggedData();
        _note('Changed journal to ${density.label}');
      },
      onLoggedToday: (logged) {
        setState(() => _loggedToday = logged);
        _syncLoggedData();
        _note(logged ? "Logged today's check-in" : "Cleared today's check-in");
      },
      onRegenerate: () {
        setState(() => _logGeneration += 1);
        _syncLoggedData();
        _note('Regenerated logged data');
      },
      onExport: _onExport,
      onReset: _reset,
    );

    final readout = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionIntro(
          label: 'How Ritu got here',
          body:
              'The reasoning behind what\'s on screen right now, updates with anything you change on the left.',
        ),
        const ScenarioReadout(),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 1100;
          final header = _StudioHeader(
            wide: wide,
            onGithub: () => _openLink(_githubUri),
            onGetTheApp: _getTheApp,
          );
          final footer = _StudioFooter(onSupport: () => _openLink(_supportUri));

          if (!wide) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  header,
                  const SizedBox(height: 28),
                  console,
                  const SizedBox(height: 28),
                  const SizedBox(height: 640, child: PreviewPanel()),
                  const SizedBox(height: 28),
                  readout,
                  const SizedBox(height: 16),
                  RecentChangesCard(changes: _changes),
                  const SizedBox(height: 28),
                  footer,
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(60, 30, 60, 24),
            child: Column(
              children: [
                header,
                const SizedBox(height: 28),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: 334,
                        child: SingleChildScrollView(child: console),
                      ),
                      const Expanded(child: PreviewPanel()),
                      SizedBox(
                        width: 334,
                        child: LayoutBuilder(
                          builder: (context, column) {
                            return SingleChildScrollView(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: column.maxHeight,
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    readout,
                                    Padding(
                                      padding: const EdgeInsets.only(top: 16),
                                      child: RecentChangesCard(
                                        changes: _changes,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                footer,
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionIntro extends StatelessWidget {
  const _SectionIntro({required this.label, required this.body});

  final String label;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: StudioText.sectionLabel),
        Text(body, style: StudioText.sectionBody),
        const SizedBox(height: 16),
        const Divider(height: 1, thickness: 1, color: RituColors.borderSubtle),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _StudioHeader extends StatelessWidget {
  const _StudioHeader({
    required this.wide,
    required this.onGithub,
    required this.onGetTheApp,
  });

  final bool wide;
  final VoidCallback onGithub;
  final VoidCallback onGetTheApp;

  @override
  Widget build(BuildContext context) {
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ritu', style: StudioText.displayTitle),
            const SizedBox(width: 8),
            Text('Cycle Studio', style: StudioText.wordmark),
          ],
        ),
        Text('Interactive playground', style: StudioText.eyebrow),
      ],
    );
    final links = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _HeaderLink(label: 'View on GitHub', onTap: onGithub),
        const SizedBox(width: 32),
        _HeaderLink(label: 'Get the app', onTap: onGetTheApp),
      ],
    );

    if (!wide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [title, const SizedBox(height: 12), links],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [title, const Spacer(), links],
    );
  }
}

class _HeaderLink extends StatelessWidget {
  const _HeaderLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: StudioText.link),
            const Icon(
              LucideIcons.arrowUpRight,
              size: 20,
              color: RituColors.fillBrandPressed,
            ),
          ],
        ),
      ),
    );
  }
}

class _StudioFooter extends StatelessWidget {
  const _StudioFooter({required this.onSupport});

  final VoidCallback onSupport;

  @override
  Widget build(BuildContext context) {
    final copy = Text(
      '© ${DateTime.now().year} Ritu.care',
      style: StudioText.footer,
    );
    final mail = MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onSupport,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.mail, size: 16, color: studioIcon),
            const SizedBox(width: 4),
            Text('support@ritu.care', style: StudioText.footer),
          ],
        ),
      ),
    );

    return Row(children: [copy, const Spacer(), mail]);
  }
}
