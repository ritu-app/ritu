import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../theme/ritu_colors.dart';

/// Summary tab — empty state until the first daily log, then a progress
/// teaser toward summary unlock (Figma 411-844 / 411-1162).
class SummaryScreen extends StatelessWidget {
  const SummaryScreen({
    super.key,
    this.loggedDaysCount = 0,
    this.patternDaysRequired = 14,
  });

  /// Total calendar days with a saved daily log (drives empty vs progress UI).
  final int loggedDaysCount;
  final int patternDaysRequired;

  static const _heroBackground = Color(0xFFF5EFF6);
  static const _heroBorder = Color(0xFFE2DDD8);
  static const _progressColor = Color(0xFF9C8FB5);

  static const _valueItems = [
    (
      LucideIcons.stickyNote,
      RituColors.fillAttentionSecondary,
      RituColors.iconAttention,
      'Generate professional reports',
      'Export your health data in a clear format',
    ),
    (
      LucideIcons.stethoscope,
      RituColors.fillInfoSecondary,
      RituColors.iconInfo,
      'Share with healthcare professionals',
      'Support more informed health conversations',
    ),
    (
      LucideIcons.thumbsUp,
      RituColors.fillPositiveSecondary,
      RituColors.textPositive,
      'Make more informed decisions',
      'Use insights to support your well-being',
    ),
    (
      LucideIcons.squareLibrary,
      RituColors.fillCriticalSecondary,
      RituColors.iconCritical,
      'Keep everything in one place',
      'Access your health history whenever needed',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final hasStartedLogging = loggedDaysCount > 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text(
          'Summary',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 28,
            fontWeight: FontWeight.w400,
            height: 34 / 28,
            color: RituColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Export your health data',
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
        ),
        const SizedBox(height: 20),
        Text(
          'Why summary valuable',
          style: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            height: 24 / 15,
            color: RituColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < _valueItems.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          _ValueRow(
            icon: _valueItems[i].$1,
            iconBackground: _valueItems[i].$2,
            iconColor: _valueItems[i].$3,
            title: _valueItems[i].$4,
            subtitle: _valueItems[i].$5,
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
        color: SummaryScreen._heroBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SummaryScreen._heroBorder,
          width: 0.5,
        ),
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
              color: RituColors.textPrimary,
            ),
          ),
          Text(
            'Keep logging daily to unlock your personalised health summary',
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
                color: RituColors.textSecondary,
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            const Divider(
              height: 1,
              thickness: 0.5,
              color: RituColors.divider,
            ),
            const SizedBox(height: 12),
            Text(
              'Every small note you write brings meaningful insights',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                height: 18 / 11,
                color: RituColors.textTertiary,
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
