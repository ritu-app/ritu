import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/app_scope.dart';
import '../../core/date_format.dart';
import '../../theme/ritu_colors.dart';
import '../setup/widgets/past_period_dates_editor.dart';

/// Full-page past period dates editor (Figma Settings → Period History).
class PeriodHistoryScreen extends StatefulWidget {
  const PeriodHistoryScreen({super.key});

  @override
  State<PeriodHistoryScreen> createState() => _PeriodHistoryScreenState();
}

class _PeriodHistoryScreenState extends State<PeriodHistoryScreen> {
  List<DateTime>? _initialDates;
  DateTime? _maxSelectableDate;
  int? _typicalPeriodDays;
  var _loading = true;
  var _loadStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadStarted) {
      _loadStarted = true;
      _load();
    }
  }

  Future<void> _load() async {
    final periods = AppScope.periods(context);
    final profiles = AppScope.profiles(context);
    final latest = await periods.getLatest();
    final past = await periods.getPastStartedOn();
    final profile = await profiles.getProfile();
    if (!mounted) return;

    setState(() {
      _initialDates = past;
      _typicalPeriodDays = profile?.typicalPeriodDays;
      _maxSelectableDate = latest == null
          ? dateOnly(DateTime.now())
          : dateOnly(latest.startedOn).subtract(const Duration(days: 1));
      _loading = false;
    });
  }

  Future<void> _onDateAdded(DateTime date) async {
    await AppScope.periods(context).addPastStart(
      startedOn: date,
      typicalPeriodDays: _typicalPeriodDays,
    );
  }

  Future<void> _onDateRemoved(DateTime date) async {
    await AppScope.periods(context).deleteByStartedOn(date);
  }

  Future<void> _pop() async {
    final count = await AppScope.periods(context).getPastStartedOn();
    if (!mounted) return;
    Navigator.of(context).pop(count.length);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _pop();
      },
      child: Scaffold(
        backgroundColor: RituColors.backgroundPage,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: IconButton(
                  onPressed: _pop,
                  icon: const Icon(
                    Icons.chevron_left,
                    size: 28,
                    color: RituColors.textPrimary,
                  ),
                ),
              ),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: RituColors.sage500,
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Do you have past period dates?',
                              style: GoogleFonts.dmSans(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                height: 26 / 22,
                                color: RituColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'It helps Ritu understand your cycle right away',
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                height: 24 / 15,
                                color: RituColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            PastPeriodDatesEditor(
                              initialDates: _initialDates ?? const [],
                              maxSelectableDate: _maxSelectableDate,
                              onDateAdded: _onDateAdded,
                              onDateRemoved: _onDateRemoved,
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
