import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/models/daily_log_entry.dart';
import '../../providers/daily_log_providers.dart';
import '../../providers/simulated_today_provider.dart';
import '../../theme/ritu_colors.dart';
import 'insight_history.dart';

/// Insights tab — empty state until the first daily log, then a progress
/// teaser. Once [patternDaysRequired] logs exist, shows the history heatmap
/// (Figma 899-6470). Key insights are not shown yet.
class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({
    super.key,
    this.patternDaysRequired = 14,
    this.onLogToday,
  });

  final int patternDaysRequired;
  final VoidCallback? onLogToday;

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  InsightLens _lens = InsightLens.overview;

  @override
  Widget build(BuildContext context) {
    final loggedDaysCount = ref.watch(totalLoggedDaysProvider).valueOrNull ?? 0;
    final hasLoggedToday = ref.watch(todayLogProvider).valueOrNull != null;
    final logs =
        ref.watch(allDailyLogsProvider).valueOrNull ?? const <DailyLogEntry>[];
    final today = ref.watch(simulatedTodayProvider);

    if (loggedDaysCount >= widget.patternDaysRequired) {
      return _HistoryView(
        loggedDaysCount: loggedDaysCount,
        logs: logs,
        today: today,
        lens: _lens,
        onLensSelected: (lens) => setState(() => _lens = lens),
      );
    }

    return _ProgressView(
      loggedDaysCount: loggedDaysCount,
      patternDaysRequired: widget.patternDaysRequired,
      hasLoggedToday: hasLoggedToday,
      onLogToday: widget.onLogToday,
    );
  }
}

class _ProgressView extends StatelessWidget {
  const _ProgressView({
    required this.loggedDaysCount,
    required this.patternDaysRequired,
    required this.hasLoggedToday,
    this.onLogToday,
  });

  final int loggedDaysCount;
  final int patternDaysRequired;
  final bool hasLoggedToday;
  final VoidCallback? onLogToday;

  /// Empty-state banner (Figma pastel-green-banner-2).
  static const _heroBackgroundEmpty = Color(0xFFEDF0EC);

  /// After-logged banner (Figma pastel-green-banner).
  static const _heroBackgroundProgress = Color(0xFFE7E9DE);

  static const _unlockItems = [
    (
      LucideIcons.trendingUp,
      RituColors.fillPositiveSecondary,
      RituColors.textPositive,
      'Energy trends',
      'See how your energy changes over time',
    ),
    (
      LucideIcons.audioWaveform,
      RituColors.fillInfoSecondary,
      RituColors.iconInfo,
      'Symptom patterns',
      'Discover what triggers and affects you',
    ),
    (
      LucideIcons.star,
      RituColors.fillCriticalSecondary,
      RituColors.iconCritical,
      'Cycle insights',
      'Get personalised predictions and phase insights',
    ),
    (
      LucideIcons.notepadText,
      RituColors.fillAttentionSecondary,
      RituColors.iconAttention,
      'Monthly summaries',
      'Summaries to reflect on your journey',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final hasStartedLogging = loggedDaysCount > 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text(
          'Insights',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 28,
            fontWeight: FontWeight.w400,
            height: 34 / 28,
            color: RituColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Understand your patterns',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 20 / 13,
            color: RituColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        _HeroCard(
          hasStartedLogging: hasStartedLogging,
          daysLogged: loggedDaysCount.clamp(0, patternDaysRequired),
          daysRequired: patternDaysRequired,
          showLogToday: !hasLoggedToday,
          onLogToday: onLogToday,
        ),
        const SizedBox(height: 20),
        Text(
          'What you’ll unlock',
          style: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            height: 24 / 15,
            color: RituColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < _unlockItems.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          _UnlockRow(
            icon: _unlockItems[i].$1,
            iconBackground: _unlockItems[i].$2,
            iconColor: _unlockItems[i].$3,
            title: _unlockItems[i].$4,
            subtitle: _unlockItems[i].$5,
          ),
        ],
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.hasStartedLogging,
    required this.daysLogged,
    required this.daysRequired,
    required this.showLogToday,
    this.onLogToday,
  });

  final bool hasStartedLogging;
  final int daysLogged;
  final int daysRequired;
  final bool showLogToday;
  final VoidCallback? onLogToday;

  @override
  Widget build(BuildContext context) {
    final progress = daysRequired == 0
        ? 0.0
        : (daysLogged / daysRequired).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasStartedLogging
            ? _ProgressView._heroBackgroundProgress
            : _ProgressView._heroBackgroundEmpty,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 116,
            height: 118,
            child: Image.asset(
              hasStartedLogging
                  ? 'assets/images/insights_rhythm.png'
                  : 'assets/images/insights_journey.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            hasStartedLogging
                ? 'Learning your rhythm'
                : 'Your journey is just beginning',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 24 / 18,
              color: RituColors.textPrimary,
            ),
          ),
          Text(
            hasStartedLogging
                ? 'Keep logging daily and Ritu will begin finding meaningful patterns'
                : 'Once you start logging daily, Ritu will find patterns unique to your body',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 20 / 13,
              color: RituColors.textSecondary,
            ),
          ),
          if (hasStartedLogging) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                backgroundColor: RituColors.white,
                color: RituColors.meadow600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$daysLogged of $daysRequired days – pattern unlock at $daysRequired',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                height: 18 / 11,
                color: RituColors.textSecondary,
              ),
            ),
          ] else if (showLogToday) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 36,
              child: FilledButton(
                onPressed: onLogToday,
                style: FilledButton.styleFrom(
                  backgroundColor: RituColors.sage500,
                  foregroundColor: RituColors.white,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: const StadiumBorder(),
                  textStyle: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 20 / 13,
                  ),
                ),
                child: const Text('Log today'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _UnlockRow extends StatelessWidget {
  const _UnlockRow({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RituColors.fillElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RituColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 20 / 13,
                    color: RituColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    height: 18 / 11,
                    color: RituColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const _chipBorder = Color(0xFFE2DDD8);

class _HistoryView extends StatelessWidget {
  const _HistoryView({
    required this.loggedDaysCount,
    required this.logs,
    required this.today,
    required this.lens,
    required this.onLensSelected,
  });

  final int loggedDaysCount;
  final List<DailyLogEntry> logs;
  final DateTime today;
  final InsightLens lens;
  final ValueChanged<InsightLens> onLensSelected;

  @override
  Widget build(BuildContext context) {
    final strips = buildInsightHistory(logs: logs, today: today, lens: lens);
    final copy = _lensCopy(lens);
    final dayLabel = loggedDaysCount == 1 ? 'day' : 'days';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text(
          'Insights',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 28,
            fontWeight: FontWeight.w400,
            height: 34 / 28,
            color: RituColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Based on $loggedDaysCount $dayLabel of logs',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 20 / 13,
            color: RituColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final option in InsightLens.values)
              _LensChip(
                label: _lensLabel(option),
                selected: option == lens,
                onTap: () => onLensSelected(option),
              ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          copy.title,
          style: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            height: 24 / 15,
            color: RituColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < strips.length; i++) ...[
          if (i > 0) const SizedBox(height: 4),
          _MonthStrip(strip: strips[i]),
        ],
        if (strips.isNotEmpty) const SizedBox(height: 8),
        _Legend(labels: copy.legend),
        const SizedBox(height: 20),
        const _ConsistencyCard(),
      ],
    );
  }
}

({String title, List<String> legend}) _lensCopy(InsightLens lens) {
  return switch (lens) {
    InsightLens.overview => (
      title: 'Wellbeing over time',
      legend: ['Low', 'Okay', 'High', 'No data'],
    ),
    InsightLens.mood => (
      title: 'Mood over time',
      legend: ['Heavy', 'Mixed', 'Light', 'No data'],
    ),
    InsightLens.energy => (
      title: 'Energy over time',
      legend: ['Low', 'Medium', 'High', 'No data'],
    ),
    InsightLens.body => (
      title: 'Body signals over time',
      legend: ['2 or more signals', 'one signal', 'No signal', 'No data'],
    ),
  };
}

String _lensLabel(InsightLens lens) {
  return switch (lens) {
    InsightLens.overview => 'Overview',
    InsightLens.mood => 'Mood',
    InsightLens.energy => 'Energy',
    InsightLens.body => 'Body',
  };
}

class _LensChip extends StatelessWidget {
  const _LensChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? RituColors.fillBrandPressed : RituColors.fillSubtle,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? Colors.transparent : _chipBorder,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            height: 20 / 13,
            color: selected ? RituColors.textInverse : RituColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _MonthStrip extends StatelessWidget {
  const _MonthStrip({required this.strip});

  final InsightMonthStrip strip;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: Row(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 25),
            child: Text(
              strip.label,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                height: 20 / 13,
                color: RituColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var i = 0; i < strip.levels.length; i++) ...[
                    if (i > 0) const SizedBox(width: 4),
                    Container(
                      width: 12,
                      height: 15,
                      decoration: BoxDecoration(
                        color: _levelColor(strip.levels[i]),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Color _levelColor(InsightLevel level) {
  return switch (level) {
    InsightLevel.low => RituColors.heatmapLow,
    InsightLevel.mid => RituColors.heatmapOkay,
    InsightLevel.high => RituColors.heatmapHigh,
    InsightLevel.none => RituColors.heatmapNoData,
  };
}

class _Legend extends StatelessWidget {
  const _Legend({required this.labels});

  final List<String> labels;

  static const _colors = [
    RituColors.heatmapLow,
    RituColors.heatmapOkay,
    RituColors.heatmapHigh,
    RituColors.heatmapNoData,
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        for (var i = 0; i < labels.length && i < _colors.length; i++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _colors[i],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                labels[i],
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  height: 18 / 11,
                  color: RituColors.textSecondary,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _ConsistencyCard extends StatelessWidget {
  const _ConsistencyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RituColors.fillInfo,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RituColors.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: Center(
              child: Icon(
                LucideIcons.info,
                size: 16,
                color: RituColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Consistency is powerful',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 20 / 13,
                    color: RituColors.textPrimary,
                  ),
                ),
                Text(
                  'Keep logging to unlock deeper insights and long-term trends',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    height: 18 / 11,
                    color: RituColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
