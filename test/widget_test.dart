import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ritu/main.dart';

void main() {
  testWidgets('Splash screen shows Ritu branding and CTA', (tester) async {
    await tester.pumpWidget(const RituApp());
    await tester.pump();

    expect(find.text('Ritu'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
  });

  testWidgets('Onboarding completes into homepage', (tester) async {
    await tester.pumpWidget(const RituApp());
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

    await tester.tap(find.text('This look right'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip – I’ll build from today'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip for now'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome,'), findsOneWidget);
    expect(find.text('Maya ✨'), findsOneWidget);
    expect(find.text('days since last period'), findsOneWidget);
    expect(find.text('How are you feeling today?'), findsOneWidget);
    expect(find.text('Log today'), findsOneWidget);
    expect(find.text('Home'), findsWidgets);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Maya'), findsOneWidget);
    expect(find.text('Cycle & Tracking'), findsOneWidget);
    expect(find.text('Daily Reminder'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Cycle calendar'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Cycle calendar'), findsOneWidget);

    await tester.tap(find.text('Insights'));
    await tester.pumpAndSettle();

    expect(find.text('Understand your patterns'), findsOneWidget);
    expect(find.text('Your journey is just beginning'), findsOneWidget);
    expect(find.text('What you’ll unlock'), findsOneWidget);
    expect(find.text('Energy trends'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Cycle insights'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Cycle insights'), findsOneWidget);

    await tester.tap(find.text('Journal'));
    await tester.pumpAndSettle();

    expect(find.text('Your space to reflect'), findsOneWidget);
    expect(find.text('A space for you, just as you are'), findsOneWidget);
    expect(find.text('Today’s reflection'), findsOneWidget);
    expect(find.text('Save entry'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Build self awareness'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Journal helps you'), findsOneWidget);

    await tester.tap(find.text('Reports'));
    await tester.pumpAndSettle();

    expect(find.text('Export your health data'), findsOneWidget);
    expect(find.text('Your first report is on the way'), findsOneWidget);
    expect(find.text('Why Reports Are Valuable'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Keep everything in one place'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Generate professional reports'), findsOneWidget);
  });
}
