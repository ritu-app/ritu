import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/home_greeting.dart';
import '../services/home_greeting_prefs.dart';
import 'daily_log_providers.dart';
import 'repository_providers.dart';
import 'simulated_clock_provider.dart';
import 'simulated_today_provider.dart';

/// Optional overrides for Widgetbook / tests — production leaves this null.
class HomeGreetingOverrides {
  const HomeGreetingOverrides({
    this.clock,
    this.isFirstOpenToday,
    this.isFirstHomeVisit,
    this.daysSinceLastOpen,
    this.skipSessionCommit = false,
  });

  final DateTime? clock;
  final bool? isFirstOpenToday;
  final bool? isFirstHomeVisit;
  final int? daysSinceLastOpen;
  final bool skipSessionCommit;
}

final homeGreetingOverridesProvider =
    Provider<HomeGreetingOverrides?>((ref) => null);

final homeGreetingProvider = FutureProvider<HomeGreeting>((ref) async {
  final overrides = ref.watch(homeGreetingOverridesProvider);
  final DateTime clock =
      overrides?.clock ?? ref.watch(simulatedClockProvider);
  final today = ref.watch(simulatedTodayProvider);
  final todayLog = ref.watch(todayLogProvider).valueOrNull;
  final streak = ref.watch(currentStreakProvider).valueOrNull ?? 0;
  final totalLogged = ref.watch(totalLoggedDaysProvider).valueOrNull ?? 0;

  final session = await HomeGreetingSession.load(today);

  final loggedYesterday = await ref
      .read(dailyLogRepositoryProvider)
      .hasLoggedOn(today.subtract(const Duration(days: 1)));

  final greeting = resolveHomeGreeting(
    HomeGreetingContext(
      clock: clock,
      today: today,
      loggedToday: todayLog != null,
      streak: streak,
      totalLoggedDays: totalLogged,
      loggedYesterday: loggedYesterday,
      isFirstOpenToday:
          overrides?.isFirstOpenToday ?? session.isFirstOpenToday,
      isFirstHomeVisit:
          overrides?.isFirstHomeVisit ?? session.isFirstHomeVisit,
      daysSinceLastOpen:
          overrides?.daysSinceLastOpen ?? session.daysSinceLastOpen,
    ),
  );

  if (overrides?.skipSessionCommit != true) {
    await session.commit();
  }

  return greeting;
});
