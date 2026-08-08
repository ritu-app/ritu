import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/date_format.dart';
import '../../data/models/period_log.dart';
import '../../providers/cycle_snapshot_provider.dart';
import '../../providers/period_providers.dart';
import '../../theme/ritu_colors.dart';
import 'add_period_screen.dart';
import 'period_started_screen.dart';

/// Figma 922:4534 — Settings → Period History (Logged vs Manual).
class PeriodHistoryScreen extends ConsumerWidget {
  const PeriodHistoryScreen({super.key});

  void _pop(BuildContext context, WidgetRef ref) {
    final periods = ref.read(allPeriodsProvider).valueOrNull ?? const [];
    final pastCount = periods.length <= 1 ? 0 : periods.length - 1;
    Navigator.of(context).pop(pastCount);
  }

  Future<void> _openAddPeriod(BuildContext context) async {
    await Navigator.of(context).push<DateTime>(
      MaterialPageRoute<DateTime>(
        builder: (_) => const AddPeriodScreen(),
      ),
    );
  }

  Future<void> _openLatest(BuildContext context) async {
    await Navigator.of(context).push<DateTime>(
      MaterialPageRoute<DateTime>(
        builder: (_) => const PeriodStartedScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periodsAsync = ref.watch(allPeriodsProvider);
    final snapshotAsync = ref.watch(cycleSnapshotProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _pop(context, ref);
      },
      child: Scaffold(
        backgroundColor: RituColors.backgroundPage,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => _pop(context, ref),
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
                    Expanded(
                      child: Text(
                        'Period history',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          height: 25 / 18,
                          color: RituColors.textPrimary,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _openAddPeriod(context),
                      behavior: HitTestBehavior.opaque,
                      child: const SizedBox(
                        width: 24,
                        height: 24,
                        child: Icon(
                          LucideIcons.circlePlus,
                          size: 24,
                          color: RituColors.sage600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: periodsAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: RituColors.sage500,
                    ),
                  ),
                  error: (error, _) => Center(child: Text('$error')),
                  data: (periods) {
                    final loggedCount =
                        periods.where((p) => !p.isManual).length;
                    final mean = snapshotAsync.valueOrNull?.mean;
                    final mostRecent = periods.isEmpty
                        ? null
                        : dateOnly(periods.first.startedOn);

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      children: [
                        _StatsBanner(
                          loggedCount: loggedCount,
                          avgCycleDays: mean,
                          mostRecent: mostRecent,
                        ),
                        const SizedBox(height: 16),
                        if (periods.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: Text(
                              'No periods yet. Tap + to add one you didn’t '
                              'log in real time.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                height: 20 / 13,
                                color: RituColors.textSecondary,
                              ),
                            ),
                          )
                        else
                          _PeriodListCard(
                            periods: periods,
                            onTapLatest: () => _openLatest(context),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsBanner extends StatelessWidget {
  const _StatsBanner({
    required this.loggedCount,
    required this.avgCycleDays,
    required this.mostRecent,
  });

  final int loggedCount;
  final double? avgCycleDays;
  final DateTime? mostRecent;

  @override
  Widget build(BuildContext context) {
    final avgLabel = avgCycleDays == null
        ? '—'
        : avgCycleDays!.toStringAsFixed(1);
    final recentLabel =
        mostRecent == null ? '—' : formatMonthDay(mostRecent!);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: RituColors.fillSecondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatCell(
              value: '$loggedCount',
              label: 'Periods logged',
            ),
          ),
          Container(width: 0.5, height: 60, color: RituColors.divider),
          Expanded(
            child: _StatCell(
              value: avgLabel,
              label: 'avg cycle (days)',
            ),
          ),
          Container(width: 0.5, height: 60, color: RituColors.divider),
          Expanded(
            child: _StatCell(
              value: recentLabel,
              label: 'most recent',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 28,
              fontWeight: FontWeight.w400,
              height: 34 / 28,
              color: RituColors.textPrimary,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 18 / 11,
              color: RituColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodListCard extends StatelessWidget {
  const _PeriodListCard({
    required this.periods,
    required this.onTapLatest,
  });

  final List<PeriodLog> periods;
  final VoidCallback onTapLatest;

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
      child: Column(
        children: [
          for (var i = 0; i < periods.length; i++) ...[
            _PeriodRow(
              log: periods[i],
              isLatest: i == 0,
              isOldest: i == periods.length - 1,
              nextNewerStart: i == 0
                  ? null
                  : dateOnly(periods[i - 1].startedOn),
              showDivider: i < periods.length - 1,
              onTap: i == 0 ? onTapLatest : null,
            ),
          ],
        ],
      ),
    );
  }
}

class _PeriodRow extends StatelessWidget {
  const _PeriodRow({
    required this.log,
    required this.isLatest,
    required this.isOldest,
    required this.nextNewerStart,
    required this.showDivider,
    this.onTap,
  });

  final PeriodLog log;
  final bool isLatest;
  final bool isOldest;
  final DateTime? nextNewerStart;
  final bool showDivider;
  final VoidCallback? onTap;

  String _subtitleFor(DateTime start) {
    if (isLatest) return 'Current period';
    // Last row in the list — Figma always uses this copy.
    if (isOldest) return 'Oldest entry on record';
    if (nextNewerStart == null) return 'Oldest entry on record';
    final days = nextNewerStart!.difference(start).inDays;
    return log.isManual
        ? '~$days days to next period'
        : '$days days to next period';
  }

  @override
  Widget build(BuildContext context) {
    final start = dateOnly(log.startedOn);
    final displaySubtitle = _subtitleFor(start);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: showDivider
              ? const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: RituColors.borderSubtle,
                      width: 0.5,
                    ),
                  ),
                )
              : null,
          child: Row(
            children: [
              SizedBox(
                width: 54,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatShortMonthDay(start),
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 24 / 15,
                        color: RituColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${start.year}',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 20 / 13,
                        color: RituColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: RituColors.fillSecondaryHover,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        log.isManual ? 'Manual' : 'Logged',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          height: 18 / 11,
                          color: RituColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      displaySubtitle,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        height: 18 / 11,
                        color: RituColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                size: 16,
                color: onTap == null
                    ? RituColors.textDisabled
                    : RituColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
