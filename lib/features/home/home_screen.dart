import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/app_scope.dart';
import '../../core/date_format.dart';
import '../../theme/ritu_colors.dart';
import '../insights/insights_screen.dart';
import '../journal/journal_screen.dart';
import '../reports/reports_screen.dart';
import '../settings/settings_screen.dart';
import '../setup/widgets/ritu_calendar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.name,
    required this.loggingSince,
    this.patternDaysRequired = 14,
  });

  final String name;
  final DateTime loggingSince;
  final int patternDaysRequired;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;
  bool _showSpeedUpBanner = true;
  String? _selectedMood;
  late DateTime _calendarMonth;
  late String _name;

  int? _daysSinceLastPeriod;
  String? _lastPeriodLabel;
  Set<DateTime> _periodDates = {};
  int _periodCount = 0;
  bool _periodDataLoaded = false;

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
    _name = widget.name;
    final now = DateTime.now();
    _calendarMonth = DateTime(now.year, now.month);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_periodDataLoaded) {
      _periodDataLoaded = true;
      _loadPeriodData();
    }
  }

  Future<void> _loadPeriodData() async {
    final periods = AppScope.periods(context);
    final latest = await periods.getLatest();
    final days = await periods.daysSinceLastPeriod();
    final bleed = await periods.allBleedDays();
    final all = await periods.getAll();
    if (!mounted) return;
    setState(() {
      _daysSinceLastPeriod = days;
      _lastPeriodLabel =
          latest == null ? null : formatDisplayDate(latest.startedOn);
      _periodDates = bleed;
      _periodCount = all.length;
      _showSpeedUpBanner = all.length < 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RituColors.backgroundPage,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: switch (_tabIndex) {
                0 => _HomeTab(
                    name: _name,
                    loggingSince: widget.loggingSince,
                    daysSinceLastPeriod: _daysSinceLastPeriod,
                    lastPeriodLabel: _lastPeriodLabel,
                    patternDaysLogged:
                        _periodCount.clamp(0, widget.patternDaysRequired),
                    patternDaysRequired: widget.patternDaysRequired,
                    showSpeedUpBanner: _showSpeedUpBanner,
                    selectedMood: _selectedMood,
                    moods: _moods,
                    calendarMonth: _calendarMonth,
                    periodDates: _periodDates,
                    onMoodSelected: (mood) {
                      setState(() => _selectedMood = mood);
                    },
                    onDismissBanner: () {
                      setState(() => _showSpeedUpBanner = false);
                    },
                    onMonthChanged: (month) {
                      setState(() => _calendarMonth = month);
                    },
                    onNameUpdated: (name) {
                      setState(() => _name = name);
                    },
                    onReturnedFromSettings: _loadPeriodData,
                    periodStartedLabel: _lastPeriodLabel,
                  ),
                1 => InsightsScreen(
                    onLogToday: () => setState(() => _tabIndex = 0),
                  ),
                2 => const JournalScreen(),
                3 => const ReportsScreen(),
                _ => _PlaceholderTab(label: _tabLabel(_tabIndex)),
              },
            ),
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
        3 => 'Reports',
        _ => 'Home',
      };
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({
    required this.name,
    required this.loggingSince,
    required this.daysSinceLastPeriod,
    required this.lastPeriodLabel,
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
    required this.onNameUpdated,
    required this.onReturnedFromSettings,
    this.periodStartedLabel,
  });

  final String name;
  final DateTime loggingSince;
  final int? daysSinceLastPeriod;
  final String? lastPeriodLabel;
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
  final ValueChanged<String> onNameUpdated;
  final Future<void> Function() onReturnedFromSettings;
  final String? periodStartedLabel;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _Header(
          name: name,
          onSettingsTap: () async {
            final updated = await Navigator.of(context).push<String>(
              MaterialPageRoute<String>(
                builder: (_) => SettingsScreen(
                  name: name,
                  loggingSince: loggingSince,
                  periodStartedLabel: periodStartedLabel,
                ),
              ),
            );
            if (updated != null) onNameUpdated(updated);
            await onReturnedFromSettings();
          },
        ),
        const SizedBox(height: 16),
        _StatusCard(
          daysSinceLastPeriod: daysSinceLastPeriod,
          lastPeriodLabel: lastPeriodLabel,
        ),
        const SizedBox(height: 12),
        _CheckInCard(
          moods: moods,
          selectedMood: selectedMood,
          onMoodSelected: onMoodSelected,
        ),
        const SizedBox(height: 12),
        _PatternsCard(
          daysLogged: patternDaysLogged,
          daysRequired: patternDaysRequired,
        ),
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
              Icons.edit_outlined,
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

class _Header extends StatelessWidget {
  const _Header({
    required this.name,
    required this.onSettingsTap,
  });

  final String name;
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome,',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 20 / 13,
                  color: RituColors.textSecondary,
                ),
              ),
              Text(
                '$name ✨',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  height: 34 / 28,
                  color: RituColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            const Icon(
              Icons.local_fire_department_outlined,
              size: 20,
              color: RituColors.textDisabled,
            ),
            const SizedBox(width: 4),
            Text(
              '0',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: RituColors.textDisabled,
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onSettingsTap,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.settings_outlined,
                  size: 22,
                  color: RituColors.textDisabled,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.daysSinceLastPeriod,
    required this.lastPeriodLabel,
  });

  final int? daysSinceLastPeriod;
  final String? lastPeriodLabel;

  @override
  Widget build(BuildContext context) {
    final hasPeriod = daysSinceLastPeriod != null && lastPeriodLabel != null;
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
            hasPeriod ? '$daysSinceLastPeriod' : '—',
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 52,
              fontWeight: FontWeight.w400,
              height: 54 / 52,
              color: RituColors.textInverse,
            ),
          ),
          Text(
            hasPeriod ? 'days since last period' : 'No period logged yet',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 20 / 13,
              color: RituColors.textInverse,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: RituColors.white.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 12),
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
                hasPeriod ? '' : 'No history yet',
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
  });

  final List<(String, String)> moods;
  final String? selectedMood;
  final ValueChanged<String> onMoodSelected;

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
              onPressed: () {},
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
  const _PatternsCard({
    required this.daysLogged,
    required this.daysRequired,
  });

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
                  Icons.close,
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
  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    (Icons.home_outlined, Icons.home, 'Home'),
    (Icons.monitor_heart_outlined, Icons.monitor_heart, 'Insights'),
    (Icons.menu_book_outlined, Icons.menu_book, 'Journal'),
    (Icons.assignment_outlined, Icons.assignment, 'Reports'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: RituColors.fillElevated,
        border: Border(
          top: BorderSide(color: RituColors.borderSubtle),
        ),
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
                          currentIndex == i
                              ? _items[i].$2
                              : _items[i].$1,
                          size: 22,
                          color: currentIndex == i
                              ? RituColors.sage600
                              : RituColors.textDisabled,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _items[i].$3,
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
