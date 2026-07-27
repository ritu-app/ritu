import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../theme/ritu_colors.dart';

/// New-user empty state for the Insights tab.
class InsightsScreen extends StatelessWidget {
  const InsightsScreen({
    super.key,
    this.onLogToday,
  });

  final VoidCallback? onLogToday;

  static const _heroBackground = Color(0xFFEDF0EC);

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
        _HeroCard(onLogToday: onLogToday),
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
  const _HeroCard({this.onLogToday});

  final VoidCallback? onLogToday;

  @override
  Widget build(BuildContext context) {
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
            'Your journey is just beginning',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 24 / 18,
              color: RituColors.textPrimary,
            ),
          ),
          Text(
            'Once you start logging daily, Ritu will find patterns unique to your body',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 20 / 13,
              color: RituColors.textSecondary,
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
