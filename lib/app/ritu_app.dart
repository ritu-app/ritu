import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/app_database.dart';
import '../features/home/home_screen.dart';
import '../features/onboarding/confirmation_screen.dart';
import '../features/onboarding/name_screen.dart';
import '../features/setup/last_period_screen.dart';
import '../features/setup/notification_screen.dart';
import '../features/setup/past_dates_screen.dart';
import '../features/splash/splash_screen.dart';
import '../providers/app_restart_provider.dart';
import '../providers/database_provider.dart';
import '../providers/profile_providers.dart';
import '../providers/repository_providers.dart';
import '../theme/ritu_theme.dart';

class RituApp extends ConsumerWidget {
  const RituApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restartKey = ref.watch(appRestartProvider);

    return MaterialApp(
      key: ValueKey(restartKey),
      title: 'Ritu',
      debugShowCheckedModeBanner: false,
      theme: buildRituTheme(),
      home: const _AppBootstrap(),
    );
  }
}

class _AppBootstrap extends ConsumerWidget {
  const _AppBootstrap();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return profileAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(
          child: Text('Something went wrong: $error'),
        ),
      ),
      data: (profile) {
        if (profile != null && profile.hasCompletedOnboarding) {
          return const HomeScreen();
        }

        return const _OnboardingFlow();
      },
    );
  }
}

class _OnboardingFlow extends ConsumerWidget {
  const _OnboardingFlow();

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  Future<void> _goHome(WidgetRef ref) async {
    await ref.read(profileRepositoryProvider).markOnboardingCompleted();
    ref.invalidate(profileProvider);
    ref.read(appRestartProvider.notifier).state++;
  }

  Widget _pastDates(BuildContext context, WidgetRef ref, String name) {
    return PastDatesScreen(
      onContinue: (dates) async {
        final profiles = ref.read(profileRepositoryProvider);
        final periods = ref.read(periodRepositoryProvider);
        final typical = (await profiles.getProfile())?.typicalPeriodDays;
        await periods.recordPastStarts(
          startedOnDates: dates,
          typicalPeriodDays: typical,
        );
        if (!context.mounted) return;
        _push(context, _notifications(context, ref, name));
      },
      onSkip: () => _push(context, _notifications(context, ref, name)),
    );
  }

  Widget _notifications(BuildContext context, WidgetRef ref, String name) {
    return NotificationScreen(
      onTurnOn: () => _goHome(ref),
      onSkip: () => _goHome(ref),
    );
  }

  Widget _lastPeriod(BuildContext context, WidgetRef ref, String name) {
    return LastPeriodScreen(
      onContinue: (startedOn, duration) async {
        final profiles = ref.read(profileRepositoryProvider);
        final periods = ref.read(periodRepositoryProvider);
        final days = duration.typicalDays;
        await profiles.setTypicalPeriodDays(days);
        await periods.recordLastPeriod(
          startedOn: startedOn,
          typicalPeriodDays: days,
        );
        if (!context.mounted) return;
        _push(context, _pastDates(context, ref, name));
      },
      onSkip: () => _push(context, _pastDates(context, ref, name)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SplashScreen(
      onGetStarted: () {
        _push(
          context,
          NameScreen(
            onContinue: (name) async {
              await ref
                  .read(profileRepositoryProvider)
                  .upsertDisplayName(name);
              if (!context.mounted) return;
              _push(
                context,
                ConfirmationScreen(
                  name: name,
                  onContinue: () {
                    _push(context, _lastPeriod(context, ref, name));
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Root widget for tests and Widgetbook. Wraps [RituApp] in a [ProviderScope],
/// optionally overriding the shared [AppDatabase].
Widget createRituApp({AppDatabase? database}) {
  return ProviderScope(
    overrides: [
      if (database != null) databaseProvider.overrideWithValue(database),
    ],
    child: const RituApp(),
  );
}
