import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/app_scope.dart';
import '../../theme/ritu_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.name,
    this.loggingSinceLabel = 'June 17, 2026',
    this.periodStartedLabel = 'June 17, 2026',
  });

  final String name;
  final String loggingSinceLabel;
  final String periodStartedLabel;

  String get _initial {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.substring(0, 1).toUpperCase();
  }

  Future<void> _confirmAndDeleteData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: RituColors.fillElevated,
          title: Text(
            'Delete all data?',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: RituColors.textPrimary,
            ),
          ),
          content: Text(
            'This permanently removes your profile and all local data on this device. You can’t undo this.',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 20 / 14,
              color: RituColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Cancel',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w600,
                  color: RituColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                'Delete',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w600,
                  color: RituColors.iconCritical,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    final scope = AppScope.of(context);
    await scope.profileRepository.clearAllData();
    if (!context.mounted) return;
    scope.restartApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RituColors.backgroundPage,
      body: SafeArea(
        child: Column(
          children: [
            _SettingsAppBar(
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  _ProfileCard(
                    initial: _initial,
                    name: name,
                    loggingSinceLabel: loggingSinceLabel,
                  ),
                  const SizedBox(height: 20),
                  const _SectionLabel('Cycle & Tracking'),
                  const SizedBox(height: 8),
                  _SettingsGroup(
                    children: [
                      _SettingsRow(
                        icon: Icons.calendar_today_outlined,
                        iconBackground: RituColors.fillPositiveSecondary,
                        iconColor: RituColors.sage600,
                        title: 'Period Started',
                        subtitle: periodStartedLabel,
                      ),
                      _SettingsRow(
                        icon: Icons.history,
                        iconBackground: RituColors.fillPositiveSecondary,
                        iconColor: RituColors.sage600,
                        title: 'Period History',
                        subtitle: 'No dates added',
                      ),
                      _SettingsRow(
                        icon: Icons.schedule_outlined,
                        iconBackground: RituColors.fillPositiveSecondary,
                        iconColor: RituColors.sage600,
                        title: 'Cycle Learning',
                        subtitle: 'Unclassified – needs 3 cycles',
                      ),
                      _SettingsRow(
                        icon: Icons.add_circle_outline,
                        iconBackground: RituColors.fillPositiveSecondary,
                        iconColor: RituColors.sage600,
                        title: 'Custom Symptoms',
                        subtitle: 'Add your own symptoms to track',
                        showDivider: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const _SectionLabel('Reminder & Notifications'),
                  const SizedBox(height: 8),
                  const _SettingsGroup(
                    children: [
                      _SettingsRow(
                        icon: Icons.notifications_none_rounded,
                        iconBackground: RituColors.fillAttentionSecondary,
                        iconColor: RituColors.iconAttention,
                        title: 'Daily Reminder',
                        subtitle: '8:00 AM',
                      ),
                      _SettingsRow(
                        icon: Icons.auto_awesome,
                        iconBackground: RituColors.fillAttentionSecondary,
                        iconColor: RituColors.iconAttention,
                        title: 'Insight Alerts',
                        subtitle: 'When Ritu spots something new',
                      ),
                      _SettingsRow(
                        icon: Icons.nightlight_round,
                        iconBackground: RituColors.fillAttentionSecondary,
                        iconColor: RituColors.iconAttention,
                        title: 'Period Reminder',
                        subtitle: 'A gentle nudge before your period',
                        showDivider: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const _SectionLabel('Data & Privacy'),
                  const SizedBox(height: 8),
                  _SettingsGroup(
                    children: [
                      const _SettingsRow(
                        icon: Icons.cloud_upload_outlined,
                        iconBackground: RituColors.fillInfoSecondary,
                        iconColor: RituColors.iconInfo,
                        title: 'iCloud Backup',
                        subtitle: 'Off',
                      ),
                      const _SettingsRow(
                        icon: Icons.ios_share_outlined,
                        iconBackground: RituColors.fillPositiveSecondary,
                        iconColor: RituColors.sage600,
                        title: 'Export Data',
                        subtitle: 'Download a complete copy of everything',
                      ),
                      const _SettingsRow(
                        icon: Icons.bar_chart_rounded,
                        iconBackground: RituColors.fillAttentionSecondary,
                        iconColor: RituColors.iconAttention,
                        title: 'Usage Analytics',
                        subtitle: 'Helps improve Ritu – no personal data',
                      ),
                      _SettingsRow(
                        icon: Icons.delete_outline,
                        iconBackground: RituColors.fillCriticalSecondary,
                        iconColor: RituColors.iconCritical,
                        title: 'Delete Data',
                        subtitle: 'Permanently removes everything',
                        showDivider: false,
                        onTap: () => _confirmAndDeleteData(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const _SectionLabel('Support & About'),
                  const SizedBox(height: 8),
                  const _SettingsGroup(
                    children: [
                      _SettingsRow(
                        icon: Icons.help_outline,
                        iconBackground: RituColors.fillInfoSecondary,
                        iconColor: RituColors.iconInfo,
                        title: 'Help & Support',
                      ),
                      _SettingsRow(
                        icon: Icons.lock_outline,
                        iconBackground: RituColors.fillInfoSecondary,
                        iconColor: RituColors.iconInfo,
                        title: 'Privacy Policy',
                      ),
                      _SettingsRow(
                        icon: Icons.description_outlined,
                        iconBackground: RituColors.fillInfoSecondary,
                        iconColor: RituColors.iconInfo,
                        title: 'Terms of Service',
                      ),
                      _SettingsRow(
                        icon: Icons.info_outline,
                        iconBackground: RituColors.fillInfoSecondary,
                        iconColor: RituColors.iconInfo,
                        title: 'About Ritu',
                        showDivider: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const _Footer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsAppBar extends StatelessWidget {
  const _SettingsAppBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.chevron_left,
              size: 28,
              color: RituColors.textPrimary,
            ),
          ),
          Expanded(
            child: Text(
              'Settings',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                height: 25 / 18,
                color: RituColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.initial,
    required this.name,
    required this.loggingSinceLabel,
  });

  final String initial;
  final String name;
  final String loggingSinceLabel;

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
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment(-0.7, -0.5),
                end: Alignment(0.8, 0.8),
                colors: [
                  RituColors.gradientVb1,
                  RituColors.gradientVb2,
                  RituColors.gradientVb3,
                ],
                stops: [0.14, 0.59, 0.95],
              ),
            ),
            child: Text(
              initial,
              style: GoogleFonts.dmSans(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                height: 26 / 22,
                color: RituColors.textInverse,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 24 / 18,
                    color: RituColors.textPrimary,
                  ),
                ),
                Text(
                  'Logging since $loggingSinceLabel',
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 20 / 13,
        color: RituColors.textDisabled,
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

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
      child: Column(children: children),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.showDivider = true,
    this.onTap,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final bool showDivider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
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
                      if (subtitle != null)
                        Text(
                          subtitle!,
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
                const Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: RituColors.textDisabled,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 0.5,
            color: RituColors.borderSubtle,
          ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Ritu',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 28,
            fontWeight: FontWeight.w400,
            color: RituColors.sage600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Version 1.0.0',
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            height: 18 / 11,
            color: RituColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
