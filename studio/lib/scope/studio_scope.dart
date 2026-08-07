import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ritu/core/date_format.dart';
import 'package:ritu/data/repositories/memory/memory_daily_log_repository.dart';
import 'package:ritu/data/repositories/memory/memory_journal_entry_repository.dart';
import 'package:ritu/data/repositories/memory/memory_period_repository.dart';
import 'package:ritu/data/repositories/memory/memory_profile_repository.dart';
import 'package:ritu/data/repositories/memory/memory_ritu_store.dart';
import 'package:ritu/data/repositories/memory/memory_symptom_repository.dart';
import 'package:ritu/providers/repository_providers.dart';
import 'package:ritu/providers/simulated_today_provider.dart';

import '../models/cycle_history_draft.dart';
import '../presets/cycle_presets.dart';
import '../presets/daily_log_controls.dart';
import 'ritu_repos.dart';

/// Mutable in-memory app state for Cycle Studio.
class StudioController {
  StudioController({
    required this.repos,
    required this.simulatedToday,
    required this.setSimulatedToday,
    required this.applyPreset,
    required this.applyHistory,
    required this.applyDailyLogs,
    required this.loadHistoryDraft,
  });

  final RituRepos repos;
  final DateTime simulatedToday;
  final ValueChanged<DateTime> setSimulatedToday;
  final Future<void> Function(CyclePreset preset) applyPreset;
  final Future<void> Function(CycleHistoryDraft draft) applyHistory;
  final Future<void> Function({
    required int loggedDaysCount,
    required bool loggedToday,
  }) applyDailyLogs;
  final Future<CycleHistoryDraft> Function() loadHistoryDraft;
}

/// Wraps [child] in the production Riverpod graph backed by memory repos.
class StudioScope extends StatefulWidget {
  const StudioScope({super.key, required this.child});

  final Widget child;

  static StudioController of(BuildContext context) {
    return context.studioController;
  }

  @override
  State<StudioScope> createState() => _StudioScopeState();
}

class _StudioScopeState extends State<StudioScope> {
  MemoryRituStore? _store;
  RituRepos? _repos;
  late DateTime _simulatedToday;
  var _ready = false;

  @override
  void initState() {
    super.initState();
    _simulatedToday = dateOnly(DateTime.now());
    _init();
  }

  Future<void> _init() async {
    final store = MemoryRituStore();
    final repos = RituRepos(
      MemoryProfileRepository(store),
      MemoryPeriodRepository(store),
      MemorySymptomRepository(store),
      MemoryDailyLogRepository(store),
      MemoryJournalEntryRepository(store),
    );

    await seedOnboardedProfile(repos);
    await applyPreset(repos, CyclePreset.regular, _simulatedToday);

    if (!mounted) {
      store.dispose();
      return;
    }

    setState(() {
      _store = store;
      _repos = repos;
      _ready = true;
    });
  }

  void _setSimulatedToday(DateTime date) {
    setState(() => _simulatedToday = dateOnly(date));
  }

  Future<void> _applyPreset(CyclePreset preset) {
    return applyPreset(_repos!, preset, _simulatedToday);
  }

  Future<void> _applyHistory(CycleHistoryDraft draft) {
    return applyHistoryDraft(_repos!, draft, _simulatedToday);
  }

  Future<void> _applyDailyLogs({
    required int loggedDaysCount,
    required bool loggedToday,
  }) {
    return applyDailyLogState(
      repos: _repos!,
      simulatedToday: _simulatedToday,
      loggedDaysCount: loggedDaysCount,
      loggedToday: loggedToday,
    );
  }

  Future<CycleHistoryDraft> _loadHistoryDraft() async {
    final logs = await _repos!.periods.getAll();
    return CycleHistoryDraft.fromPeriodLogs(
      logs: logs,
      simulatedToday: _simulatedToday,
    );
  }

  @override
  void dispose() {
    _store?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final repos = _repos!;
    final liveController = StudioController(
      repos: repos,
      simulatedToday: _simulatedToday,
      setSimulatedToday: _setSimulatedToday,
      applyPreset: _applyPreset,
      applyHistory: _applyHistory,
      applyDailyLogs: _applyDailyLogs,
      loadHistoryDraft: _loadHistoryDraft,
    );

    return ProviderScope(
      overrides: [
        profileRepositoryProvider.overrideWithValue(repos.profiles),
        periodRepositoryProvider.overrideWithValue(repos.periods),
        symptomRepositoryProvider.overrideWithValue(repos.symptoms),
        dailyLogRepositoryProvider.overrideWithValue(repos.dailyLogs),
        journalEntryRepositoryProvider.overrideWithValue(repos.journalEntries),
        simulatedTodayProvider.overrideWith((ref) => _simulatedToday),
      ],
      child: _StudioControllerScope(
        controller: liveController,
        child: widget.child,
      ),
    );
  }
}

class _StudioControllerScope extends InheritedWidget {
  const _StudioControllerScope({
    required this.controller,
    required super.child,
  });

  final StudioController controller;

  @override
  bool updateShouldNotify(_StudioControllerScope oldWidget) {
    return controller.simulatedToday != oldWidget.controller.simulatedToday;
  }
}

extension StudioScopeLookup on BuildContext {
  StudioController get studioController {
    final scope =
        dependOnInheritedWidgetOfExactType<_StudioControllerScope>();
    assert(scope != null, 'StudioScope not found above $this');
    return scope!.controller;
  }
}
