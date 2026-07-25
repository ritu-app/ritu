import 'package:flutter/material.dart';

import '../data/local/app_database.dart';
import '../data/repositories/period_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/symptom_repository.dart';
import '../features/home/home_screen.dart';
import '../features/onboarding/confirmation_screen.dart';
import '../features/onboarding/name_screen.dart';
import '../features/setup/last_period_screen.dart';
import '../features/setup/notification_screen.dart';
import '../features/setup/past_dates_screen.dart';
import '../features/splash/splash_screen.dart';
import '../theme/ritu_theme.dart';
import 'app_scope.dart';

class RituApp extends StatefulWidget {
  const RituApp({
    super.key,
    required this.profileRepository,
    required this.periodRepository,
    required this.symptomRepository,
  });

  final ProfileRepository profileRepository;
  final PeriodRepository periodRepository;
  final SymptomRepository symptomRepository;

  @override
  State<RituApp> createState() => _RituAppState();
}

class _RituAppState extends State<RituApp> {
  Key _bootstrapKey = UniqueKey();

  void _restartApp() {
    setState(() => _bootstrapKey = UniqueKey());
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      profileRepository: widget.profileRepository,
      periodRepository: widget.periodRepository,
      symptomRepository: widget.symptomRepository,
      restartApp: _restartApp,
      child: MaterialApp(
        key: _bootstrapKey,
        title: 'Ritu',
        debugShowCheckedModeBanner: false,
        theme: buildRituTheme(),
        home: _AppBootstrap(
          profileRepository: widget.profileRepository,
        ),
      ),
    );
  }
}

class _AppBootstrap extends StatefulWidget {
  const _AppBootstrap({
    required this.profileRepository,
  });

  final ProfileRepository profileRepository;

  @override
  State<_AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<_AppBootstrap> {
  late final Future<Profile?> _profileFuture =
      widget.profileRepository.getProfile();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Profile?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final profile = snapshot.data;
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
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }

  Future<void> _goHome(BuildContext context, String name) async {
    final profile =
        await AppScope.profiles(context).markOnboardingCompleted();
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
        final profiles = AppScope.profiles(context);
        final periods = AppScope.periods(context);
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
        final profiles = AppScope.profiles(context);
        final periods = AppScope.periods(context);
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
              await AppScope.profiles(context).upsertDisplayName(name);
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

/// Builds the app with a fresh or injected database.
RituApp createRituApp({AppDatabase? database}) {
  final db = database ?? AppDatabase();
  return RituApp(
    profileRepository: ProfileRepository(db),
    periodRepository: PeriodRepository(db),
    symptomRepository: SymptomRepository(db),
  );
}
