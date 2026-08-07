import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/date_format.dart';
import '../data/models/period_log.dart';
import 'repository_providers.dart';
import 'simulated_today_provider.dart';

final latestPeriodProvider = StreamProvider<PeriodLog?>((ref) {
  return ref.watch(periodRepositoryProvider).watchLatest();
});

final allPeriodsProvider = StreamProvider<List<PeriodLog>>((ref) {
  return ref.watch(periodRepositoryProvider).watchAll();
});

final bleedDaysProvider = Provider<AsyncValue<Set<DateTime>>>((ref) {
  return ref.watch(allPeriodsProvider).whenData((periods) {
    return {for (final log in periods) ...log.bleedDays};
  });
});

final daysSinceLastPeriodProvider = Provider<AsyncValue<int?>>((ref) {
  return ref.watch(latestPeriodProvider).whenData((latest) {
    if (latest == null) return null;
    final today = ref.watch(simulatedTodayProvider);
    return today.difference(dateOnly(latest.startedOn)).inDays;
  });
});

final pastPeriodStartsProvider = Provider<AsyncValue<List<DateTime>>>((ref) {
  return ref.watch(allPeriodsProvider).whenData((periods) {
    if (periods.length <= 1) return const [];
    return periods
        .skip(1)
        .map((log) => dateOnly(log.startedOn))
        .toList();
  });
});

final showSpeedUpBannerProvider = Provider<AsyncValue<bool>>((ref) {
  return ref.watch(allPeriodsProvider).whenData((periods) => periods.length < 2);
});
