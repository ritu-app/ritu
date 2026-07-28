import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../providers/period_providers.dart';
import '../../providers/profile_providers.dart';
import '../../providers/repository_access.dart';
import '../../core/date_format.dart';
import '../../theme/ritu_colors.dart';
import '../setup/widgets/past_period_dates_editor.dart';

/// Full-page past period dates editor (Figma Settings → Period History).
class PeriodHistoryScreen extends ConsumerWidget {
  const PeriodHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pastAsync = ref.watch(pastPeriodStartsProvider);
    final latestAsync = ref.watch(latestPeriodProvider);
    final profileAsync = ref.watch(profileProvider);

    void pop() {
      final count = pastAsync.valueOrNull?.length ?? 0;
      Navigator.of(context).pop(count);
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        pop();
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
                  onPressed: pop,
                  icon: const Icon(
                    LucideIcons.chevronLeft,
                    size: 28,
                    color: RituColors.textPrimary,
                  ),
                ),
              ),
              Expanded(
                child: pastAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: RituColors.sage500,
                    ),
                  ),
                  error: (error, _) => Center(child: Text('$error')),
                  data: (pastDates) {
                    if (latestAsync.isLoading || profileAsync.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: RituColors.sage500,
                        ),
                      );
                    }

                    final latest = latestAsync.valueOrNull;
                    final typicalDays =
                        profileAsync.valueOrNull?.typicalPeriodDays;
                    final maxSelectableDate = latest == null
                        ? dateOnly(DateTime.now())
                        : dateOnly(
                            latest.startedOn,
                          ).subtract(const Duration(days: 1));

                    return SingleChildScrollView(
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
                            initialDates: pastDates,
                            maxSelectableDate: maxSelectableDate,
                            onDateAdded: (date) => context.periods.addPastStart(
                              startedOn: date,
                              typicalPeriodDays: typicalDays,
                            ),
                            onDateRemoved: (date) =>
                                context.periods.deleteByStartedOn(date),
                          ),
                        ],
                      ),
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
