import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/cycle/cycle.dart';
import '../../core/home_greeting.dart';
import '../../core/date_format.dart';
import '../../data/repositories/daily_log_repository.dart';
import '../../providers/cycle_snapshot_provider.dart';
import '../../providers/daily_log_providers.dart';
import '../../providers/home_greeting_provider.dart';
import '../../providers/period_providers.dart';
import '../../providers/profile_providers.dart';
import 'home_greeting_header.dart';
import '../../services/daily_log_notification_navigation.dart';
import '../../theme/ritu_colors.dart';
import '../insights/insights_screen.dart';
import '../journal/journal_screen.dart';
import '../log/daily_log_flow.dart';
import '../settings/settings_screen.dart';
import '../setup/widgets/ritu_calendar.dart';
import '../summary/summary_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, this.patternDaysRequired = 14});

  final int patternDaysRequired;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _tabIndex = 0;
  var _bannerDismissed = false;
  var _hideBottomNav = false;
  var _logFlowOpen = false;
  String? _selectedMood;
  late DateTime _calendarMonth;
  StreamSubscription<void>? _notificationLaunchSub;

  static const _moods = [
    ('😊', 'Radiant'),
    ('😌', 'Calm'),
    ('😐', 'Neutral'),
    ('😒', 'Tired'),
    ('😣', 'Stressed'),
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _calendarMonth = DateTime(now.year, now.month);
    _notificationLaunchSub =
        DailyLogNotificationNavigation.requests.listen((_) {
      _openDailyLogFromNotification();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openDailyLogFromNotification();
    });
  }

  @override
  void dispose() {
    _notificationLaunchSub?.cancel();
    super.dispose();
  }

  void _openDailyLogFromNotification() {
    if (!DailyLogNotificationNavigation.takePending()) return;
    unawaited(_openDailyLog());
  }

  Future<void> _openDailyLog() async {
    if (_logFlowOpen || !mounted) return;
    _logFlowOpen = true;
    try {
      await Navigator.of(
        context,
      ).push<bool>(MaterialPageRoute<bool>(builder: (_) => DailyLogFlow()));
    } finally {
      _logFlowOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    final snapshotAsync = ref.watch(cycleSnapshotProvider);
    final latestAsync = ref.watch(latestPeriodProvider);
    final allPeriodsAsync = ref.watch(allPeriodsProvider);
    final bleedDaysAsync = ref.watch(bleedDaysProvider);
    final loggedDaysAsync = ref.watch(totalLoggedDaysProvider);
    final bannerAsync = ref.watch(showSpeedUpBannerProvider);
    final todayLogAsync = ref.watch(todayLogProvider);
    final streakAsync = ref.watch(currentStreakProvider);
    final greetingAsync = ref.watch(homeGreetingProvider);

    final profile = profileAsync.valueOrNull;
    if (profileAsync.isLoading && profile == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: RituColors.sage500),
        ),
      );
    }
    if (profile == null || profile.onboardingCompletedAt == null) {
      return const Scaffold(
        body: Center(child: Text('Profile not found')),
      );
    }

    final name = profile.displayName;
    final snapshot = snapshotAsync.valueOrNull;
    final latest = latestAsync.valueOrNull;
    final lastPeriodLabel =
        latest == null ? null : formatShortMonthDay(latest.startedOn);
    final cycleLength =
        snapshot?.effectiveCycleLength ?? snapshot?.mean?.round();
    final classification =
        snapshot?.classification ?? CycleClassification.unclassified;
    final nextPeriodLabel = formatNextPeriodLabel(
      lastPeriodStartedOn: latest?.startedOn,
      effectiveCycleLength: cycleLength,
      sampleCycleLengths: snapshot?.sample ?? const [],
      asRange: classification == CycleClassification.variable,
    );
    final periodStartCount = allPeriodsAsync.valueOrNull?.length ?? 0;
    final periodDates = bleedDaysAsync.valueOrNull ?? {};
    final loggedDaysCount = loggedDaysAsync.valueOrNull ?? 0;
    final showSpeedUpBanner =
        (bannerAsync.valueOrNull ?? false) && !_bannerDismissed;
    final todayLog = todayLogAsync.valueOrNull;
    final streak = streakAsync.valueOrNull ?? 0;
    final greeting = greetingAsync.valueOrNull;

    return Scaffold(
      backgroundColor: RituColors.backgroundPage,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: switch (_tabIndex) {
                0 => _HomeTab(
                  name: name,
                  greeting: greeting,
                  cycleDay: snapshot?.cycleDay,
                  lastPeriodLabel: lastPeriodLabel,
                  nextPeriodLabel: nextPeriodLabel,
                  effectiveCycleLength: cycleLength,
                  periodStartCount: periodStartCount,
                  classification: classification,
                  todayPhase: snapshot?.todayPhase,
                  patternDaysLogged: loggedDaysCount.clamp(
                    0,
                    widget.patternDaysRequired,
                  ),
                  patternDaysRequired: widget.patternDaysRequired,
                  showSpeedUpBanner: showSpeedUpBanner,
                  selectedMood: _selectedMood,
                  moods: _moods,
                  calendarMonth: _calendarMonth,
                  periodDates: periodDates,
                  onMoodSelected: (mood) {
                    setState(() => _selectedMood = mood);
                  },
                  onDismissBanner: () {
                    setState(() => _bannerDismissed = true);
                  },
                  onMonthChanged: (month) {
                    setState(() => _calendarMonth = month);
                  },
                  todayLog: todayLog,
                  streak: streak,
                  onLogToday: _openDailyLog,
                ),
                1 => InsightsScreen(
                  loggedDaysCount: loggedDaysCount,
                  patternDaysRequired: widget.patternDaysRequired,
                  hasLoggedToday: todayLog != null,
                  onLogToday: _openDailyLog,
                ),
                2 => JournalScreen(
                  onSelectionModeChanged: (active) {
                    setState(() => _hideBottomNav = active);
                  },
                ),
                3 => SummaryScreen(
                  loggedDaysCount: loggedDaysCount,
                  patternDaysRequired: widget.patternDaysRequired,
                ),
                _ => _PlaceholderTab(label: _tabLabel(_tabIndex)),
              },
            ),
            if (!_hideBottomNav)
              _BottomNav(
                currentIndex: _tabIndex,
                onTap: (index) => setState(() => _tabIndex = index),
              ),
          ],
        ),
      ),
    );
  }

  String _tabLabel(int index) => switch (index) {
    1 => 'Insights',
    2 => 'Journal',
    3 => 'Summary',
    _ => 'Home',
  };
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({
    required this.name,
    this.greeting,
    required this.cycleDay,
    required this.lastPeriodLabel,
    required this.nextPeriodLabel,
    required this.effectiveCycleLength,
    required this.periodStartCount,
    required this.classification,
    required this.todayPhase,
    required this.patternDaysLogged,
    required this.patternDaysRequired,
    required this.showSpeedUpBanner,
    required this.selectedMood,
    required this.moods,
    required this.calendarMonth,
    required this.periodDates,
    required this.onMoodSelected,
    required this.onDismissBanner,
    required this.onMonthChanged,
    required this.onLogToday,
    this.todayLog,
    this.streak = 0,
  });

  final String name;
  final HomeGreeting? greeting;
  final int? cycleDay;
  final String? lastPeriodLabel;
  final String? nextPeriodLabel;
  final int? effectiveCycleLength;
  final int periodStartCount;
  final CycleClassification classification;
  final CyclePhase? todayPhase;
  final int patternDaysLogged;
  final int patternDaysRequired;
  final bool showSpeedUpBanner;
  final String? selectedMood;
  final List<(String, String)> moods;
  final DateTime calendarMonth;
  final Set<DateTime> periodDates;
  final ValueChanged<String> onMoodSelected;
  final VoidCallback onDismissBanner;
  final ValueChanged<DateTime> onMonthChanged;
  final Future<void> Function() onLogToday;
  final DailyLogEntry? todayLog;
  final int streak;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        if (greeting != null)
          HomeGreetingHeader(
            greeting: greeting!,
            name: name,
            streak: streak,
            onSettingsTap: () {
              Navigator.of(context).push<String>(
                MaterialPageRoute<String>(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          )
        else
          const SizedBox(
            height: 54,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: RituColors.sage500,
                ),
              ),
            ),
          ),
        const SizedBox(height: 16),
        _StatusCard(
          cycleDay: cycleDay,
          lastPeriodLabel: lastPeriodLabel,
          nextPeriodLabel: nextPeriodLabel,
          effectiveCycleLength: effectiveCycleLength,
          periodStartCount: periodStartCount,
          classification: classification,
          todayPhase: todayPhase,
        ),
        const SizedBox(height: 12),
        todayLog == null
            ? _CheckInCard(
                moods: moods,
                selectedMood: selectedMood,
                onMoodSelected: onMoodSelected,
                onLogToday: onLogToday,
              )
            : _LoggedTodayCard(entry: todayLog!, onEdit: onLogToday),
        if (patternDaysLogged > 0) ...[
          const SizedBox(height: 12),
          _PatternsCard(
            daysLogged: patternDaysLogged,
            daysRequired: patternDaysRequired,
          ),
        ],
        if (showSpeedUpBanner) ...[
          const SizedBox(height: 12),
          _SpeedUpBanner(onDismiss: onDismissBanner),
        ],
        const SizedBox(height: 20),
        Row(
          children: [
            Text(
              'Cycle calendar',
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 24 / 15,
                color: RituColors.textPrimary,
              ),
            ),
            const Spacer(),
            const Icon(
              LucideIcons.pencil,
              size: 18,
              color: RituColors.textDisabled,
            ),
          ],
        ),
        const SizedBox(height: 12),
        RituCalendar(
          month: calendarMonth,
          periodDates: periodDates,
          onMonthChanged: onMonthChanged,
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.cycleDay,
    required this.lastPeriodLabel,
    required this.nextPeriodLabel,
    required this.effectiveCycleLength,
    required this.periodStartCount,
    required this.classification,
    required this.todayPhase,
  });

  final int? cycleDay;
  final String? lastPeriodLabel;
  final String? nextPeriodLabel;
  final int? effectiveCycleLength;
  final int periodStartCount;
  final CycleClassification classification;
  final CyclePhase? todayPhase;

  @override
  Widget build(BuildContext context) {
    final hasPeriod = cycleDay != null && lastPeriodLabel != null;
    final showPhaseCard = hasPeriod &&
        (classification == CycleClassification.regular ||
            classification == CycleClassification.variable);
    if (showPhaseCard) {
      return _PhaseStatusCard(
        cycleDay: cycleDay!,
        lastPeriodLabel: lastPeriodLabel!,
        nextPeriodLabel: nextPeriodLabel,
        effectiveCycleLength: effectiveCycleLength,
        todayPhase: todayPhase,
        estimatedPhases: classification == CycleClassification.variable,
      );
    }

    final trailing = !hasPeriod
        ? 'No history yet'
        : classification == CycleClassification.unclassified
        ? unclassifiedStatusTrailingLabel(
            periodStartCount: periodStartCount,
            cycleDay: cycleDay,
          )
        : '';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment(-0.8, -0.6),
          end: Alignment(0.9, 0.7),
          colors: [
            RituColors.gradientSh1,
            RituColors.gradientSh2,
            RituColors.gradientSh3,
          ],
          stops: [0.11, 0.56, 0.88],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hasPeriod ? '$cycleDay' : '—',
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 52,
              fontWeight: FontWeight.w400,
              height: 54 / 52,
              color: RituColors.textInverse,
            ),
          ),
          Text(
            hasPeriod ? 'days into your cycle' : 'No period logged yet',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 20 / 13,
              color: RituColors.textInverse,
            ),
          ),
          const SizedBox(height: 8),
          Container(height: 1, color: RituColors.white.withValues(alpha: 0.35)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  hasPeriod
                      ? 'Last period $lastPeriodLabel'
                      : 'Add your last period in Settings',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    height: 18 / 11,
                    color: RituColors.textInverse,
                  ),
                ),
              ),
              Text(
                trailing,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  height: 18 / 11,
                  color: RituColors.textInverse,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Regular / Variable classification hero — phase-colored gradient, badge,
/// next period (exact date or estimated range).
class _PhaseStatusCard extends StatelessWidget {
  const _PhaseStatusCard({
    required this.cycleDay,
    required this.lastPeriodLabel,
    required this.nextPeriodLabel,
    required this.effectiveCycleLength,
    required this.todayPhase,
    this.estimatedPhases = false,
  });

  final int cycleDay;
  final String lastPeriodLabel;
  final String? nextPeriodLabel;
  final int? effectiveCycleLength;
  final CyclePhase? todayPhase;

  /// Variable users: `~` on non-menstrual phase names.
  final bool estimatedPhases;

  static const _menstrualAsset = 'assets/images/phase_menstrual.png';
  static const _follicularAsset = 'assets/images/phase_follicular.png';
  static const _ovulatoryAsset = 'assets/images/phase_ovulatory.png';
  static const _lutealAsset = 'assets/images/phase_luteal.png';

  bool get _isMenstrual => todayPhase == CyclePhase.menstrual;

  List<Color> get _gradientColors => switch (todayPhase) {
    CyclePhase.menstrual => const [
      RituColors.gradientRw1,
      RituColors.gradientRw2,
    ],
    CyclePhase.ovulatory => const [
      RituColors.gradientGh1,
      RituColors.gradientGh2,
    ],
    CyclePhase.luteal => const [
      RituColors.gradientLilac1,
      RituColors.gradientLilac2,
    ],
    _ => const [
      RituColors.gradientMl1,
      RituColors.gradientMl2,
    ],
  };

  String get _illustrationAsset => switch (todayPhase) {
    CyclePhase.menstrual => _menstrualAsset,
    CyclePhase.ovulatory => _ovulatoryAsset,
    CyclePhase.luteal => _lutealAsset,
    _ => _follicularAsset,
  };

  String get _daySubtitle => _isMenstrual
      ? 'days into your period'
      : 'days into your cycle';

  String get _footerLeading {
    if (_isMenstrual && effectiveCycleLength != null) {
      return '$effectiveCycleLength day cycle';
    }
    return 'Last period $lastPeriodLabel';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: const Alignment(-0.95, -0.25),
          end: const Alignment(0.95, 0.35),
          colors: _gradientColors,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (todayPhase != null)
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: RituColors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2.5,
                          ),
                          child: Text(
                            phaseDisplayLabel(
                              todayPhase!,
                              estimated: estimatedPhases,
                            ),
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              height: 18 / 11,
                              color: RituColors.textDisabled,
                            ),
                          ),
                        ),
                      ),
                    Text(
                      '$cycleDay',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 52,
                        fontWeight: FontWeight.w400,
                        height: 54 / 52,
                        color: RituColors.textInverse,
                      ),
                    ),
                    Text(
                      _daySubtitle,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        height: 20 / 13,
                        color: RituColors.textInverse,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 100,
                height: 97,
                child: Image(
                  image: AssetImage(_illustrationAsset),
                  fit: BoxFit.contain,
                  alignment: Alignment.centerRight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(height: 1, color: RituColors.white.withValues(alpha: 0.35)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  _footerLeading,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    height: 18 / 11,
                    color: RituColors.textInverse,
                  ),
                ),
              ),
              if (nextPeriodLabel != null)
                Text(
                  'Next period $nextPeriodLabel',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    height: 18 / 11,
                    color: RituColors.textInverse,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CheckInCard extends StatelessWidget {
  const _CheckInCard({
    required this.moods,
    required this.selectedMood,
    required this.onMoodSelected,
    required this.onLogToday,
  });

  final List<(String, String)> moods;
  final String? selectedMood;
  final ValueChanged<String> onMoodSelected;
  final Future<void> Function() onLogToday;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 20),
      decoration: BoxDecoration(
        color: RituColors.fillElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RituColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How are you feeling today?',
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 24 / 15,
              color: RituColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < moods.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _MoodChip(
                    emoji: moods[i].$1,
                    label: moods[i].$2,
                    selected: selectedMood == moods[i].$2,
                    onTap: () => onMoodSelected(moods[i].$2),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Complete today's check-in",
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 20 / 13,
              color: RituColors.textSecondary,
            ),
          ),
          Text(
            'Takes less than 30 seconds',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              height: 18 / 11,
              color: RituColors.textTertiary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: FilledButton(
              onPressed: onLogToday,
              style: FilledButton.styleFrom(
                backgroundColor: RituColors.sage500,
                foregroundColor: RituColors.white,
                padding: EdgeInsets.zero,
                textStyle: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 20 / 13,
                ),
                shape: const StadiumBorder(),
              ),
              child: const Text('Log today'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Home summary card once today's daily log is saved (Figma Home →
/// "New user after logged").
class _LoggedTodayCard extends StatelessWidget {
  const _LoggedTodayCard({required this.entry, required this.onEdit});

  final DailyLogEntry entry;
  final Future<void> Function() onEdit;

  List<String> get _summaryChips {
    return [
      if (entry.flowIntensity != null && entry.flowIntensity != 'None')
        '${entry.flowIntensity} flow',
      ...entry.moods,
      if (entry.energyLevel != null) '${entry.energyLevel} energy',
      if (entry.sleepQuality != null) '${entry.sleepQuality} sleep',
      ...entry.symptoms,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final chips = _summaryChips;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RituColors.fillElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RituColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.circleCheck,
                size: 24,
                color: RituColors.sage600,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Logged today',
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 24 / 15,
                    color: RituColors.textPrimary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onEdit,
                behavior: HitTestBehavior.opaque,
                child: Text(
                  'Edit',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 20 / 13,
                    color: RituColors.sage600,
                  ),
                ),
              ),
            ],
          ),
          if (chips.isEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'No details added — tap Edit to fill them in',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                height: 20 / 13,
                color: RituColors.textTertiary,
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final chip in chips)
                  Container(
                    height: 28,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: RituColors.fillSubtle,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      chip,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        height: 20 / 13,
                        color: RituColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MoodChip extends StatelessWidget {
  const _MoodChip({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 69,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selected ? RituColors.fillSecondary : RituColors.fillSubtle,
          borderRadius: BorderRadius.circular(12),
          border: selected
              ? Border.all(color: RituColors.sage600)
              : Border.all(color: Colors.transparent),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18, height: 1.2)),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                height: 18 / 11,
                color: RituColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PatternsCard extends StatelessWidget {
  const _PatternsCard({required this.daysLogged, required this.daysRequired});

  final int daysLogged;
  final int daysRequired;

  @override
  Widget build(BuildContext context) {
    final progress = (daysLogged / daysRequired).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RituColors.fillAccent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your patterns will appear here',
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 24 / 15,
              color: RituColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Keep logging and Ritu will surface trends in your energy, mood, and sleep.',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 20 / 13,
              color: RituColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: RituColors.white,
              color: RituColors.meadow600,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '$daysLogged of $daysRequired days – pattern unlock at $daysRequired',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                height: 18 / 11,
                color: RituColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeedUpBanner extends StatelessWidget {
  const _SpeedUpBanner({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RituColors.fillInfo,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Speed up your patterns',
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 24 / 15,
                    color: RituColors.textPrimary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onDismiss,
                child: const Icon(
                  LucideIcons.x,
                  size: 18,
                  color: RituColors.textDisabled,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Adding past period dates helps Ritu understand your cycle right away',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 20 / 13,
              color: RituColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add past dates →',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 20 / 13,
              color: RituColors.textPositive,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    (LucideIcons.house, 'Home'),
    (LucideIcons.activity, 'Insights'),
    (LucideIcons.bookOpen, 'Journal'),
    (LucideIcons.notepadText, 'Summary'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: RituColors.fillElevated,
        border: Border(top: BorderSide(color: RituColors.borderSubtle)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => onTap(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _items[i].$1,
                          size: 22,
                          color: currentIndex == i
                              ? RituColors.sage600
                              : RituColors.textDisabled,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _items[i].$2,
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            height: 14 / 10,
                            color: currentIndex == i
                                ? RituColors.sage600
                                : RituColors.textDisabled,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$label coming soon',
        style: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: RituColors.textSecondary,
        ),
      ),
    );
  }
}
