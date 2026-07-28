import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ritu/app/app_scope.dart';
import 'package:ritu/data/local/app_database.dart';
import 'package:ritu/data/repositories/daily_log_repository.dart';
import 'package:ritu/data/repositories/drift/drift_daily_log_repository.dart';
import 'package:ritu/data/repositories/drift/drift_period_repository.dart';
import 'package:ritu/data/repositories/drift/drift_profile_repository.dart';
import 'package:ritu/data/repositories/drift/drift_symptom_repository.dart';
import 'package:ritu/data/repositories/period_repository.dart';
import 'package:ritu/data/repositories/profile_repository.dart';
import 'package:ritu/data/repositories/symptom_repository.dart';

/// The four repositories a use-case's [SeededAppScope.seed] callback can use
/// to fake data before the wrapped screen is shown.
class RituRepos {
  RituRepos(this.profiles, this.periods, this.symptoms, this.dailyLogs);

  final ProfileRepository profiles;
  final PeriodRepository periods;
  final SymptomRepository symptoms;
  final DailyLogRepository dailyLogs;
}

/// Wraps [builder] in an [AppScope] backed by a fresh in-memory [AppDatabase],
/// after running [seed] against it — the same pattern `test/widget_test.dart`
/// uses for widget tests, reused here so screens that read from `AppScope`
/// (e.g. `HomeScreen`, `PeriodStartedScreen`) can be previewed with fake data.
///
/// [AppDatabase.memory] relies on drift's native (FFI) sqlite backend, which
/// isn't available on web, so on web this shows a placeholder instead of
/// crashing. Component-level use-cases (which don't need [SeededAppScope])
/// are unaffected and render normally on web.
class SeededAppScope extends StatefulWidget {
  const SeededAppScope({super.key, required this.seed, required this.builder});

  final Future<void> Function(RituRepos repos) seed;
  final WidgetBuilder builder;

  @override
  State<SeededAppScope> createState() => _SeededAppScopeState();
}

class _SeededAppScopeState extends State<SeededAppScope> {
  RituRepos? _repos;
  AppDatabase? _db;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) _init();
  }

  // Deliberately seeds once in [initState] rather than reacting to prop
  // changes: each use-case in the navigation tree is its own distinct route,
  // so switching use-cases disposes/recreates this widget (and reseeds)
  // naturally. Knobs that should vary the seed belong on a per-use-case
  // `ValueKey` instead of comparing closures, which are never `==`.
  Future<void> _init() async {
    final db = AppDatabase.memory();
    final repos = RituRepos(
      DriftProfileRepository(db),
      DriftPeriodRepository(db),
      DriftSymptomRepository(db),
      DriftDailyLogRepository(db),
    );
    await widget.seed(repos);
    if (!mounted) return;
    setState(() {
      _db = db;
      _repos = repos;
    });
  }

  @override
  void dispose() {
    _db?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const _WebUnsupportedPlaceholder();
    }

    final repos = _repos;
    if (repos == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return AppScope(
      profileRepository: repos.profiles,
      periodRepository: repos.periods,
      symptomRepository: repos.symptoms,
      dailyLogRepository: repos.dailyLogs,
      restartApp: () {},
      child: Builder(builder: widget.builder),
    );
  }
}

class _WebUnsupportedPlaceholder extends StatelessWidget {
  const _WebUnsupportedPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.desktop_mac_outlined, size: 32),
            const SizedBox(height: 12),
            Text(
              'Not available on web',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'This use-case needs an in-memory database, which relies on '
              'native (FFI) sqlite. Run this catalog on macOS, iOS, or '
              'Android to preview it.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Creates a profile that has already completed onboarding — the baseline
/// most screen-level use-cases need, since `AppScope`-backed screens assume
/// a profile already exists.
Future<void> seedOnboardedProfile(
  RituRepos repos, {
  String name = 'Maya',
}) async {
  await repos.profiles.upsertDisplayName(name);
  await repos.profiles.markOnboardingCompleted();
}
