import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/models/app_appearance.dart';
import '../../data/models/daily_reminder.dart';
import '../../providers/app_appearance_provider.dart';
import '../../providers/daily_reminder_provider.dart';
import '../../providers/period_providers.dart';
import '../../providers/profile_providers.dart';
import '../../providers/repository_providers.dart';
import '../../providers/symptom_providers.dart';
import '../../core/date_format.dart';
import '../../theme/ritu_colors.dart';
import 'about_ritu_screen.dart';
import 'app_appearance_screen.dart';
import 'custom_symptoms_screen.dart';
import 'daily_reminder_screen.dart';
import 'delete_data_screen.dart';
import 'edit_name_dialog.dart';
import 'export_data_screen.dart';
import 'help_support_screen.dart';
import 'period_history_screen.dart';
import 'period_started_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final latestAsync = ref.watch(latestPeriodProvider);
    final pastAsync = ref.watch(pastPeriodStartsProvider);
    final symptomsAsync = ref.watch(customSymptomsProvider);

    return profileAsync.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: RituColors.sage500),
        ),
      ),
      error: (error, _) => Scaffold(body: Center(child: Text('$error'))),
      data: (profile) {
        if (profile == null) {
          return const Scaffold(
            body: Center(child: Text('No profile found')),
          );
        }

        final name = profile.displayName;
        final loggingSince = profile.onboardingCompletedAt!;
        final periodStartedLabel = latestAsync.valueOrNull == null
            ? null
            : formatDisplayDate(latestAsync.valueOrNull!.startedOn);
        final pastPeriodCount = pastAsync.valueOrNull?.length ?? 0;
        final customSymptomCount = symptomsAsync.valueOrNull?.length ?? 0;

        return _SettingsBody(
          name: name,
          loggingSince: loggingSince,
          periodStartedLabel: periodStartedLabel,
          pastPeriodCount: pastPeriodCount,
          customSymptomCount: customSymptomCount,
          onDeleteData: () => _openDeleteData(context),
        );
      },
    );
  }

  Future<void> _openDeleteData(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const DeleteDataScreen(),
      ),
    );
  }
}

class _SettingsBody extends ConsumerWidget {
  const _SettingsBody({
    required this.name,
    required this.loggingSince,
    required this.periodStartedLabel,
    required this.pastPeriodCount,
    required this.customSymptomCount,
    required this.onDeleteData,
  });

  final String name;
  final DateTime loggingSince;
  final String? periodStartedLabel;
  final int pastPeriodCount;
  final int customSymptomCount;
  final VoidCallback onDeleteData;

  String get _initial {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.substring(0, 1).toUpperCase();
  }

  String get _loggingSinceLabel => formatDisplayDate(loggingSince);

  String get _periodHistorySubtitle =>
      pastPeriodCount == 0 ? 'No dates added' : 'View and edit past dates';

  String get _customSymptomsSubtitle => customSymptomCount == 0
      ? 'Add your own symptoms to track'
      : '$customSymptomCount added';

  void _popWithName(BuildContext context) {
    Navigator.of(context).pop(name);
  }

  Future<void> _editName(BuildContext context, WidgetRef ref) async {
    final updated = await showEditNameDialog(context, currentName: name);
    if (updated == null || !context.mounted) return;
    if (updated == name) return;
    await ref.read(profileRepositoryProvider).upsertDisplayName(updated);
  }

  Future<void> _editPeriodStarted(BuildContext context) async {
    await Navigator.of(context).push<DateTime>(
      MaterialPageRoute<DateTime>(
        builder: (_) => const PeriodStartedScreen(),
      ),
    );
  }

  Future<void> _editPeriodHistory(BuildContext context) async {
    await Navigator.of(context).push<int>(
      MaterialPageRoute<int>(
        builder: (_) => const PeriodHistoryScreen(),
      ),
    );
  }

  Future<void> _editCustomSymptoms(BuildContext context) async {
    await Navigator.of(context).push<int>(
      MaterialPageRoute<int>(
        builder: (_) => const CustomSymptomsScreen(),
      ),
    );
  }

  Future<void> _openExportData(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const ExportDataScreen(),
      ),
    );
  }

  Future<void> _openHelpSupport(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const HelpSupportScreen(),
      ),
    );
  }

  Future<void> _openAboutRitu(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const AboutRituScreen(),
      ),
    );
  }

  Future<void> _openAppAppearance(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const AppAppearanceScreen(),
      ),
    );
  }

  Future<void> _openDailyReminder(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const DailyReminderScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearanceLabel =
        ref.watch(appAppearanceProvider).valueOrNull?.label ??
            AppAppearance.system.label;
    final reminderSubtitle =
        ref.watch(dailyReminderProvider).valueOrNull?.settingsSubtitle ??
            DailyReminder.defaults.settingsSubtitle;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _popWithName(context);
      },
      child: Scaffold(
        backgroundColor: RituColors.backgroundPage,
        body: SafeArea(
          child: Column(
            children: [
              _SettingsAppBar(onBack: () => _popWithName(context)),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  children: [
                    _ProfileCard(
                      initial: _initial,
                      name: name,
                      loggingSinceLabel: _loggingSinceLabel,
                      onNameTap: () => _editName(context, ref),
                    ),
                    const SizedBox(height: 20),
                    const _SectionLabel('Cycle & Tracking'),
                    const SizedBox(height: 8),
                    _SettingsGroup(
                      children: [
                        _SettingsRow(
                          icon: LucideIcons.calendar1,
                          iconBackground: RituColors.fillPositiveSecondary,
                          iconColor: RituColors.sage600,
                          title: 'Period Started',
                          subtitle: periodStartedLabel ?? 'Not set',
                          onTap: () => _editPeriodStarted(context),
                        ),
                        _SettingsRow(
                          icon: LucideIcons.undo2,
                          iconBackground: RituColors.fillPositiveSecondary,
                          iconColor: RituColors.sage600,
                          title: 'Period History',
                          subtitle: _periodHistorySubtitle,
                          onTap: () => _editPeriodHistory(context),
                        ),
                        _SettingsRow(
                          icon: LucideIcons.clock,
                          iconBackground: RituColors.fillPositiveSecondary,
                          iconColor: RituColors.sage600,
                          title: 'Cycle Learning',
                          subtitle: 'Unclassified – needs 3 cycles',
                        ),
                        _SettingsRow(
                          icon: LucideIcons.badgePlus,
                          iconBackground: RituColors.fillPositiveSecondary,
                          iconColor: RituColors.sage600,
                          title: 'Custom Symptoms',
                          subtitle: _customSymptomsSubtitle,
                          showDivider: false,
                          onTap: () => _editCustomSymptoms(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const _SectionLabel('Reminder & Notifications'),
                    const SizedBox(height: 8),
                    _SettingsGroup(
                      children: [
                        _SettingsRow(
                          icon: LucideIcons.bell,
                          iconBackground: RituColors.fillAttentionSecondary,
                          iconColor: RituColors.iconAttention,
                          title: 'Daily Reminder',
                          subtitle: reminderSubtitle,
                          onTap: () => _openDailyReminder(context),
                        ),
                        const _SettingsRow(
                          icon: LucideIcons.sparkles,
                          iconBackground: RituColors.fillAttentionSecondary,
                          iconColor: RituColors.iconAttention,
                          title: 'Insight Alerts',
                          subtitle: 'When Ritu spots something new',
                        ),
                        const _SettingsRow(
                          icon: LucideIcons.moon,
                          iconBackground: RituColors.fillAttentionSecondary,
                          iconColor: RituColors.iconAttention,
                          title: 'Period Reminder',
                          subtitle: 'A gentle nudge before your period',
                          showDivider: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const _SectionLabel('App Preferences'),
                    const SizedBox(height: 8),
                    _SettingsGroup(
                      children: [
                        _SettingsRow(
                          icon: LucideIcons.sunMoon,
                          iconBackground: RituColors.fillPositiveSecondary,
                          iconColor: RituColors.sage600,
                          title: 'App Appearance',
                          subtitle: appearanceLabel,
                          showDivider: false,
                          onTap: () => _openAppAppearance(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const _SectionLabel('Data & Privacy'),
                    const SizedBox(height: 8),
                    _SettingsGroup(
                      children: [
                        const _SettingsRow(
                          icon: LucideIcons.cloudUpload,
                          iconBackground: RituColors.fillInfoSecondary,
                          iconColor: RituColors.iconInfo,
                          title: 'iCloud Backup',
                          subtitle: 'Off',
                        ),
                        _SettingsRow(
                          icon: LucideIcons.stickyNoteCheck,
                          iconBackground: RituColors.fillPositiveSecondary,
                          iconColor: RituColors.sage600,
                          title: 'Export Data',
                          subtitle: 'Download a complete copy of everything',
                          onTap: () => _openExportData(context),
                        ),
                        const _SettingsRow(
                          icon: LucideIcons.chartNoAxesCombined,
                          iconBackground: RituColors.fillAttentionSecondary,
                          iconColor: RituColors.iconAttention,
                          title: 'Usage Analytics',
                          subtitle: 'Helps improve Ritu – no personal data',
                        ),
                        _SettingsRow(
                          icon: LucideIcons.trash2,
                          iconBackground: RituColors.fillCriticalSecondary,
                          iconColor: RituColors.iconCritical,
                          title: 'Delete Data',
                          subtitle: 'Permanently removes everything',
                          showDivider: false,
                          onTap: onDeleteData,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const _SectionLabel('Support & About'),
                    const SizedBox(height: 8),
                    _SettingsGroup(
                      children: [
                        _SettingsRow(
                          icon: LucideIcons.circleQuestionMark,
                          iconBackground: RituColors.fillInfoSecondary,
                          iconColor: RituColors.iconInfo,
                          title: 'Help & Support',
                          onTap: () => _openHelpSupport(context),
                        ),
                        const _SettingsRow(
                          icon: LucideIcons.lockKeyhole,
                          iconBackground: RituColors.fillInfoSecondary,
                          iconColor: RituColors.iconInfo,
                          title: 'Privacy Policy',
                        ),
                        const _SettingsRow(
                          icon: LucideIcons.receiptText,
                          iconBackground: RituColors.fillInfoSecondary,
                          iconColor: RituColors.iconInfo,
                          title: 'Terms of Service',
                        ),
                        _SettingsRow(
                          icon: LucideIcons.info,
                          iconBackground: RituColors.fillInfoSecondary,
                          iconColor: RituColors.iconInfo,
                          title: 'About Ritu',
                          showDivider: false,
                          onTap: () => _openAboutRitu(context),
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
              LucideIcons.chevronLeft,
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
    required this.onNameTap,
  });

  final String initial;
  final String name;
  final String loggingSinceLabel;
  final VoidCallback onNameTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: RituColors.fillElevated,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onNameTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: RituColors.borderSubtle),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
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
        ),
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
                  LucideIcons.chevronRight,
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
