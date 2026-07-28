import 'package:flutter/material.dart';
import 'package:ritu/features/onboarding/confirmation_screen.dart';
import 'package:ritu/features/onboarding/name_screen.dart';
import 'package:ritu/features/setup/last_period_screen.dart';
import 'package:ritu/features/setup/notification_screen.dart';
import 'package:ritu/features/setup/past_dates_screen.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// These onboarding screens take plain callbacks rather than reading from
// Onboarding screens don't read repositories via `context.profiles` until
// later steps, so — unlike the Home/Settings use-cases — they don't need
// `SeededAppScope`/an in-memory database.

@widgetbook.UseCase(
  name: 'Default',
  type: NameScreen,
  path: '[Screens]/Onboarding',
)
Widget nameScreenUseCase(BuildContext context) {
  return NameScreen(onContinue: (name) {});
}

@widgetbook.UseCase(
  name: 'Default',
  type: ConfirmationScreen,
  path: '[Screens]/Onboarding',
)
Widget confirmationScreenUseCase(BuildContext context) {
  final name = context.knobs.string(label: 'Name', initialValue: 'Maya');
  return ConfirmationScreen(name: name, onContinue: () {});
}

@widgetbook.UseCase(
  name: 'Default',
  type: LastPeriodScreen,
  path: '[Screens]/Onboarding',
)
Widget lastPeriodScreenUseCase(BuildContext context) {
  return LastPeriodScreen(onContinue: (startedOn, duration) {}, onSkip: () {});
}

@widgetbook.UseCase(
  name: 'Default',
  type: PastDatesScreen,
  path: '[Screens]/Onboarding',
)
Widget pastDatesScreenUseCase(BuildContext context) {
  return PastDatesScreen(onContinue: (dates) {}, onSkip: () {});
}

@widgetbook.UseCase(
  name: 'Default',
  type: NotificationScreen,
  path: '[Screens]/Onboarding',
)
Widget notificationScreenUseCase(BuildContext context) {
  return NotificationScreen(onTurnOn: () {}, onSkip: () {});
}
