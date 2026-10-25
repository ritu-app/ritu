import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/date_format.dart';
import '../data/local/app_database.dart';
import '../features/home/home_screen.dart';
import '../features/onboarding/confirmation_screen.dart';
import '../features/onboarding/name_screen.dart';
import '../features/onboarding/restore_backup_screen.dart';
import '../features/onboarding/restore_confirmation_screen.dart';
import '../features/setup/last_period_screen.dart';
import '../features/setup/widgets/period_episode_form_fields.dart';
import '../features/setup/notification_screen.dart';
import '../features/setup/past_dates_screen.dart';
import '../features/splash/splash_screen.dart';
import '../data/models/app_appearance.dart';
import '../providers/app_appearance_provider.dart';
import '../providers/app_restart_provider.dart';
import '../providers/daily_reminder_provider.dart';
import '../providers/database_provider.dart';
import '../providers/profile_providers.dart';
import '../providers/repository_providers.dart';
import '../providers/simulated_today_provider.dart';
import '../services/daily_reminder_notifications.dart';
import '../theme/ritu_palette.dart';
import '../theme/ritu_theme.dart';

class RituApp extends ConsumerWidget {
  const RituApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restartKey = ref.watch(appRestartProvider);
    final appearance =
        ref.watch(appAppearanceProvider).valueOrNull ?? AppAppearance.system;

    return MaterialApp(
      key: ValueKey(restartKey),
      title: 'Ritu',
      debugShowCheckedModeBanner: false,
      theme: buildRituTheme(RituPalette.light),
      darkTheme: buildRituTheme(RituPalette.dark),
      themeMode: themeModeFor(appearance),
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
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) =>
          Scaffold(body: Center(child: Text('Something went wrong: $error'))),
      data: (profile) {
        final restoring = ref.watch(onboardingRestoreLockProvider);
        if (!restoring && profile != null && profile.hasCompletedOnboarding) {
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

  Future<void> _finishRestore(WidgetRef ref) async {
    final profiles = ref.read(profileRepositoryProvider);
    final profile = await profiles.getProfile();
    if (profile != null && !profile.hasCompletedOnboarding) {
      await profiles.markOnboardingCompleted();
    }
    ref.read(onboardingRestoreLockProvider.notifier).state = false;
    ref.invalidate(profileProvider);
    ref.read(appRestartProvider.notifier).state++;
  }

  Widget _nameScreen(BuildContext context, WidgetRef ref) {
    return NameScreen(
      onContinue: (name) async {
        await ref.read(profileRepositoryProvider).upsertDisplayName(name);
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
    );
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
      onTurnOn: () async {
        final granted = await DailyReminderNotifications.requestPermission();
        if (granted) {
          await ref.read(dailyReminderProvider.notifier).enableFromOnboarding();
        } else {
          await ref.read(dailyReminderProvider.notifier).setEnabled(false);
        }
        await _goHome(ref);
      },
      onSkip: () async {
        await ref.read(dailyReminderProvider.notifier).setEnabled(false);
        await _goHome(ref);
      },
    );
  }

  Widget _lastPeriod(BuildContext context, WidgetRef ref, String name) {
    return LastPeriodScreen(
      onContinue: (input) async {
        final profiles = ref.read(profileRepositoryProvider);
        final periods = ref.read(periodRepositoryProvider);
        final typical = typicalPeriodDaysFromEpisodeForm(
          ongoingStatus: input.ongoingStatus,
          endConfidence: input.endConfidence,
          startDate: input.startedOn,
          selectedEndDate: input.endedOn,
          roughDurationBucket: input.roughDurationBucket,
        );
        await profiles.setTypicalPeriodDays(typical);

        switch (input.ongoingStatus) {
          case PeriodOngoingStatus.stillGoing:
            await periods.recordOnboardingLastOpen(startedOn: input.startedOn);
          case PeriodOngoingStatus.ended:
            switch (input.endConfidence) {
              case EndConfidenceChoice.exact:
                await periods.recordOnboardingLastExactEnd(
                  startedOn: input.startedOn,
                  endedOn: input.endedOn!,
                );
              case EndConfidenceChoice.rough:
                await periods.recordOnboardingLastRoughEnd(
                  startedOn: input.startedOn,
                  roughDurationBucket: input.roughDurationBucket!,
                );
              case null:
                break;
            }
        }

        if (!context.mounted) return;
        _push(context, _pastDates(context, ref, name));
      },
      onSkip: () => _push(context, _pastDates(context, ref, name)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SplashScreen(
      onGetStarted: () => _push(context, _nameScreen(context, ref)),
      onRestoreFromBackup: () {
        _push(
          context,
          RestoreBackupScreen(
            pickFile: ref.read(restoreBackupPickerProvider),
            onStartFresh: () => _push(context, _nameScreen(context, ref)),
            onContinue: (file) async {
              ref.read(onboardingRestoreLockProvider.notifier).state = true;
              try {
                await ref
                    .read(rituBackupServiceProvider)
                    .importJson(file.contents);
              } catch (_) {
                ref.read(onboardingRestoreLockProvider.notifier).state = false;
                rethrow;
              }
              if (!context.mounted) return;
              final profile = await ref
                  .read(profileRepositoryProvider)
                  .getProfile();
              if (!context.mounted) return;
              _push(
                context,
                RestoreConfirmationScreen(
                  name: profile?.displayName ?? '',
                  onContinue: () => _finishRestore(ref),
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
/// optionally overriding the shared [AppDatabase] and simulated today.
Widget createRituApp({
  AppDatabase? database,
  DateTime? simulatedToday,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: [
      if (database != null) databaseProvider.overrideWithValue(database),
      if (simulatedToday != null)
        simulatedTodayProvider.overrideWithValue(dateOnly(simulatedToday)),
      ...overrides,
    ],
    child: const RituApp(),
  );
}
