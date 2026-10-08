import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ritu/core/cycle/cycle_snapshot.dart';
import 'package:ritu/providers/cycle_snapshot_provider.dart';
import 'package:ritu/theme/ritu_colors.dart';

import '../theme/studio_styles.dart';
import '../util/studio_labels.dart';
import 'studio_disclosure.dart';

class ScenarioReadout extends ConsumerWidget {
  const ScenarioReadout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(cycleSnapshotProvider);

    return StudioSurface(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: snapshot.when(
        loading: () => const _ReadoutRows.placeholder(),
        error: (error, _) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Couldn’t read the cycle: $error',
            style: StudioText.noteBody,
          ),
        ),
        data: (data) => _ReadoutRows(snapshot: data),
      ),
    );
  }
}

class _ReadoutRows extends StatelessWidget {
  const _ReadoutRows({required this.snapshot}) : placeholder = false;

  const _ReadoutRows.placeholder() : snapshot = null, placeholder = true;

  final CycleSnapshot? snapshot;
  final bool placeholder;

  @override
  Widget build(BuildContext context) {
    final data = snapshot;
    final rows = <(String, String)>[
      ('Cycle day', _text(data?.cycleDay?.toString())),
      ('Phase', data == null ? '—' : phaseLabel(data.todayPhase)),
      (
        'Average cycle',
        _text(
          data?.effectiveCycleLength?.toString() ??
              (data?.mean == null ? null : data!.mean!.round().toString()),
        ),
      ),
      (
        'Classification',
        data == null ? '—' : classificationLabel(data.classification),
      ),
      (
        'Insights',
        data == null ? '—' : insightsAvailabilityLabel(data.insightsMode),
      ),
      ('Completed cycles', _text(data?.completedCycles.toString())),
      ('MAD', data?.mad == null ? '—' : data!.mad!.toStringAsFixed(1)),
    ];

    return Column(
      children: [
        for (var i = 0; i < rows.length; i++)
          _ReadoutRow(
            label: rows[i].$1,
            value: placeholder ? '—' : rows[i].$2,
            isLast: i == rows.length - 1,
          ),
      ],
    );
  }

  String _text(String? value) => value ?? '—';
}

class _ReadoutRow extends StatelessWidget {
  const _ReadoutRow({
    required this.label,
    required this.value,
    required this.isLast,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: RituColors.borderSubtle, width: 0.5),
              ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: StudioText.readoutLabel,
            ),
          ),
          const SizedBox(width: 12),
          Text(value, style: StudioText.readout),
        ],
      ),
    );
  }
}

class RecentChangesCard extends StatelessWidget {
  const RecentChangesCard({super.key, required this.changes});

  final List<String> changes;

  @override
  Widget build(BuildContext context) {
    return StudioSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent changes', style: StudioText.cardTitle),
          if (changes.isEmpty)
            Text(
              'No recent changes - try a scenario on the left',
              style: StudioText.noteBody,
            )
          else
            for (final change in changes)
              Text(change, style: StudioText.noteBody),
        ],
      ),
    );
  }
}
