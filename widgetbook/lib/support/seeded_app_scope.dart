import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ritu/data/repositories/daily_log_repository.dart';
import 'package:ritu/data/repositories/journal_entry_repository.dart';
import 'package:ritu/data/repositories/memory/memory_daily_log_repository.dart';
import 'package:ritu/data/repositories/memory/memory_journal_entry_repository.dart';
import 'package:ritu/data/repositories/memory/memory_period_repository.dart';
import 'package:ritu/data/repositories/memory/memory_profile_repository.dart';
import 'package:ritu/data/repositories/memory/memory_ritu_store.dart';
import 'package:ritu/data/repositories/memory/memory_symptom_repository.dart';
import 'package:ritu/data/repositories/period_repository.dart';
import 'package:ritu/data/repositories/profile_repository.dart';
import 'package:ritu/data/repositories/symptom_repository.dart';
import 'package:ritu/providers/repository_providers.dart';

/// The four repositories a use-case's [SeededAppScope.seed] callback can use
/// to fake data before the wrapped screen is shown.
class RituRepos {
  RituRepos(
    this.profiles,
    this.periods,
    this.symptoms,
    this.dailyLogs,
    this.journalEntries,
  );

  final ProfileRepository profiles;
  final PeriodRepository periods;
  final SymptomRepository symptoms;
  final DailyLogRepository dailyLogs;
  final JournalEntryRepository journalEntries;
}

/// Wraps [builder] in a [ProviderScope] backed by in-memory repository fakes,
/// after running [seed] — works on web and native without Drift/SQLite.
///
/// Screens read data through Riverpod stream providers; the memory repos emit
/// the same reactive updates as the Drift implementations used in tests.
class SeededAppScope extends StatefulWidget {
  const SeededAppScope({super.key, required this.seed, required this.builder});

  final Future<void> Function(RituRepos repos) seed;
  final WidgetBuilder builder;

  @override
  State<SeededAppScope> createState() => _SeededAppScopeState();
}

class _SeededAppScopeState extends State<SeededAppScope> {
  MemoryRituStore? _store;
  RituRepos? _repos;
  var _ready = false;

  @override
  void initState() {
    super.initState();
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
    await widget.seed(repos);
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

  @override
  void dispose() {
    _store?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Center(child: CircularProgressIndicator());
    }

    final repos = _repos!;

    return ProviderScope(
      overrides: [
        profileRepositoryProvider.overrideWithValue(repos.profiles),
        periodRepositoryProvider.overrideWithValue(repos.periods),
        symptomRepositoryProvider.overrideWithValue(repos.symptoms),
        dailyLogRepositoryProvider.overrideWithValue(repos.dailyLogs),
        journalEntryRepositoryProvider.overrideWithValue(repos.journalEntries),
      ],
      child: Builder(builder: widget.builder),
    );
  }
}

/// Creates a profile that has already completed onboarding — the baseline
/// most screen-level use-cases need.
Future<void> seedOnboardedProfile(
  RituRepos repos, {
  String name = 'Maya',
}) async {
  await repos.profiles.upsertDisplayName(name);
  await repos.profiles.markOnboardingCompleted();
}
