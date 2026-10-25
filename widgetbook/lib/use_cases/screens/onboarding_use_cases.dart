import 'package:flutter/material.dart';
import 'package:ritu/data/backup/restore_backup_file.dart';
import 'package:ritu/features/onboarding/confirmation_screen.dart';
import 'package:ritu/features/onboarding/name_screen.dart';
import 'package:ritu/features/onboarding/restore_backup_screen.dart';
import 'package:ritu/features/onboarding/restore_confirmation_screen.dart';
import 'package:ritu/features/setup/last_period_screen.dart';
import 'package:ritu/features/setup/notification_screen.dart';
import 'package:ritu/features/setup/past_dates_screen.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// These onboarding screens take plain callbacks rather than reading from
// Onboarding screens don't touch repositories until later steps, so —
// unlike the Home/Settings use-cases — they don't need
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
  name: 'Empty',
  type: RestoreBackupScreen,
  path: '[Screens]/Onboarding',
)
Widget restoreBackupEmptyUseCase(BuildContext context) {
  return RestoreBackupScreen(
    pickFile: () async => null,
    onContinue: (_) async {},
    onStartFresh: () {},
  );
}

@widgetbook.UseCase(
  name: 'Import failed',
  type: RestoreBackupScreen,
  path: '[Screens]/Onboarding',
)
Widget restoreBackupFailedUseCase(BuildContext context) {
  return RestoreBackupScreen(
    initiallyInvalid: true,
    pickFile: () async => null,
    onStartFresh: () {},
  );
}

@widgetbook.UseCase(
  name: 'File selected',
  type: RestoreBackupScreen,
  path: '[Screens]/Onboarding',
)
Widget restoreBackupSelectedUseCase(BuildContext context) {
  final name = context.knobs.string(
    label: 'File name',
    initialValue: 'ritu_export_2026.json',
  );
  return RestoreBackupScreen(
    initialFile: RestoreBackupFile(
      name: name,
      sizeBytes: 184 * 1024,
      contents: '',
    ),
    pickFile: () async => null,
    onContinue: (_) async {},
    onStartFresh: () {},
  );
}

@widgetbook.UseCase(
  name: 'Default',
  type: RestoreConfirmationScreen,
  path: '[Screens]/Onboarding',
)
Widget restoreConfirmationUseCase(BuildContext context) {
  final name = context.knobs.string(label: 'Name', initialValue: 'Maya');
  return RestoreConfirmationScreen(name: name, onContinue: () {});
}

@widgetbook.UseCase(
  name: 'Default',
  type: LastPeriodScreen,
  path: '[Screens]/Onboarding',
)
Widget lastPeriodScreenUseCase(BuildContext context) {
  return LastPeriodScreen(onContinue: (_) {}, onSkip: () {});
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
  return NotificationScreen(
    onTurnOn: () async {},
    onSkip: () async {},
  );
}
