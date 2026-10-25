import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../theme/ritu_palette.dart';
import 'generate_summary_sheet.dart';

/// Summary tab.
///
/// Before [patternDaysRequired] daily logs, shows the empty or progress
/// teaser (Figma 411-844 / 411-1162). At that threshold, shows the generate
/// layout. With no completed cycle yet, an early-days note sits above the
/// button (Figma 934-3810). One or more completed cycles hides that note
/// (Figma 972-3499).
class SummaryScreen extends StatelessWidget {
  const SummaryScreen({
    super.key,
    this.loggedDaysCount = 0,
    this.patternDaysRequired = 14,
    this.completedCycles = 0,
  });

  /// Total calendar days with a saved daily log (drives empty vs progress UI).
  final int loggedDaysCount;
  final int patternDaysRequired;

  /// Completed cycles from the cycle engine. Zero keeps the early-days note
  /// on the unlocked summary.
  final int completedCycles;

  /// Lavender banner. Dark is Figma banners/lavender-banner.
  static const _heroBackground = Color(0xFFF5EFF6);
  static const _heroBackgroundDark = Color(0xFF503C53);
  static const _progressColor = Color(0xFF9C8FB5);

  static Color heroBackground(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return dark ? _heroBackgroundDark : _heroBackground;
  }

  static List<(IconData, Color, Color, String, String)> _valueItems(
    BuildContext context,
  ) => [
    (
      LucideIcons.stickyNote,
      context.ritu.fillAttentionSecondary,
      context.ritu.iconAttention,
      'Generate professional reports',
      'Export your health data in a clear format',
    ),
    (
      LucideIcons.stethoscope,
      context.ritu.fillInfoSecondary,
      context.ritu.iconInfo,
      'Share with healthcare professionals',
      'Support more informed health conversations',
    ),
    (
      LucideIcons.thumbsUp,
      context.ritu.fillPositiveSecondary,
      context.ritu.textPositive,
      'Make more informed decisions',
      'Use insights to support your well-being',
    ),
    (
      LucideIcons.squareLibrary,
      context.ritu.fillCriticalSecondary,
      context.ritu.iconCritical,
      'Keep everything in one place',
      'Access your health history whenever needed',
    ),
  ];

  bool get _unlocked => loggedDaysCount >= patternDaysRequired;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const _SummaryHeader(),
        if (_unlocked) ..._unlockedChildren(context) else ..._lockedChildren(),
      ],
    );
  }

  List<Widget> _lockedChildren() {
    final hasStartedLogging = loggedDaysCount > 0;
    return [
      const SizedBox(height: 20),
      _HeroCard(
        hasStartedLogging: hasStartedLogging,
        daysLogged: loggedDaysCount.clamp(0, patternDaysRequired),
        daysRequired: patternDaysRequired,
      ),
      const SizedBox(height: 20),
      const _WhySummarySection(),
    ];
  }

  List<Widget> _unlockedChildren(BuildContext context) {
    final showEarlyDays = completedCycles < 1;
    return [
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        height: 320,
        child: Image.asset(
          'assets/images/summary_ready.png',
          fit: BoxFit.cover,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        'Bring together your journal, mood, sleep, body signals '
        'and cycle into one meaningful summary',
        textAlign: TextAlign.center,
        style: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          height: 20 / 13,
          color: context.ritu.textSecondary,
        ),
      ),
      if (showEarlyDays) ...[
        const SizedBox(height: 20),
        const _EarlyDaysCallout(),
      ],
      const SizedBox(height: 20),
      FilledButton(
        onPressed: () => showGenerateSummarySheet(context),
        child: const Text('Generate summary'),
      ),
      const SizedBox(height: 20),
      const _WhySummarySection(),
    ];
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Summary',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 28,
            fontWeight: FontWeight.w400,
            height: 34 / 28,
            color: context.ritu.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Export your health data',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 20 / 13,
            color: context.ritu.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _EarlyDaysCallout extends StatelessWidget {
  const _EarlyDaysCallout();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.ritu.fillAttention,
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
                color: context.ritu.textAttention,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Still early days',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 20 / 13,
                    color: context.ritu.textPrimary,
                  ),
                ),
                Text(
                  'You haven’t completed a full cycle yet, so this report '
                  'can’t include cycle length or confirmed patterns. It’ll '
                  'cover what’s genuinely there: your daily logs so far',
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

class _WhySummarySection extends StatelessWidget {
  const _WhySummarySection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Why summary valuable',
          style: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            height: 24 / 15,
            color: context.ritu.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < SummaryScreen._valueItems(context).length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          _ValueRow(
            icon: SummaryScreen._valueItems(context)[i].$1,
            iconBackground: SummaryScreen._valueItems(context)[i].$2,
            iconColor: SummaryScreen._valueItems(context)[i].$3,
            title: SummaryScreen._valueItems(context)[i].$4,
            subtitle: SummaryScreen._valueItems(context)[i].$5,
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
  });

  final bool hasStartedLogging;
  final int daysLogged;
  final int daysRequired;

  @override
  Widget build(BuildContext context) {
    final progress = daysRequired == 0
        ? 0.0
        : (daysLogged / daysRequired).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SummaryScreen.heroBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.ritu.borderDefault, width: 0.5),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 116,
            height: 118,
            child: Image.asset(
              'assets/images/summary_health.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your first summary is on the way',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 24 / 18,
              color: context.ritu.textPrimary,
            ),
          ),
          Text(
            'Keep logging daily to unlock your personalised health summary',
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
                backgroundColor: context.ritu.fillElevated,
                color: SummaryScreen._progressColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$daysLogged of $daysRequired days – summary unlock at $daysRequired',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                height: 18 / 11,
                color: context.ritu.textSecondary,
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            Divider(height: 1, thickness: 0.5, color: context.ritu.divider),
            const SizedBox(height: 12),
            Text(
              'Every small note you write brings meaningful insights',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                height: 18 / 11,
                color: context.ritu.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({
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
