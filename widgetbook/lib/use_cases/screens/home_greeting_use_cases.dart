import 'package:flutter/material.dart';
import 'package:ritu/core/home_greeting.dart';
import 'package:ritu/features/home/home_greeting_header.dart';
import 'package:ritu/theme/ritu_colors.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Greeting',
  type: HomeGreetingHeader,
  path: '[Screens]/Home',
)
Widget homeGreetingUseCase(BuildContext context) {
  final window = context.knobs.object.dropdown<GreetingTimeWindow>(
    label: 'Time of day',
    options: const [
      GreetingTimeWindow.morning,
      GreetingTimeWindow.afternoon,
      GreetingTimeWindow.evening,
      GreetingTimeWindow.night,
    ],
    labelBuilder: (value) => switch (value) {
      GreetingTimeWindow.morning => 'Morning (5–10)',
      GreetingTimeWindow.afternoon => 'Afternoon (11–15)',
      GreetingTimeWindow.evening => 'Evening (16–19)',
      GreetingTimeWindow.night => 'Night (20–4)',
    },
    initialOption: GreetingTimeWindow.morning,
  );

  final loggedToday = context.knobs.boolean(
    label: 'Logged today',
    initialValue: false,
  );

  final streak = context.knobs.int.slider(
    label: 'Streak',
    initialValue: 0,
    min: 0,
    max: 100,
  );

  final firstOpenToday = context.knobs.boolean(
    label: 'First open today',
    initialValue: true,
  );

  final firstHomeVisit = context.knobs.boolean(
    label: 'First home visit',
    initialValue: false,
  );

  final daysAway = context.knobs.int.slider(
    label: 'Days since last open',
    initialValue: 0,
    min: 0,
    max: 14,
  );

  final name = context.knobs.string(label: 'Name', initialValue: 'Maya');

  final today = DateTime.now();
  final clock = sampleClockForWindow(window, today);
  final greeting = resolveHomeGreeting(
    HomeGreetingContext(
      clock: clock,
      today: DateTime(today.year, today.month, today.day),
      loggedToday: loggedToday,
      streak: streak,
      totalLoggedDays: loggedToday || streak > 0 ? 10 : 0,
      loggedYesterday: streak > 0,
      isFirstOpenToday: firstOpenToday,
      isFirstHomeVisit: firstHomeVisit,
      daysSinceLastOpen: daysAway,
    ),
  );

  return Scaffold(
    backgroundColor: RituColors.backgroundPage,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: HomeGreetingHeader(
          greeting: greeting,
          name: name,
          streak: streak,
          onSettingsTap: () {},
        ),
      ),
    ),
  );
}
