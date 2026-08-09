import 'package:ritu/core/date_format.dart';
import 'package:ritu/core/home_greeting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('greetingTimeWindowFor', () {
    test('morning is 5:00–10:59', () {
      final day = DateTime(2026, 3, 1);
      expect(
        greetingTimeWindowFor(DateTime(day.year, day.month, day.day, 5)),
        GreetingTimeWindow.morning,
      );
      expect(
        greetingTimeWindowFor(DateTime(day.year, day.month, day.day, 10)),
        GreetingTimeWindow.morning,
      );
    });

    test('afternoon is 11:00–15:59', () {
      final day = DateTime(2026, 3, 1);
      expect(
        greetingTimeWindowFor(DateTime(day.year, day.month, day.day, 11)),
        GreetingTimeWindow.afternoon,
      );
      expect(
        greetingTimeWindowFor(DateTime(day.year, day.month, day.day, 15)),
        GreetingTimeWindow.afternoon,
      );
    });

    test('evening is 16:00–19:59', () {
      final day = DateTime(2026, 3, 1);
      expect(
        greetingTimeWindowFor(DateTime(day.year, day.month, day.day, 16)),
        GreetingTimeWindow.evening,
      );
    });

    test('night wraps late evening and early morning', () {
      final day = DateTime(2026, 3, 1);
      expect(
        greetingTimeWindowFor(DateTime(day.year, day.month, day.day, 20)),
        GreetingTimeWindow.night,
      );
      expect(
        greetingTimeWindowFor(DateTime(day.year, day.month, day.day, 4)),
        GreetingTimeWindow.night,
      );
    });
  });

  group('resolveHomeGreeting', () {
    final today = dateOnly(DateTime(2026, 8, 9));
    final morning = DateTime(2026, 8, 9, 8);

    HomeGreetingContext base({
      bool loggedToday = false,
      int streak = 0,
      bool isFirstOpenToday = false,
      bool isFirstHomeVisit = false,
      int daysSinceLastOpen = 0,
    }) {
      return HomeGreetingContext(
        clock: morning,
        today: today,
        loggedToday: loggedToday,
        streak: streak,
        totalLoggedDays: 5,
        loggedYesterday: true,
        isFirstOpenToday: isFirstOpenToday,
        isFirstHomeVisit: isFirstHomeVisit,
        daysSinceLastOpen: daysSinceLastOpen,
      );
    }

    test('first home visit shows welcome with name', () {
      final greeting = resolveHomeGreeting(
        base(isFirstOpenToday: true, isFirstHomeVisit: true),
      );
      expect(greeting.line1, 'Welcome,');
      expect(greeting.showsName, isTrue);
    });

    test('streak milestone on first open beats time pool', () {
      final greeting = resolveHomeGreeting(
        base(isFirstOpenToday: true, streak: 7),
      );
      expect(greeting.line1, 'Your consistency is growing');
      expect(greeting.showsName, isTrue);
    });

    test('absence greeting for 4–7 days away', () {
      final greeting = resolveHomeGreeting(
        base(isFirstOpenToday: true, daysSinceLastOpen: 5),
      );
      expect(greeting.line1, 'Glad to see you again,');
      expect(greeting.showsName, isTrue);
    });

    test('logged today uses after-logged pool', () {
      final greeting = resolveHomeGreeting(base(loggedToday: true));
      expect(greeting.line1, isNot('Welcome,'));
      expect(greeting.showsName, isFalse);
      expect(greeting.line2, isNotEmpty);
    });

    test('not logged uses before-logged pool', () {
      final greeting = resolveHomeGreeting(base());
      expect(greeting.showsName, isFalse);
      expect(greeting.line1, 'The day is yours');
      expect(greeting.line2, "Check in when you're ready");
    });
  });
}
