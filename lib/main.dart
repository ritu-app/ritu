import 'package:flutter/material.dart';

import 'features/home/home_screen.dart';
import 'features/onboarding/confirmation_screen.dart';
import 'features/onboarding/name_screen.dart';
import 'features/setup/last_period_screen.dart';
import 'features/setup/notification_screen.dart';
import 'features/setup/past_dates_screen.dart';
import 'features/splash/splash_screen.dart';
import 'theme/ritu_theme.dart';

void main() {
  runApp(const RituApp());
}

class RituApp extends StatelessWidget {
  const RituApp({super.key});

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }

  void _goHome(BuildContext context, String name) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => HomeScreen(name: name),
      ),
      (route) => false,
    );
  }

  Widget _pastDates(BuildContext context, String name) {
    return PastDatesScreen(
      onContinue: () => _push(context, _notifications(context, name)),
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
      onContinue: () => _push(context, _pastDates(context, name)),
      onSkip: () => _push(context, _pastDates(context, name)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ritu',
      debugShowCheckedModeBanner: false,
      theme: buildRituTheme(),
      home: Builder(
        builder: (context) {
          return SplashScreen(
            onGetStarted: () {
              _push(
                context,
                NameScreen(
                  onContinue: (name) {
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
        },
      ),
    );
  }
}
