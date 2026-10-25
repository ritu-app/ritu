import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/cycle/cycle_classification.dart';
import '../../core/date_format.dart';
import '../../data/models/app_appearance.dart';
import '../../data/models/daily_reminder.dart';
import '../../providers/app_appearance_provider.dart';
import '../../providers/cycle_snapshot_provider.dart';
import '../../providers/daily_reminder_provider.dart';
import '../../providers/period_providers.dart';
import '../../providers/profile_providers.dart';
import '../../providers/repository_providers.dart';
import '../../providers/symptom_providers.dart';
import '../../theme/ritu_palette.dart';
import 'about_ritu_screen.dart';
import 'app_appearance_screen.dart';
import 'custom_symptoms_screen.dart';
import 'cycle_learning_screen.dart';
import 'daily_reminder_screen.dart';
import 'delete_data_screen.dart';
import 'edit_name_dialog.dart';
import 'export_data_screen.dart';
import 'help_support_screen.dart';
import 'period_history_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final pastAsync = ref.watch(pastPeriodStartsProvider);
    final symptomsAsync = ref.watch(customSymptomsProvider);

    return profileAsync.when(
      loading: () => Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: context.ritu.sage500),
        ),
      ),
      error: (error, _) => Scaffold(body: Center(child: Text('$error'))),
      data: (profile) {
        if (profile == null) {
          return const Scaffold(body: Center(child: Text('No profile found')));
        }

        final name = profile.displayName;
        final loggingSince = profile.onboardingCompletedAt!;
        final pastPeriodCount = pastAsync.valueOrNull?.length ?? 0;
        final customSymptomCount = symptomsAsync.valueOrNull?.length ?? 0;

        return _SettingsBody(
          name: name,
          loggingSince: loggingSince,
          pastPeriodCount: pastPeriodCount,
          customSymptomCount: customSymptomCount,
          onDeleteData: () => _openDeleteData(context),
        );
      },
    );
  }

  Future<void> _openDeleteData(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const DeleteDataScreen()),
    );
  }
}

class _SettingsBody extends ConsumerWidget {
  const _SettingsBody({
    required this.name,
    required this.loggingSince,
    required this.pastPeriodCount,
    required this.customSymptomCount,
    required this.onDeleteData,
  });

  final String name;
  final DateTime loggingSince;
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

  Future<void> _editPeriodHistory(BuildContext context) async {
    await Navigator.of(context).push<int>(
      MaterialPageRoute<int>(builder: (_) => const PeriodHistoryScreen()),
    );
  }

  Future<void> _openCycleLearning(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const CycleLearningScreen()),
    );
  }

  Future<void> _editCustomSymptoms(BuildContext context) async {
    await Navigator.of(context).push<int>(
      MaterialPageRoute<int>(builder: (_) => const CustomSymptomsScreen()),
    );
  }

  Future<void> _openExportData(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const ExportDataScreen()),
    );
  }

  Future<void> _openHelpSupport(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const HelpSupportScreen()),
    );
  }

  Future<void> _openAboutRitu(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const AboutRituScreen()),
    );
  }

  Future<void> _openWebPage(BuildContext context, Uri uri) async {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Couldn’t open the link')));
    }
  }

  Future<void> _openAppAppearance(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const AppAppearanceScreen()),
    );
  }

  Future<void> _openDailyReminder(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const DailyReminderScreen()),
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
    final classification = ref
        .watch(cycleSnapshotProvider)
        .valueOrNull
        ?.classification;
    final cycleLearningSubtitle = switch (classification) {
      CycleClassification.regular => 'Regular',
      CycleClassification.variable => 'Variable',
      CycleClassification.unpredictable => 'Unpredictable',
      _ => 'Unclassified – needs 3 cycles',
    };

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _popWithName(context);
      },
      child: Scaffold(
        backgroundColor: context.ritu.backgroundPage,
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
                          icon: LucideIcons.undo2,
                          iconBackground: context.ritu.fillPositiveSecondary,
                          iconColor: context.ritu.sage600,
                          title: 'Period History',
                          subtitle: _periodHistorySubtitle,
                          onTap: () => _editPeriodHistory(context),
                        ),
                        _SettingsRow(
                          icon: LucideIcons.clock,
                          iconBackground: context.ritu.fillPositiveSecondary,
                          iconColor: context.ritu.sage600,
                          title: 'Cycle Learning',
                          subtitle: cycleLearningSubtitle,
                          onTap: () => _openCycleLearning(context),
                        ),
                        _SettingsRow(
                          icon: LucideIcons.badgePlus,
                          iconBackground: context.ritu.fillPositiveSecondary,
                          iconColor: context.ritu.sage600,
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
                          iconBackground: context.ritu.fillAttentionSecondary,
                          iconColor: context.ritu.iconAttention,
                          title: 'Daily Reminder',
                          subtitle: reminderSubtitle,
                          showDivider: false,
                          onTap: () => _openDailyReminder(context),
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
                          iconBackground: context.ritu.fillPositiveSecondary,
                          iconColor: context.ritu.sage600,
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
                        _SettingsRow(
                          icon: LucideIcons.stickyNoteCheck,
                          iconBackground: context.ritu.fillPositiveSecondary,
                          iconColor: context.ritu.sage600,
                          title: 'Export Data',
                          subtitle: 'Download a complete copy of everything',
                          onTap: () => _openExportData(context),
                        ),
                        _SettingsRow(
                          icon: LucideIcons.trash2,
                          iconBackground: context.ritu.fillCriticalSecondary,
                          iconColor: context.ritu.iconCritical,
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
                          iconBackground: context.ritu.fillInfoSecondary,
                          iconColor: context.ritu.iconInfo,
                          title: 'Help & Support',
                          onTap: () => _openHelpSupport(context),
                        ),
                        _SettingsRow(
                          icon: LucideIcons.lockKeyhole,
                          iconBackground: context.ritu.fillInfoSecondary,
                          iconColor: context.ritu.iconInfo,
                          title: 'Privacy Policy',
                          onTap: () => _openWebPage(
                            context,
                            Uri.parse('https://www.ritu.care/privacy'),
                          ),
                        ),
                        _SettingsRow(
                          icon: LucideIcons.receiptText,
                          iconBackground: context.ritu.fillInfoSecondary,
                          iconColor: context.ritu.iconInfo,
                          title: 'Terms of Service',
                          onTap: () => _openWebPage(
                            context,
                            Uri.parse('https://www.ritu.care/terms'),
                          ),
                        ),
                        _SettingsRow(
                          icon: LucideIcons.info,
                          iconBackground: context.ritu.fillInfoSecondary,
                          iconColor: context.ritu.iconInfo,
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
            icon: Icon(
              LucideIcons.chevronLeft,
              size: 28,
              color: context.ritu.textPrimary,
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
                color: context.ritu.textPrimary,
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
      color: context.ritu.fillElevated,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onNameTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.ritu.borderSubtle),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment(-0.7, -0.5),
                    end: Alignment(0.8, 0.8),
                    colors: [
                      context.ritu.gradientVb1,
                      context.ritu.gradientVb2,
                      context.ritu.gradientVb3,
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
                    color: context.ritu.textInverse,
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
                        color: context.ritu.textPrimary,
                      ),
                    ),
                    Text(
                      'Logging since $loggingSinceLabel',
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
        color: context.ritu.textDisabled,
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
        color: context.ritu.fillElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.ritu.borderSubtle),
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
                          color: context.ritu.textPrimary,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
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
                Icon(
                  LucideIcons.chevronRight,
                  size: 16,
                  color: context.ritu.textDisabled,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(height: 1, thickness: 0.5, color: context.ritu.borderSubtle),
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
            color: context.ritu.sage600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Version 1.0.0',
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            height: 18 / 11,
            color: context.ritu.textTertiary,
          ),
        ),
      ],
    );
  }
}
