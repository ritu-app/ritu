import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/cycle/cycle_adapters.dart';
import '../core/cycle/cycle_snapshot.dart';
import 'period_providers.dart';
import 'simulated_today_provider.dart';

/// Reactive cycle engine output from logged period history and [simulatedTodayProvider].
final cycleSnapshotProvider = Provider<AsyncValue<CycleSnapshot>>((ref) {
  return ref.watch(allPeriodsProvider).when(
    data: (logs) => AsyncData(
      cycleSnapshotFromPeriodLogs(
        referenceDate: ref.watch(simulatedTodayProvider),
        logs: logs,
      ),
    ),
    loading: () => const AsyncLoading(),
    error: (error, stackTrace) => AsyncError(error, stackTrace),
  );
});
