import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ritu/providers/cycle_snapshot_provider.dart';

class DebugPanel extends ConsumerWidget {
  const DebugPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshotAsync = ref.watch(cycleSnapshotProvider);
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: snapshotAsync.when(
          loading: () => const Text('Computing cycle snapshot…'),
          error: (error, _) => Text('Error: $error'),
          data: (snapshot) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Debug readout',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                _ReadoutRow(
                  label: 'Insights mode',
                  value: _formatEnum(snapshot.insightsMode),
                  highlight: true,
                ),
                _ReadoutRow(
                  label: 'Completed cycles',
                  value: '${snapshot.completedCycles}',
                ),
                _ReadoutRow(
                  label: 'Classification',
                  value: _formatEnum(snapshot.classification),
                ),
                _ReadoutRow(
                  label: 'MAD',
                  value: snapshot.mad?.toStringAsFixed(1) ?? '—',
                ),
                _ReadoutRow(
                  label: 'Cycle day',
                  value: snapshot.cycleDay?.toString() ?? '—',
                ),
                _ReadoutRow(
                  label: 'Phase',
                  value: snapshot.todayPhase == null
                      ? '—'
                      : _formatEnum(snapshot.todayPhase!),
                ),
                _ReadoutRow(
                  label: 'Tier',
                  value: snapshot.ranges?.tier == null
                      ? '—'
                      : _formatEnum(snapshot.ranges!.tier),
                ),
                _ReadoutRow(
                  label: 'Effective C',
                  value: snapshot.effectiveCycleLength?.toString() ?? '—',
                ),
                _ReadoutRow(
                  label: 'Phase estimates',
                  value: snapshot.showsPhaseEstimates ? 'Yes' : 'No',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ReadoutRow extends StatelessWidget {
  const _ReadoutRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final valueStyle = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: highlight ? FontWeight.w600 : FontWeight.w500,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: labelStyle),
          const SizedBox(height: 2),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }
}

String _formatEnum(Object value) {
  final name = value.toString().split('.').last;
  if (name.isEmpty) return name;
  return '${name[0].toUpperCase()}${name.substring(1)}';
}
