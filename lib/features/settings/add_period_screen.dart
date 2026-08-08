import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/date_format.dart';
import '../../providers/period_providers.dart';
import '../../providers/profile_providers.dart';
import '../../providers/repository_providers.dart';
import '../../theme/ritu_colors.dart';
import '../setup/last_period_screen.dart';
import '../setup/widgets/choice_chips.dart';
import '../setup/widgets/ritu_calendar.dart';

/// Figma 921:3299 / 922:4152 — Period History → Add a period (manual backfill).
class AddPeriodScreen extends ConsumerStatefulWidget {
  const AddPeriodScreen({super.key});

  @override
  ConsumerState<AddPeriodScreen> createState() => _AddPeriodScreenState();
}

class _AddPeriodScreenState extends ConsumerState<AddPeriodScreen> {
  late DateTime _visibleMonth;
  DateTime? _selectedDate;
  PeriodDuration? _duration;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
  }

  String _durationLabel(PeriodDuration option) => switch (option) {
        PeriodDuration.twoToThree => '2-3 days',
        PeriodDuration.fourToFive => '4-5 days',
        PeriodDuration.sixToSeven => '6-7 days',
        PeriodDuration.varies => 'Not sure',
      };

  Future<void> _save() async {
    final selected = _selectedDate;
    if (selected == null || _saving) return;

    setState(() => _saving = true);
    try {
      final typical =
          _duration?.typicalDays ??
          ref.read(profileProvider).valueOrNull?.typicalPeriodDays;
      final created = await ref.read(periodRepositoryProvider).addPastStart(
            startedOn: selected,
            typicalPeriodDays: typical,
          );
      if (!mounted) return;
      if (created == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Pick a date before your most recent period start',
            ),
          ),
        );
        return;
      }
      Navigator.of(context).pop(created.startedOn);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final periods = ref.watch(allPeriodsProvider).valueOrNull ?? const [];
    final existingStarts = {
      for (final log in periods) dateOnly(log.startedOn),
    };
    final latest = ref.watch(latestPeriodProvider).valueOrNull;
    final maxSelectable = latest == null
        ? dateOnly(DateTime.now())
        : dateOnly(latest.startedOn).subtract(const Duration(days: 1));

    final canSave = !_saving &&
        _selectedDate != null &&
        !existingStarts.contains(dateOnly(_selectedDate!));

    return Scaffold(
      backgroundColor: RituColors.backgroundPage,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: _saving ? null : () => Navigator.of(context).pop(),
                  behavior: HitTestBehavior.opaque,
                  child: const SizedBox(
                    width: 24,
                    height: 24,
                    child: Icon(
                      LucideIcons.chevronLeft,
                      size: 24,
                      color: RituColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  Text(
                    'Add a period',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 24 / 18,
                      color: RituColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Existing entries are marked so you don’t duplicate one',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      height: 20 / 13,
                      color: RituColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  RituCalendar(
                    month: _visibleMonth,
                    selectedDate: _selectedDate,
                    entryDates: existingStarts,
                    maxSelectableDate: maxSelectable,
                    onMonthChanged: (month) {
                      setState(() => _visibleMonth = month);
                    },
                    onDateSelected: (date) {
                      if (existingStarts.contains(dateOnly(date))) return;
                      setState(() => _selectedDate = date);
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'And roughly how many days did it last?',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 24 / 18,
                      color: RituColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final option in PeriodDuration.values)
                        RituChoiceChip(
                          label: _durationLabel(option),
                          selected: _duration == option,
                          onTap: () => setState(() => _duration = option),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: canSave ? _save : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: RituColors.sage500,
                        disabledBackgroundColor:
                            RituColors.sage500.withValues(alpha: 0.4),
                        foregroundColor: RituColors.white,
                        disabledForegroundColor: RituColors.white,
                        elevation: 0,
                        shape: const StadiumBorder(),
                        textStyle: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 24 / 15,
                        ),
                      ),
                      child: Text(_saving ? 'Saving…' : 'Save period'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'For a period you didn’t log in real time – not a '
                    'replacement for your daily check-in',
                    textAlign: TextAlign.center,
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
    );
  }
}
