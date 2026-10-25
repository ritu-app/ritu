import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/cycle/cycle_classification.dart';
import '../../data/models/daily_log_entry.dart';
import '../../data/models/period_log.dart';
import '../../providers/cycle_snapshot_provider.dart';
import '../../providers/daily_log_providers.dart';
import '../../providers/period_providers.dart';
import '../../providers/simulated_today_provider.dart';
import '../../theme/ritu_palette.dart';
import 'consistent_cycle_copy.dart';
import 'cycle_length_record.dart';
import 'cycles_covered_by_logs.dart';
import 'insight_history.dart';
import 'most_logged.dart';
import 'unpredictable_cycle_copy.dart';
import 'variable_cycle_copy.dart';

/// Insights tab — empty state until the first daily log, then a progress
/// teaser. Once [patternDaysRequired] logs exist, shows the history heatmap.
/// Mood, Energy, and Body stay locked until those logs fall in at least
/// three period cycles (Figma 899-6584). After that, those tabs list what
/// was logged most (Figma 899-6940 / 899-7118 / 899-7301). Pattern banners
/// are not shown yet. Under Key insights on Overview, a consistency note
/// stays until the cycle is Regular (Figma 899-6470 / 899-6767). A Variable
/// cycle replaces that note with the length range on Overview, and explains
/// on every tab that patterns are anchored before the period (Figma 899-9056).
/// An Unpredictable cycle uses the same slots with its own copy, and adds a
/// cycle length record on Overview (Figma 899-11340).
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
    final snapshot = ref.watch(cycleSnapshotProvider).valueOrNull;
    final periods =
        ref.watch(allPeriodsProvider).valueOrNull ?? const <PeriodLog>[];
    final classification =
        snapshot?.classification ?? CycleClassification.unclassified;
    final cycleLengths = snapshot?.sample ?? const <int>[];
    final consistentCycle = consistentCycleCopy(
      classification: classification,
      cycleLengths: cycleLengths,
    );
    final variableCycle = variableCycleCopy(
      classification: classification,
      cycleLengths: cycleLengths,
    );
    final unpredictableCycle = unpredictableCycleCopy(
      classification: classification,
      cycleLengths: cycleLengths,
    );
    final lengthRecord = unpredictableCycle == null
        ? const <CycleLengthRecordRow>[]
        : cycleLengthRecord(
            periodStarts: periods.map((period) => period.startedOn),
          );
    final cyclesWithLogs = cyclesCoveredByLogs(
      logDates: logs.map((log) => log.loggedOn),
      periodStarts: periods.map((period) => period.startedOn),
    );

    if (loggedDaysCount >= widget.patternDaysRequired) {
      return _HistoryView(
        loggedDaysCount: loggedDaysCount,
        logs: logs,
        today: today,
        lens: _lens,
        onLensSelected: (lens) => setState(() => _lens = lens),
        consistentCycle: consistentCycle,
        variableCycle: variableCycle,
        unpredictableCycle: unpredictableCycle,
        lengthRecord: lengthRecord,
        cyclesWithLogs: cyclesWithLogs,
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

  static List<(IconData, Color, Color, String, String)> _unlockItems(
    BuildContext context,
  ) => [
    (
      LucideIcons.trendingUp,
      context.ritu.fillPositiveSecondary,
      context.ritu.textPositive,
      'Energy trends',
      'See how your energy changes over time',
    ),
    (
      LucideIcons.audioWaveform,
      context.ritu.fillInfoSecondary,
      context.ritu.iconInfo,
      'Symptom patterns',
      'Discover what triggers and affects you',
    ),
    (
      LucideIcons.star,
      context.ritu.fillCriticalSecondary,
      context.ritu.iconCritical,
      'Cycle insights',
      'Get personalised predictions and phase insights',
    ),
    (
      LucideIcons.notepadText,
      context.ritu.fillAttentionSecondary,
      context.ritu.iconAttention,
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
            color: context.ritu.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Understand your patterns',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 20 / 13,
            color: context.ritu.textSecondary,
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
            color: context.ritu.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < _unlockItems(context).length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          _UnlockRow(
            icon: _unlockItems(context)[i].$1,
            iconBackground: _unlockItems(context)[i].$2,
            iconColor: _unlockItems(context)[i].$3,
            title: _unlockItems(context)[i].$4,
            subtitle: _unlockItems(context)[i].$5,
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
              color: context.ritu.textPrimary,
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
              color: context.ritu.textSecondary,
            ),
          ),
          if (hasStartedLogging) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                backgroundColor: context.ritu.white,
                color: context.ritu.meadow600,
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
                color: context.ritu.textSecondary,
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
                  backgroundColor: context.ritu.sage500,
                  foregroundColor: context.ritu.white,
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
        color: context.ritu.fillElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.ritu.borderSubtle),
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
                    color: context.ritu.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    height: 18 / 11,
                    color: context.ritu.textTertiary,
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

class _HistoryView extends StatelessWidget {
  const _HistoryView({
    required this.loggedDaysCount,
    required this.logs,
    required this.today,
    required this.lens,
    required this.onLensSelected,
    this.consistentCycle,
    this.variableCycle,
    this.unpredictableCycle,
    this.lengthRecord = const [],
    this.cyclesWithLogs = 0,
  });

  final int loggedDaysCount;
  final List<DailyLogEntry> logs;
  final DateTime today;
  final InsightLens lens;
  final ValueChanged<InsightLens> onLensSelected;
  final ConsistentCycleCopy? consistentCycle;
  final VariableCycleCopy? variableCycle;
  final UnpredictableCycleCopy? unpredictableCycle;
  final List<CycleLengthRecordRow> lengthRecord;
  final int cyclesWithLogs;

  @override
  Widget build(BuildContext context) {
    final strips = buildInsightHistory(logs: logs, today: today, lens: lens);
    final copy = _lensCopy(lens);
    final loggedMost = mostLoggedLabels(logs: logs, today: today, lens: lens);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text(
          'Insights',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 28,
            fontWeight: FontWeight.w400,
            height: 34 / 28,
            color: context.ritu.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _historyBasis(
            loggedDaysCount: loggedDaysCount,
            cyclesWithLogs: cyclesWithLogs,
          ),
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 20 / 13,
            color: context.ritu.textSecondary,
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
        if (variableCycle != null) ...[
          _HowInsightsWorkCard(
            body: _variableHowInsightsBody,
            background: context.ritu.fillAttention,
          ),
          const SizedBox(height: 20),
        ] else if (unpredictableCycle != null) ...[
          _HowInsightsWorkCard(
            body: unpredictableCycle!.howInsightsBody,
            background: context.ritu.fillCritical,
          ),
          const SizedBox(height: 20),
        ],
        if (lens != InsightLens.overview && cyclesWithLogs < 3)
          _KeepGoingCard(cyclesWithLogs: cyclesWithLogs)
        else ...[
          Text(
            copy.title,
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 24 / 15,
              color: context.ritu.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < strips.length; i++) ...[
            if (i > 0) const SizedBox(height: 4),
            _MonthStrip(strip: strips[i]),
          ],
          if (strips.isNotEmpty) const SizedBox(height: 8),
          _Legend(labels: copy.legend),
          if (lens == InsightLens.overview) ...[
            const SizedBox(height: 20),
            Text(
              'Key insights',
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 24 / 15,
                color: context.ritu.textPrimary,
              ),
            ),
            if (consistentCycle != null) ...[
              const SizedBox(height: 16),
              _ConsistentCycleCard(copy: consistentCycle!),
            ] else if (variableCycle != null) ...[
              const SizedBox(height: 16),
              _CycleVariationCard(
                title: variableCycle!.title,
                body: _variableCycleBody,
                footer: variableCycle!.recorded,
              ),
            ] else if (unpredictableCycle != null) ...[
              const SizedBox(height: 16),
              _CycleVariationCard(
                title: unpredictableCycle!.title,
                body: _unpredictableCycleBody,
                footer: unpredictableCycle!.recorded,
              ),
            ] else ...[
              const SizedBox(height: 16),
              const _ConsistencyCard(),
            ],
            if (lengthRecord.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'Cycle length record',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 24 / 15,
                  color: context.ritu.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _CycleLengthRecordTable(rows: lengthRecord),
              const SizedBox(height: 12),
              Text(
                'This table is included in your doctor PDF report',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  height: 18 / 11,
                  color: context.ritu.textTertiary,
                ),
              ),
            ],
          ] else if (loggedMost.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              _mostLoggedTitle(lens),
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 24 / 15,
                color: context.ritu.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final label in loggedMost)
                  _MostLoggedChip(
                    label: label,
                    fill: lens == InsightLens.mood
                        ? context.ritu.fillSecondary
                        : context.ritu.fillPositiveSecondary,
                  ),
              ],
            ),
          ],
        ],
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

String _historyBasis({
  required int loggedDaysCount,
  required int cyclesWithLogs,
}) {
  if (cyclesWithLogs >= 3) {
    final unit = cyclesWithLogs == 1 ? 'cycle' : 'cycles';
    return 'Based on $cyclesWithLogs $unit';
  }
  final unit = loggedDaysCount == 1 ? 'day' : 'days';
  return 'Based on $loggedDaysCount $unit of logs';
}

String _mostLoggedTitle(InsightLens lens) {
  return switch (lens) {
    InsightLens.mood => 'Most logged moods',
    InsightLens.energy => 'Energy levels you log most',
    InsightLens.body => 'Most common signals',
    InsightLens.overview => '',
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
          color: selected
              ? context.ritu.fillBrandPressed
              : context.ritu.fillSubtle,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? Colors.transparent : context.ritu.borderDefault,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            height: 20 / 13,
            color: selected
                ? context.ritu.textInverse
                : context.ritu.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _MostLoggedChip extends StatelessWidget {
  const _MostLoggedChip({required this.label, required this.fill});

  final String label;
  final Color fill;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: context.ritu.sage600),
      ),
      child: Center(
        widthFactor: 1,
        heightFactor: 1,
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 20 / 13,
            color: context.ritu.textPrimary,
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
                color: context.ritu.textSecondary,
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
                        color: _levelColor(context, strip.levels[i]),
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

Color _levelColor(BuildContext context, InsightLevel level) {
  return switch (level) {
    InsightLevel.low => context.ritu.heatmapLow,
    InsightLevel.mid => context.ritu.heatmapOkay,
    InsightLevel.high => context.ritu.heatmapHigh,
    InsightLevel.none => context.ritu.heatmapNoData,
  };
}

class _Legend extends StatelessWidget {
  const _Legend({required this.labels});

  final List<String> labels;

  static List<Color> _colors(BuildContext context) => [
    context.ritu.heatmapLow,
    context.ritu.heatmapOkay,
    context.ritu.heatmapHigh,
    context.ritu.heatmapNoData,
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        for (var i = 0; i < labels.length && i < _colors(context).length; i++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _colors(context)[i],
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
                  color: context.ritu.textSecondary,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _KeepGoingCard extends StatelessWidget {
  const _KeepGoingCard({required this.cyclesWithLogs});

  final int cyclesWithLogs;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.ritu.fillInfo,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Center(
              child: Icon(
                LucideIcons.info,
                size: 16,
                color: context.ritu.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keep going',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 20 / 13,
                    color: context.ritu.textPrimary,
                  ),
                ),
                Text(
                  _keepGoingBody(cyclesWithLogs),
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    height: 18 / 11,
                    color: context.ritu.textSecondary,
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

String _keepGoingBody(int cyclesWithLogs) {
  final remaining = (3 - cyclesWithLogs).clamp(1, 3);
  final unit = remaining == 1 ? 'cycle' : 'cycles';
  return 'You’re building something meaningful. '
      '$remaining more $unit to unlock deeper insights';
}

class _ConsistentCycleCard extends StatelessWidget {
  const _ConsistentCycleCard({required this.copy});

  final ConsistentCycleCopy copy;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.ritu.fillPositiveSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.ritu.borderPositive),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cycle length is consistent',
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 24 / 15,
              color: context.ritu.textPrimary,
            ),
          ),
          Text(
            copy.body,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 20 / 13,
              color: context.ritu.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            copy.average,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 18 / 11,
              color: context.ritu.textPositive,
            ),
          ),
        ],
      ),
    );
  }
}

const _variableHowInsightsBody =
    'Because your cycle length varies, patterns here are '
    'anchored to days before your period - not absolute day '
    'numbers';

const _variableCycleBody =
    'Your cycles shift noticeably. This is normal for many women. '
    'Patterns here use relative timing';

const _unpredictableCycleBody =
    'This level of variation can sometimes have an underlying cause. '
    "Worth discussing with a doctor if you haven't already";

class _HowInsightsWorkCard extends StatelessWidget {
  const _HowInsightsWorkCard({required this.body, required this.background});

  final String body;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Center(
              child: Icon(
                LucideIcons.info,
                size: 16,
                color: context.ritu.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How insights work for you',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 20 / 13,
                    color: context.ritu.textPrimary,
                  ),
                ),
                Text(
                  body,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    height: 18 / 11,
                    color: context.ritu.textSecondary,
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

class _CycleVariationCard extends StatelessWidget {
  const _CycleVariationCard({
    required this.title,
    required this.body,
    required this.footer,
  });

  final String title;
  final String body;
  final String footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.ritu.fillCriticalSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.ritu.borderCritical),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 24 / 15,
              color: context.ritu.textPrimary,
            ),
          ),
          Text(
            body,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 20 / 13,
              color: context.ritu.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            footer,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 18 / 11,
              color: context.ritu.textCritical,
            ),
          ),
        ],
      ),
    );
  }
}

class _CycleLengthRecordTable extends StatelessWidget {
  const _CycleLengthRecordTable({required this.rows});

  final List<CycleLengthRecordRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.ritu.fillElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.ritu.borderSubtle),
      ),
      child: Column(
        children: [
          _RecordRow(
            span: 'Cycle',
            length: 'Length',
            spanStyle: _recordHeaderStyle(context),
            lengthStyle: _recordHeaderStyle(context),
            showDivider: true,
          ),
          for (var i = 0; i < rows.length; i++)
            _RecordRow(
              span: rows[i].span,
              length: rows[i].length,
              spanStyle: _recordSpanStyle(context),
              lengthStyle: rows[i].inProgress
                  ? _recordProgressStyle(context)
                  : _recordLengthStyle(context),
              showDivider: i < rows.length - 1,
            ),
        ],
      ),
    );
  }
}

TextStyle _recordHeaderStyle(BuildContext context) => TextStyle(
  fontSize: 13,
  fontWeight: FontWeight.w400,
  height: 20 / 13,
  color: context.ritu.textTertiary,
);

TextStyle _recordSpanStyle(BuildContext context) => TextStyle(
  fontSize: 13,
  fontWeight: FontWeight.w500,
  height: 20 / 13,
  color: context.ritu.textPrimary,
);

TextStyle _recordLengthStyle(BuildContext context) => TextStyle(
  fontSize: 13,
  fontWeight: FontWeight.w600,
  height: 20 / 13,
  color: context.ritu.textPrimary,
);

TextStyle _recordProgressStyle(BuildContext context) => TextStyle(
  fontSize: 13,
  fontWeight: FontWeight.w600,
  height: 20 / 13,
  color: context.ritu.textSecondary,
);

class _RecordRow extends StatelessWidget {
  const _RecordRow({
    required this.span,
    required this.length,
    required this.spanStyle,
    required this.lengthStyle,
    required this.showDivider,
  });

  final String span;
  final String length;
  final TextStyle spanStyle;
  final TextStyle lengthStyle;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(
                bottom: BorderSide(
                  color: context.ritu.borderSubtle,
                  width: 0.5,
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(span, style: GoogleFonts.dmSans(textStyle: spanStyle)),
          ),
          Text(
            length,
            textAlign: TextAlign.right,
            style: GoogleFonts.dmSans(textStyle: lengthStyle),
          ),
        ],
      ),
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
        color: context.ritu.fillInfo,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.ritu.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Center(
              child: Icon(
                LucideIcons.info,
                size: 16,
                color: context.ritu.textPrimary,
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
                    color: context.ritu.textPrimary,
                  ),
                ),
                Text(
                  'Keep logging to unlock deeper insights and long-term trends',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    height: 18 / 11,
                    color: context.ritu.textSecondary,
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
