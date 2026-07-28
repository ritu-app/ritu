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
import '../providers/profile_providers.dart';
import '../providers/repository_access.dart';
import '../theme/ritu_theme.dart';
import '../providers/database_provider.dart';

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
          return HomeScreen(
            name: profile.displayName,
            loggingSince: profile.onboardingCompletedAt!,
          );
        }

        return const _OnboardingFlow();
      },
    );
  }
}

class _OnboardingFlow extends StatelessWidget {
  const _OnboardingFlow();

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  Future<void> _goHome(BuildContext context, String name) async {
    final profile = await context.profiles.markOnboardingCompleted();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => HomeScreen(
          name: name,
          loggingSince: profile.onboardingCompletedAt!,
        ),
      ),
      (route) => false,
    );
  }

  Widget _pastDates(BuildContext context, String name) {
    return PastDatesScreen(
      onContinue: (dates) async {
        final profiles = context.profiles;
        final periods = context.periods;
        final typical = (await profiles.getProfile())?.typicalPeriodDays;
        await periods.recordPastStarts(
          startedOnDates: dates,
          typicalPeriodDays: typical,
        );
        if (!context.mounted) return;
        _push(context, _notifications(context, name));
      },
      onSkip: () => _push(context, _notifications(context, name)),
    );
  }

  Widget _notifications(BuildContext context, String name) {
    return NotificationScreen(
      onTurnOn: () => _goHome(context, name),
      onSkip: () => _goHome(context, name),
    );
  }

  Widget _lastPeriod(BuildContext context, String name) {
    return LastPeriodScreen(
      onContinue: (startedOn, duration) async {
        final profiles = context.profiles;
        final periods = context.periods;
        final days = duration.typicalDays;
        await profiles.setTypicalPeriodDays(days);
        await periods.recordLastPeriod(
          startedOn: startedOn,
          typicalPeriodDays: days,
        );
        if (!context.mounted) return;
        _push(context, _pastDates(context, name));
      },
      onSkip: () => _push(context, _pastDates(context, name)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      onGetStarted: () {
        _push(
          context,
          NameScreen(
            onContinue: (name) async {
              await context.profiles.upsertDisplayName(name);
              if (!context.mounted) return;
              _push(
                context,
                ConfirmationScreen(
                  name: name,
                  onContinue: () {
                    _push(context, _lastPeriod(context, name));
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
