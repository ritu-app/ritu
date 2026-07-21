import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:luna_app/main.dart';

void main() {
  testWidgets('Splash screen shows Luna branding and CTA', (tester) async {
    await tester.pumpWidget(const LunaApp());
    await tester.pump();

    expect(find.text('Luna'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
  });

  testWidgets('Onboarding reaches setup screens', (tester) async {
    await tester.pumpWidget(const LunaApp());
    await tester.pump();

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Maya');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Hi, Maya 👋'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('What did your last period start?'), findsOneWidget);
    expect(find.text('This look right'), findsOneWidget);
    await tester.tap(find.text('This look right'));
    await tester.pumpAndSettle();

    expect(find.text('Do you have past period dates?'), findsOneWidget);
    expect(find.text('Add a date'), findsOneWidget);

    final continueButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Continue'),
    );
    expect(continueButton.onPressed, isNull);

    await tester.tap(find.text('Skip – I’ll build from today'));
    await tester.pumpAndSettle();

    expect(find.text('A gentle nudge each morning'), findsOneWidget);
    expect(find.text('Turn on reminders'), findsOneWidget);
    expect(find.text('Skip for now'), findsOneWidget);
  });
}
