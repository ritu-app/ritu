import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ritu/theme/ritu_colors.dart';

import '../presets/journal_controls.dart';
import '../presets/logged_density.dart';
import '../theme/studio_styles.dart';
import 'studio_widgets.dart';

class LoggedDataSection extends StatelessWidget {
  const LoggedDataSection({
    super.key,
    required this.logDensity,
    required this.journalDensity,
    required this.loggedToday,
    required this.onLogDensity,
    required this.onJournalDensity,
    required this.onLoggedToday,
    required this.onRegenerate,
  });

  final DailyLogDensity logDensity;
  final JournalDensity journalDensity;
  final bool loggedToday;
  final ValueChanged<DailyLogDensity> onLogDensity;
  final ValueChanged<JournalDensity> onJournalDensity;
  final ValueChanged<bool> onLoggedToday;
  final VoidCallback onRegenerate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text('Logged today', style: StudioText.cardTitle)),
            StudioToggle(value: loggedToday, onChanged: onLoggedToday),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(height: 1, thickness: 1, color: RituColors.borderSubtle),
        const SizedBox(height: 16),
        Text('Daily log', style: StudioText.cardTitle),
        const SizedBox(height: 2),
        Text(
          'How many days across your logged history have a check-in recorded',
          style: StudioText.caption,
        ),
        const SizedBox(height: 8),
        StudioSegmentedControl<DailyLogDensity>(
          options: DailyLogDensity.values,
          selected: logDensity,
          labelOf: (option) => option.label,
          onChanged: onLogDensity,
        ),
        const SizedBox(height: 16),
        const Divider(height: 1, thickness: 1, color: RituColors.borderSubtle),
        const SizedBox(height: 16),
        Text('Journal entries', style: StudioText.cardTitle),
        const SizedBox(height: 2),
        Text(
          'How many days across your logged history have a journal entry',
          style: StudioText.caption,
        ),
        const SizedBox(height: 8),
        StudioSegmentedControl<JournalDensity>(
          options: JournalDensity.values,
          selected: journalDensity,
          labelOf: (option) => option.label,
          onChanged: onJournalDensity,
        ),
        const SizedBox(height: 16),
        const Divider(height: 1, thickness: 1, color: RituColors.borderSubtle),
        const SizedBox(height: 16),
        StudioPillButton(
          icon: LucideIcons.rotateCcwSquare,
          label: 'Regenerate',
          onPressed: onRegenerate,
        ),
        const SizedBox(height: 8),
        Text(
          'Same settings, a fresh data spread — see how Insights, Journal, and Summary change',
          textAlign: TextAlign.center,
          style: StudioText.hint,
        ),
      ],
    );
  }
}

String loggedJournalBody(
  JournalDensity density,
  int generation, {
  required bool includeToday,
}) {
  if (!includeToday) return '';
  return journalReflection(generation, 0);
}
