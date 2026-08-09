/// Home header greeting copy and resolution — see [docs/home-greeting-spec.md].
library;

import 'date_format.dart';

/// Local-time window for greeting pools.
enum GreetingTimeWindow {
  morning,
  afternoon,
  evening,
  night,
}

/// Resolved two-line home header copy.
class HomeGreeting {
  const HomeGreeting({
    required this.line1,
    required this.line2,
    this.showsName = false,
  });

  final String line1;

  /// Primary line — either `{name} ✨` or a subtitle string.
  final String line2;
  final bool showsName;

  HomeGreeting withName(String name) {
    if (!showsName) return this;
    return HomeGreeting(line1: line1, line2: name, showsName: true);
  }
}

typedef _GreetingPair = ({String line1, String line2});

const _streakMilestones = [3, 7, 14, 30, 100];

const _beforeLoggedMorning = <_GreetingPair>[
  (line1: 'New day', line2: 'A few seconds to check in?'),
  (line1: 'Good morning', line2: 'How are you feeling today?'),
  (line1: 'A gentle start', line2: 'A good time to log today'),
  (line1: 'The day is yours', line2: "Check in when you're ready"),
  (line1: 'Day is starting', line2: 'A few seconds is all it takes'),
  (line1: 'Ready for today?', line2: 'Take a moment to check in'),
  (line1: "Let's begin", line2: 'Thirty seconds for yourself'),
  (line1: 'Enjoy your day', line2: 'Thirty seconds for today'),
  (line1: 'A quiet start', line2: "Log when you're ready"),
  (line1: 'Enjoy your day', line2: 'A moment before it begins'),
  (line1: 'Fresh start', line2: 'A good time to log'),
  (line1: 'A quiet start', line2: "Today's log is still open"),
];

const _beforeLoggedAfternoon = <_GreetingPair>[
  (line1: "Day's halfway done", line2: 'Still time to log today'),
  (line1: 'Midday pause', line2: "Today's log is waiting"),
  (line1: 'Still going', line2: 'Log before it slips by'),
  (line1: 'Afternoon already', line2: "How's your day unfolding?"),
  (line1: 'Day keeps moving', line2: 'Worth taking thirty seconds'),
  (line1: 'Not too late', line2: 'A quick log goes a long way'),
  (line1: 'Still here', line2: 'Take a moment to check in'),
  (line1: 'Halfway through', line2: 'Log while you remember'),
  (line1: 'Afternoon light', line2: "Today's check-in is waiting"),
  (line1: 'Day moves on', line2: 'Take today at your pace'),
  (line1: 'Before it passes', line2: 'Keep your rhythm going'),
  (line1: 'Stay in rhythm', line2: 'Take a mindful pause'),
];

const _beforeLoggedEvening = <_GreetingPair>[
  (line1: 'Day winding down', line2: 'Log before it closes'),
  (line1: 'Evening is here', line2: 'Reflect on your journey'),
  (line1: 'Almost done', line2: 'Still time to check in'),
  (line1: 'Day behind you', line2: "Log while it's fresh"),
  (line1: 'Getting quieter', line2: 'A good time to check in'),
  (line1: 'Nearly there', line2: 'A moment to reflect'),
  (line1: 'Before you settle', line2: 'Log before today passes'),
  (line1: 'Evening settling in', line2: 'Check in before you rest'),
  (line1: 'Almost at end', line2: 'One small thing left'),
  (line1: "Day's end close", line2: 'How has your day been?'),
  (line1: 'Day slowing down', line2: 'Log before it passes'),
  (line1: 'Good evening', line2: 'A good time to check in'),
];

const _beforeLoggedNight = <_GreetingPair>[
  (line1: 'Still up', line2: 'Log before the day ends'),
  (line1: 'Late night', line2: "Today's log is still waiting"),
  (line1: 'Day almost over', line2: 'Log before it closes'),
  (line1: 'Night is quiet', line2: "How's your day unfolding?"),
  (line1: 'Before you rest', line2: 'One last thing today'),
  (line1: 'Getting late', line2: 'Still time to check in'),
  (line1: 'World is still', line2: 'Take a moment to check in'),
  (line1: 'Late but here', line2: 'How did today feel?'),
  (line1: 'Quiet night', line2: 'Log before the day ends'),
  (line1: 'Night settling in', line2: 'A moment before you sleep'),
  (line1: 'Time to recharge', line2: 'Check in before you rest'),
  (line1: 'A quiet moment', line2: 'Take a moment to log'),
];

const _afterLoggedMorning = <_GreetingPair>[
  (line1: 'Already logged', line2: 'The day is ahead of you'),
  (line1: 'Morning log done', line2: 'Go make the most of today'),
  (line1: 'Checked in early', line2: "You're all set"),
  (line1: 'Today sorted', line2: 'Well done'),
  (line1: 'Log is in', line2: 'A good way to start'),
  (line1: 'All logged', line2: 'Your consistency is growing'),
  (line1: 'Checked in', line2: 'Great start today!'),
  (line1: 'Logged and done', line2: 'Go enjoy the morning'),
  (line1: 'Morning log done', line2: 'A beautiful start today'),
  (line1: 'Done for today', line2: 'Enjoy your day'),
  (line1: "Today's log is in", line2: 'A good way to start'),
  (line1: 'First thing done', line2: 'The day belongs to you'),
];

const _afterLoggedAfternoon = <_GreetingPair>[
  (line1: 'All logged', line2: 'The afternoon is yours'),
  (line1: 'Today done', line2: 'One less thing on the list'),
  (line1: 'Checked in', line2: 'Enjoy the rest of the day'),
  (line1: 'Today sorted', line2: 'Nothing left to do here'),
  (line1: 'Log complete', line2: 'One small thing done well'),
  (line1: 'All done', line2: 'Go make the most of today'),
  (line1: 'Logged today', line2: 'Ritu is building patterns'),
  (line1: 'Done for today', line2: 'Rest of the day is yours'),
  (line1: 'Today is done', line2: 'Afternoon belongs to you'),
  (line1: 'Logged for today', line2: "How's your afternoon going?"),
  (line1: 'Logged and done', line2: 'Looking good today'),
  (line1: 'All done for today', line2: 'Enjoy the afternoon'),
];

const _afterLoggedEvening = <_GreetingPair>[
  (line1: 'Already logged', line2: 'Enjoy the evening'),
  (line1: 'Today done', line2: 'Ritu is keeping track'),
  (line1: 'Checked in early', line2: 'Settle in for the evening'),
  (line1: 'Today sorted', line2: "Everything's up to date"),
  (line1: 'Log is in', line2: 'Evening is yours to keep'),
  (line1: 'All logged', line2: 'Let the evening be easy'),
  (line1: 'Checked in', line2: 'Soft end to the day'),
  (line1: 'Logged and done', line2: 'Day is closing well'),
  (line1: 'Morning log done', line2: 'A warm evening to you'),
  (line1: 'Done for today', line2: 'A quiet and kind evening'),
  (line1: "Today's log is in", line2: 'Take care of yourself'),
  (line1: 'All done', line2: 'Day has been well spent'),
];

const _afterLoggedNight = <_GreetingPair>[
  (line1: 'All logged', line2: 'Rest well tonight'),
  (line1: 'Today done', line2: 'The day is complete'),
  (line1: 'Checked in', line2: 'Sleep well'),
  (line1: 'Today sorted', line2: 'Nothing left but rest'),
  (line1: 'Log complete', line2: 'See you tomorrow'),
  (line1: 'All done', line2: 'A good day ends here'),
  (line1: 'Logged today', line2: 'Close the day gently'),
  (line1: 'Done for today', line2: 'Quiet night ahead'),
  (line1: 'Today is done', line2: 'Let it all settle now'),
  (line1: 'Logged for today', line2: 'Put today down gently'),
  (line1: 'Logged and done', line2: 'Rest and restore'),
  (line1: 'All done for today', line2: 'Rest well'),
];

const _beforeLoggedPools = {
  GreetingTimeWindow.morning: _beforeLoggedMorning,
  GreetingTimeWindow.afternoon: _beforeLoggedAfternoon,
  GreetingTimeWindow.evening: _beforeLoggedEvening,
  GreetingTimeWindow.night: _beforeLoggedNight,
};

const _afterLoggedPools = {
  GreetingTimeWindow.morning: _afterLoggedMorning,
  GreetingTimeWindow.afternoon: _afterLoggedAfternoon,
  GreetingTimeWindow.evening: _afterLoggedEvening,
  GreetingTimeWindow.night: _afterLoggedNight,
};

/// Maps a local [DateTime] to a [GreetingTimeWindow].
GreetingTimeWindow greetingTimeWindowFor(DateTime clock) {
  final hour = clock.hour;
  if (hour >= 5 && hour <= 10) return GreetingTimeWindow.morning;
  if (hour >= 11 && hour <= 15) return GreetingTimeWindow.afternoon;
  if (hour >= 16 && hour <= 19) return GreetingTimeWindow.evening;
  return GreetingTimeWindow.night;
}

/// Sample clock for [window] — noon-ish per window for previews.
DateTime sampleClockForWindow(GreetingTimeWindow window, DateTime onDay) {
  final day = dateOnly(onDay);
  final hour = switch (window) {
    GreetingTimeWindow.morning => 8,
    GreetingTimeWindow.afternoon => 13,
    GreetingTimeWindow.evening => 18,
    GreetingTimeWindow.night => 22,
  };
  return DateTime(day.year, day.month, day.day, hour);
}

int _poolIndex(DateTime day) {
  // Day-of-year is 1-based; use 0-based index into 12-item pools.
  return (day.difference(DateTime(day.year)).inDays) % 12;
}

HomeGreeting _fromPool(List<_GreetingPair> pool, DateTime day) {
  final pair = pool[_poolIndex(day)];
  return HomeGreeting(line1: pair.line1, line2: pair.line2);
}

HomeGreeting? _streakMilestoneGreeting(int streak) {
  if (!_streakMilestones.contains(streak)) return null;
  final line1 = switch (streak) {
    3 => 'Building a great habit',
    7 => 'Your consistency is growing',
    14 => "You're in a great rhythm",
    30 => 'Amazing dedication',
    100 => 'What an incredible journey',
    _ => '',
  };
  return HomeGreeting(line1: line1, line2: '', showsName: true);
}

HomeGreeting? _absenceGreeting(int daysAway, DateTime today) {
  if (daysAway < 2) return null;
  if (daysAway <= 3) {
    final pickAlt = _poolIndex(today).isOdd;
    return HomeGreeting(
      line1: pickAlt
          ? "Let's pick up where you left off"
          : 'Ready when you are',
      line2: '',
      showsName: true,
    );
  }
  if (daysAway <= 7) {
    return const HomeGreeting(
      line1: 'Glad to see you again,',
      line2: '',
      showsName: true,
    );
  }
  return const HomeGreeting(
    line1: 'Welcome back',
    line2: '',
    showsName: true,
  );
}

/// Inputs for [resolveHomeGreeting].
class HomeGreetingContext {
  const HomeGreetingContext({
    required this.clock,
    required this.today,
    required this.loggedToday,
    required this.streak,
    required this.totalLoggedDays,
    required this.loggedYesterday,
    required this.isFirstOpenToday,
    required this.isFirstHomeVisit,
    required this.daysSinceLastOpen,
  });

  final DateTime clock;
  final DateTime today;
  final bool loggedToday;
  final int streak;
  final int totalLoggedDays;
  final bool loggedYesterday;
  final bool isFirstOpenToday;
  final bool isFirstHomeVisit;

  /// Calendar days between the previous home session and [today].
  final int daysSinceLastOpen;
}

/// Resolves the home header greeting — see [docs/home-greeting-spec.md].
HomeGreeting resolveHomeGreeting(HomeGreetingContext context) {
  final window = greetingTimeWindowFor(context.clock);

  if (context.loggedToday) {
    return _fromPool(_afterLoggedPools[window]!, context.today);
  }

  if (context.isFirstOpenToday) {
    if (context.isFirstHomeVisit) {
      return const HomeGreeting(
        line1: 'Welcome,',
        line2: '',
        showsName: true,
      );
    }

    final milestone = _streakMilestoneGreeting(context.streak);
    if (milestone != null) return milestone;

    final absence = _absenceGreeting(context.daysSinceLastOpen, context.today);
    if (absence != null) return absence;
  }

  // Streak broken → fall through to before-logged pool (no dedicated copy).
  return _fromPool(_beforeLoggedPools[window]!, context.today);
}

/// Whether yesterday's missing log should be treated as a broken streak.
bool isStreakBroken({
  required bool loggedYesterday,
  required int totalLoggedDays,
}) {
  return !loggedYesterday && totalLoggedDays > 0;
}
