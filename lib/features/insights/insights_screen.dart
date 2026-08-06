import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../theme/ritu_colors.dart';

/// Insights tab — empty state until the first daily log, then a progress
/// teaser toward pattern unlock (Figma 385-1001).
class InsightsScreen extends StatelessWidget {
  const InsightsScreen({
    super.key,
    this.loggedDaysCount = 0,
    this.patternDaysRequired = 14,
    this.hasLoggedToday = false,
    this.onLogToday,
  });

  /// Total calendar days with a saved daily log (drives empty vs progress UI).
  final int loggedDaysCount;
  final int patternDaysRequired;

  /// When true, the hero CTA is hidden — logging is done for today.
  final bool hasLoggedToday;
  final VoidCallback? onLogToday;

  static const _heroBackground = Color(0xFFE7E9DE);

  static const _unlockItems = [
    (
      LucideIcons.trendingUp,
      RituColors.fillPositiveSecondary,
      RituColors.textPositive,
      'Energy trends',
      'See how your energy changes over time',
    ),
    (
      LucideIcons.audioLines,
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
      LucideIcons.notebookText,
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
        color: InsightsScreen._heroBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 116,
            height: 118,
            child: Image.asset(
              'assets/images/insights_journey.png',
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
