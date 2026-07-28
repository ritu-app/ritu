import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../providers/profile_providers.dart';
import '../../providers/period_providers.dart';
import '../../providers/repository_providers.dart';
import '../../core/date_format.dart';
import '../../data/repositories/period_repository.dart';
import '../../theme/ritu_colors.dart';
import '../setup/widgets/ritu_calendar.dart';

/// Full-page period start date editor (Figma Settings → Period Started).
class PeriodStartedScreen extends ConsumerStatefulWidget {
  const PeriodStartedScreen({super.key});

  @override
  ConsumerState<PeriodStartedScreen> createState() =>
      _PeriodStartedScreenState();
}

class _PeriodStartedScreenState extends ConsumerState<PeriodStartedScreen> {
  late DateTime _visibleMonth;
  DateTime? _selectedDate;
  var _initialized = false;
  var _saving = false;

  void _initializeFromData(PeriodLog? latest, int? typicalPeriodDays) {
    if (_initialized) return;
    _initialized = true;

    final today = dateOnly(DateTime.now());
    final initial = dateOnly(latest?.startedOn ?? today);
    final selected = initial.isAfter(today) ? today : initial;

    _selectedDate = selected;
    _visibleMonth = DateTime(selected.year, selected.month);
  }

  int? get _typicalPeriodDays =>
      ref.watch(profileProvider).valueOrNull?.typicalPeriodDays;

  /// Days after the selected start that the period is estimated to cover,
  /// shown as a lightweight text-only preview on the calendar.
  Set<DateTime> get _previewDates {
    final start = _selectedDate;
    final typical = _typicalPeriodDays;
    if (start == null || typical == null || typical < 2) return {};

    final end = PeriodRepository.estimateEnd(start, typical);
    if (end == null) return {};

    final days = <DateTime>{};
    var cursor = start.add(const Duration(days: 1));
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
    await ref.read(periodRepositoryProvider).updateLatestStartedOn(
      newStartedOn: selected,
      typicalPeriodDays: _typicalPeriodDays,
    );
    if (!mounted) return;
    Navigator.of(context).pop(selected);
  }

  void _cancel() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    final latestAsync = ref.watch(latestPeriodProvider);
    final profileAsync = ref.watch(profileProvider);

    if (latestAsync.isLoading || profileAsync.isLoading) {
      return Scaffold(
        backgroundColor: RituColors.backgroundPage,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: IconButton(
                  onPressed: _cancel,
                  icon: const Icon(
                    LucideIcons.chevronLeft,
                    size: 28,
                    color: RituColors.textPrimary,
                  ),
                ),
              ),
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: RituColors.sage500),
                ),
              ),
            ],
          ),
        ),
      );
    }

    _initializeFromData(
      latestAsync.valueOrNull,
      profileAsync.valueOrNull?.typicalPeriodDays,
    );

    return Scaffold(
      backgroundColor: RituColors.backgroundPage,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: IconButton(
                onPressed: _cancel,
                icon: const Icon(
                  LucideIcons.chevronLeft,
                  size: 28,
                  color: RituColors.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'When did your last period start?',
                      style: GoogleFonts.dmSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        height: 26 / 22,
                        color: RituColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    RituCalendar(
                      month: _visibleMonth,
                      selectedDate: _selectedDate,
                      maxSelectableDate: DateTime.now(),
                      previewDates: _previewDates,
                      onMonthChanged: (month) {
                        setState(() => _visibleMonth = month);
                      },
                      onDateSelected: (date) {
                        setState(() => _selectedDate = dateOnly(date));
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        onPressed: _saving ? null : _save,
                        style: FilledButton.styleFrom(
                          backgroundColor: RituColors.sage500,
                          disabledBackgroundColor: RituColors.sage500
                              .withValues(alpha: 0.4),
                          foregroundColor: RituColors.white,
                          disabledForegroundColor: RituColors.white,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: const StadiumBorder(),
                          textStyle: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            height: 24 / 15,
                          ),
                        ),
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
