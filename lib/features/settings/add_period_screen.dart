import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/date_format.dart';
import '../../data/repositories/period_repository.dart';
import '../../providers/period_providers.dart';
import '../../providers/profile_providers.dart';
import '../../providers/repository_providers.dart';
import '../../theme/ritu_colors.dart';
import '../setup/last_period_screen.dart';
import '../setup/widgets/choice_chips.dart';
import '../setup/widgets/ritu_calendar.dart';

/// Figma 921:3299 / 922:4152 — Period History → Add / edit a period.
class AddPeriodScreen extends ConsumerStatefulWidget {
  const AddPeriodScreen({super.key, this.editing});

  /// When set, opens in edit mode for this episode (calendar scoped to it).
  final PeriodLog? editing;

  @override
  ConsumerState<AddPeriodScreen> createState() => _AddPeriodScreenState();
}

class _AddPeriodScreenState extends ConsumerState<AddPeriodScreen> {
  late DateTime _visibleMonth;
  DateTime? _selectedDate;
  PeriodDuration? _duration;
  var _saving = false;

  bool get _isEditing => widget.editing != null;

  @override
  void initState() {
    super.initState();
    final editing = widget.editing;
    if (editing != null) {
      final start = dateOnly(editing.startedOn);
      _selectedDate = start;
      _visibleMonth = DateTime(start.year, start.month);
      _duration = _durationFromLog(editing);
      return;
    }

    // Land on a month that still has selectable days (before the latest
    // period). Current month is often fully disabled for backfill.
    final latest = ref.read(latestPeriodProvider).valueOrNull;
    final maxSelectable = latest == null
        ? dateOnly(DateTime.now())
        : dateOnly(latest.startedOn).subtract(const Duration(days: 1));
    _visibleMonth = DateTime(maxSelectable.year, maxSelectable.month);
  }

  PeriodDuration? _durationFromLog(PeriodLog log) {
    final end = log.endedOn;
    if (end == null) return PeriodDuration.varies;
    final days =
        dateOnly(end).difference(dateOnly(log.startedOn)).inDays + 1;
    if (days <= 3) return PeriodDuration.twoToThree;
    if (days <= 5) return PeriodDuration.fourToFive;
    if (days <= 7) return PeriodDuration.sixToSeven;
    return PeriodDuration.varies;
  }

  String _durationLabel(PeriodDuration option) => switch (option) {
        PeriodDuration.twoToThree => '2-3 days',
        PeriodDuration.fourToFive => '4-5 days',
        PeriodDuration.sixToSeven => '6-7 days',
        PeriodDuration.varies => 'Not sure',
      };

  /// Days after the selected start covered by the chosen length (start itself
  /// stays as the selected day on the calendar).
  Set<DateTime> get _durationSpanDates {
    final start = _selectedDate;
    final typical = _duration?.typicalDays;
    if (start == null || typical == null || typical < 2) return const {};

    final end = PeriodRepository.estimateEnd(dateOnly(start), typical);
    if (end == null) return const {};

    final days = <DateTime>{};
    var cursor = dateOnly(start).add(const Duration(days: 1));
    while (!cursor.isAfter(end)) {
      days.add(cursor);
      cursor = cursor.add(const Duration(days: 1));
    }
    return days;
  }

  Future<void> _save() async {
    final selected = _selectedDate;
    if (selected == null || _saving) return;

    setState(() => _saving = true);
    try {
      final typical =
          _duration?.typicalDays ??
          ref.read(profileProvider).valueOrNull?.typicalPeriodDays;
      final repo = ref.read(periodRepositoryProvider);
      final editing = widget.editing;

      if (editing != null) {
        final oldStart = dateOnly(editing.startedOn);
        final newStart = dateOnly(selected);
        if (oldStart != newStart) {
          await repo.deleteByStartedOn(oldStart);
        }
        await repo.upsertPeriod(
          startedOn: newStart,
          endedOn: PeriodRepository.estimateEnd(newStart, typical),
          source: editing.source,
        );
        if (!mounted) return;
        Navigator.of(context).pop(newStart);
        return;
      }

      final created = await repo.addPastStart(
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

  Future<void> _delete() async {
    final editing = widget.editing;
    if (editing == null || _saving) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete this period?',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'This removes ${formatMonthDay(editing.startedOn)} from your history.',
          style: GoogleFonts.dmSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Delete',
              style: GoogleFonts.dmSans(color: RituColors.iconCritical),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _saving = true);
    try {
      await ref
          .read(periodRepositoryProvider)
          .deleteByStartedOn(editing.startedOn);
      if (!mounted) return;
      Navigator.of(context).pop(editing.startedOn);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final periods = ref.watch(allPeriodsProvider).valueOrNull ?? const [];
    final editing = widget.editing;
    final editingStart =
        editing == null ? null : dateOnly(editing.startedOn);

    // Periods sorted newest-first (same as allPeriodsProvider).
    final editingIndex = editingStart == null
        ? -1
        : periods.indexWhere(
            (p) => dateOnly(p.startedOn) == editingStart,
          );

    final DateTime? minSelectable;
    final DateTime maxSelectable;
    if (editingIndex >= 0) {
      // Must stay after the next-older start (list is newest-first).
      final older = editingIndex + 1 < periods.length
          ? dateOnly(periods[editingIndex + 1].startedOn)
          : null;
      minSelectable = older?.add(const Duration(days: 1));

      // And before the next-newer start (or today when editing the latest).
      if (editingIndex == 0) {
        maxSelectable = dateOnly(DateTime.now());
      } else {
        maxSelectable = dateOnly(periods[editingIndex - 1].startedOn)
            .subtract(const Duration(days: 1));
      }
    } else {
      minSelectable = null;
      final latest = ref.watch(latestPeriodProvider).valueOrNull;
      maxSelectable = latest == null
          ? dateOnly(DateTime.now())
          : dateOnly(latest.startedOn).subtract(const Duration(days: 1));
    }

    final blockedStarts = {
      for (final log in periods)
        if (editingStart == null || dateOnly(log.startedOn) != editingStart)
          dateOnly(log.startedOn),
    };
    // Drop the episode being edited, then overlay the chip-selected length so
    // the calendar updates as the user tries different duration options.
    final periodDates = {
      for (final log in periods)
        if (editingStart == null || dateOnly(log.startedOn) != editingStart)
          ...log.bleedDays,
      ..._durationSpanDates,
    };

    final selected = _selectedDate == null ? null : dateOnly(_selectedDate!);
    final canSave = !_saving &&
        selected != null &&
        !blockedStarts.contains(selected) &&
        !selected.isAfter(maxSelectable) &&
        (minSelectable == null || !selected.isBefore(minSelectable));

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
                    _isEditing ? 'Edit period' : 'Add a period',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 24 / 18,
                      color: RituColors.textPrimary,
                    ),
                  ),
                  Text(
                    _isEditing
                        ? 'Update the start date or length, or remove it'
                        : 'Existing entries are marked so you don’t duplicate one',
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
                    periodDates: periodDates,
                    minSelectableDate: minSelectable,
                    maxSelectableDate: maxSelectable,
                    monthNavigationEnabled: !_isEditing,
                    onMonthChanged: (month) {
                      setState(() => _visibleMonth = month);
                    },
                    onDateSelected: (date) {
                      if (blockedStarts.contains(dateOnly(date))) return;
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
                      child: Text(
                        _saving
                            ? 'Saving…'
                            : _isEditing
                                ? 'Save changes'
                                : 'Save period',
                      ),
                    ),
                  ),
                  if (_isEditing) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: TextButton(
                        onPressed: _saving ? null : _delete,
                        style: TextButton.styleFrom(
                          foregroundColor: RituColors.iconCritical,
                          shape: const StadiumBorder(),
                          textStyle: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            height: 24 / 15,
                          ),
                        ),
                        child: const Text('Delete period'),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    _isEditing
                        ? 'Changes update your cycle history on this device only'
                        : 'For a period you didn’t log in real time – not a '
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
