import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/date_format.dart';
import '../../data/repositories/period_repository.dart';
import '../../providers/period_providers.dart';
import '../../providers/repository_providers.dart';
import '../../theme/ritu_palette.dart';
import '../setup/widgets/period_episode_form_fields.dart';
import '../setup/widgets/ritu_calendar.dart';

/// Figma 1132:5047 — Period History → Add / edit a period.
class AddPeriodScreen extends ConsumerStatefulWidget {
  const AddPeriodScreen({super.key, this.editing});

  /// When set, opens in edit mode for this episode (calendar scoped to it).
  final PeriodLog? editing;

  @override
  ConsumerState<AddPeriodScreen> createState() => _AddPeriodScreenState();
}

class _AddPeriodScreenState extends ConsumerState<AddPeriodScreen> {
  late DateTime _visibleMonth;
  DateTime? _selectedStart;
  PeriodOngoingStatus? _ongoingStatus;
  EndConfidenceChoice? _endConfidence;
  DateTime? _selectedEndDate;
  String? _roughDurationBucket;
  var _saving = false;

  bool get _isEditing => widget.editing != null;

  @override
  void initState() {
    super.initState();
    final editing = widget.editing;
    if (editing != null) {
      final start = dateOnly(editing.startedOn);
      _selectedStart = start;
      _visibleMonth = DateTime(start.year, start.month);
      _hydrateFromLog(editing);
      return;
    }

    final latest = ref.read(latestPeriodProvider).valueOrNull;
    final maxSelectable = latest == null
        ? dateOnly(DateTime.now())
        : dateOnly(latest.startedOn).subtract(const Duration(days: 1));
    _visibleMonth = DateTime(maxSelectable.year, maxSelectable.month);
  }

  void _hydrateFromLog(PeriodLog log) {
    if (log.isOpen) {
      _ongoingStatus = PeriodOngoingStatus.stillGoing;
      return;
    }

    _ongoingStatus = PeriodOngoingStatus.ended;
    if (log.hasConfirmedEnd) {
      _endConfidence = EndConfidenceChoice.exact;
      _selectedEndDate = log.endedOn == null ? null : dateOnly(log.endedOn!);
      return;
    }

    _endConfidence = EndConfidenceChoice.rough;
    _roughDurationBucket =
        log.roughDurationBucket ??
        (log.endedOn == null
            ? null
            : RoughDurationBuckets.fromInclusiveDayCount(
                dateOnly(
                      log.endedOn!,
                    ).difference(dateOnly(log.startedOn)).inDays +
                    1,
              ));
  }

  void _onStartSelected(DateTime date) {
    final start = dateOnly(date);
    setState(() {
      _selectedStart = start;
      if (_selectedEndDate != null && _selectedEndDate!.isBefore(start)) {
        _selectedEndDate = null;
      }
    });
  }

  Future<void> _save() async {
    final start = _selectedStart;
    final status = _ongoingStatus;
    if (start == null || status == null || _saving) return;

    setState(() => _saving = true);
    try {
      final repo = ref.read(periodRepositoryProvider);
      final editing = widget.editing;
      final startOnly = dateOnly(start);

      if (editing != null) {
        final oldStart = dateOnly(editing.startedOn);
        if (oldStart != startOnly) {
          await repo.deleteByStartedOn(oldStart);
        }
        await _persistEpisode(repo, startOnly);
        if (!mounted) return;
        Navigator.of(context).pop(startOnly);
        return;
      }

      final latest = await repo.getLatest();
      if (latest != null && !startOnly.isBefore(dateOnly(latest.startedOn))) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pick a date before your most recent period start'),
          ),
        );
        return;
      }

      await _persistEpisode(repo, startOnly);
      if (!mounted) return;
      Navigator.of(context).pop(startOnly);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _persistEpisode(PeriodRepository repo, DateTime start) async {
    switch (_ongoingStatus!) {
      case PeriodOngoingStatus.stillGoing:
        await repo.saveOngoingManualPeriod(startedOn: start);
      case PeriodOngoingStatus.ended:
        switch (_endConfidence) {
          case EndConfidenceChoice.exact:
            await repo.saveExactEndedManualPeriod(
              startedOn: start,
              endedOn: _selectedEndDate!,
            );
          case EndConfidenceChoice.rough:
            await repo.saveRoughEndedManualPeriod(
              startedOn: start,
              roughDurationBucket: _roughDurationBucket!,
            );
          case null:
            break;
        }
    }
  }

  Future<void> _delete() async {
    final editing = widget.editing;
    if (editing == null || _saving) return;

    final periods = ref.read(allPeriodsProvider).valueOrNull;
    if (periods == null || periods.length <= 1) return;

    setState(() => _saving = true);
    try {
      await ref
          .read(periodRepositoryProvider)
          .deleteByStartedOn(editing.startedOn);
      if (!mounted) return;
      Navigator.of(context).pop(editing);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final periods = ref.watch(allPeriodsProvider).valueOrNull ?? const [];
    final editing = widget.editing;
    final editingStart = editing == null ? null : dateOnly(editing.startedOn);

    final editingIndex = editingStart == null
        ? -1
        : periods.indexWhere((p) => dateOnly(p.startedOn) == editingStart);

    final DateTime? minSelectable;
    final DateTime maxSelectable;
    if (editingIndex >= 0) {
      final older = editingIndex + 1 < periods.length
          ? dateOnly(periods[editingIndex + 1].startedOn)
          : null;
      minSelectable = older?.add(const Duration(days: 1));

      if (editingIndex == 0) {
        maxSelectable = dateOnly(DateTime.now());
      } else {
        maxSelectable = dateOnly(
          periods[editingIndex - 1].startedOn,
        ).subtract(const Duration(days: 1));
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

    final periodDates = {
      for (final log in periods)
        if (editingStart == null || dateOnly(log.startedOn) != editingStart)
          ...log.bleedDays,
    };

    final selectedStart = _selectedStart == null
        ? null
        : dateOnly(_selectedStart!);
    final startValid =
        selectedStart != null &&
        !blockedStarts.contains(selectedStart) &&
        !selectedStart.isAfter(maxSelectable) &&
        (minSelectable == null || !selectedStart.isBefore(minSelectable));

    final canSave =
        !_saving &&
        periodEpisodeFormIsComplete(
          startDate: selectedStart,
          ongoingStatus: _ongoingStatus,
          endConfidence: _endConfidence,
          selectedEndDate: _selectedEndDate,
          roughDurationBucket: _roughDurationBucket,
        ) &&
        startValid;

    return Scaffold(
      backgroundColor: context.ritu.backgroundPage,
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
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: Icon(
                      LucideIcons.chevronLeft,
                      size: 24,
                      color: context.ritu.textPrimary,
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
                      color: context.ritu.textPrimary,
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
                      color: context.ritu.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  RituCalendar(
                    month: _visibleMonth,
                    selectedDate: _selectedStart,
                    periodDates: periodDates,
                    minSelectableDate: minSelectable,
                    maxSelectableDate: maxSelectable,
                    monthNavigationEnabled: !_isEditing,
                    onMonthChanged: (month) {
                      setState(() => _visibleMonth = month);
                    },
                    onDateSelected: (date) {
                      if (blockedStarts.contains(dateOnly(date))) return;
                      _onStartSelected(date);
                    },
                  ),
                  const SizedBox(height: 24),
                  PeriodEpisodeFormFields(
                    ongoingStatus: _ongoingStatus,
                    onOngoingStatusChanged: (status) {
                      setState(() {
                        _ongoingStatus = status;
                        if (status == PeriodOngoingStatus.stillGoing) {
                          _endConfidence = null;
                          _selectedEndDate = null;
                          _roughDurationBucket = null;
                        }
                      });
                    },
                    endConfidence: _endConfidence,
                    onEndConfidenceChanged: (choice) {
                      setState(() {
                        _endConfidence = choice;
                        if (choice == EndConfidenceChoice.exact) {
                          _roughDurationBucket = null;
                        } else {
                          _selectedEndDate = null;
                        }
                      });
                    },
                    selectedEndDate: _selectedEndDate,
                    onEndDatePicked: (date) {
                      setState(() => _selectedEndDate = date);
                    },
                    roughDurationBucket: _roughDurationBucket,
                    onRoughDurationBucketChanged: (bucket) {
                      setState(() => _roughDurationBucket = bucket);
                    },
                    maxEndDate: maxSelectable,
                    startDate: selectedStart,
                    startDateValid: startValid,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: canSave ? _save : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: context.ritu.sage500,
                        disabledBackgroundColor: context.ritu.sage500
                            .withValues(alpha: 0.4),
                        foregroundColor: context.ritu.white,
                        disabledForegroundColor: context.ritu.white,
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
                      child: AbsorbPointer(
                        absorbing: _saving || periods.length <= 1,
                        child: TextButton(
                          onPressed: _saving || periods.length <= 1
                              ? null
                              : _delete,
                          style: TextButton.styleFrom(
                            foregroundColor: context.ritu.textCritical,
                            disabledForegroundColor: context.ritu.textCritical
                                .withValues(alpha: 0.4),
                            shape: const StadiumBorder(),
                            textStyle: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              height: 24 / 15,
                            ),
                          ),
                          child: const Text('Delete this period'),
                        ),
                      ),
                    ),
                    if (periods.length <= 1) ...[
                      const SizedBox(height: 16),
                      const _LastPeriodNotice(),
                    ],
                  ],
                  if (!_isEditing) ...[
                    const SizedBox(height: 12),
                    Text(
                      'For a period you didn’t log in real time – not a '
                      'replacement for your daily check-in',
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
            ),
          ],
        ),
      ),
    );
  }
}

class _LastPeriodNotice extends StatelessWidget {
  const _LastPeriodNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.ritu.fillAttention,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'You need at least one period date - add a new one before removing this.',
        style: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          height: 20 / 13,
          color: context.ritu.textAttention,
        ),
      ),
    );
  }
}
