import 'package:flutter/material.dart';

import 'features/onboarding/confirmation_screen.dart';
import 'features/onboarding/name_screen.dart';
import 'features/setup/last_period_screen.dart';
import 'features/setup/notification_screen.dart';
import 'features/setup/past_dates_screen.dart';
import 'features/splash/splash_screen.dart';
import 'theme/luna_theme.dart';

void main() {
  runApp(const LunaApp());
}

class LunaApp extends StatelessWidget {
  const LunaApp({super.key});

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Luna',
      debugShowCheckedModeBanner: false,
      theme: buildLunaTheme(),
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
                          _push(
                            context,
                            LastPeriodScreen(
                              onContinue: () {
                                _push(
                                  context,
                                  PastDatesScreen(
                                    onContinue: () {
                                      _push(
                                        context,
                                        const NotificationScreen(),
                                      );
                                    },
                                    onSkip: () {
                                      _push(
                                        context,
                                        const NotificationScreen(),
                                      );
                                    },
                                  ),
                                );
                              },
                              onSkip: () {
                                _push(
                                  context,
                                  PastDatesScreen(
                                    onContinue: () {
                                      _push(
                                        context,
                                        const NotificationScreen(),
                                      );
                                    },
                                    onSkip: () {
                                      _push(
                                        context,
                                        const NotificationScreen(),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          );
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
