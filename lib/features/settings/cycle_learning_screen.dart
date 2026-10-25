import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/cycle/cycle_classification.dart';
import '../../core/cycle/cycle_snapshot.dart';
import '../../providers/cycle_snapshot_provider.dart';
import '../../theme/ritu_palette.dart';

/// Figma 447:1037 / 1249:6524 / 1270:6085 / 1270:6180 —
/// Settings → Cycle Learning.
const _learningBanner = Color(0xFFE7E9DE);

class CycleLearningScreen extends ConsumerWidget {
  const CycleLearningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(cycleSnapshotProvider);

    return Scaffold(
      backgroundColor: context.ritu.backgroundPage,
      body: SafeArea(
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: snapshot.when(
                loading: () => Center(
                  child: CircularProgressIndicator(color: context.ritu.sage500),
                ),
                error: (error, _) => Center(child: Text('$error')),
                data: (value) {
                  if (value.classification ==
                          CycleClassification.unclassified ||
                      value.mean == null ||
                      value.mad == null ||
                      value.sample.isEmpty) {
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      children: [
                        _LearningCard(completedCycles: value.completedCycles),
                      ],
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    children: [
                      _StatusCard(snapshot: value),
                      const SizedBox(height: 20),
                      _StatsRow(snapshot: value),
                      const SizedBox(height: 20),
                      _SpectrumCard(classification: value.classification),
                      const SizedBox(height: 20),
                      _HowCard(snapshot: value),
                      const SizedBox(height: 20),
                      const _ChangeNote(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
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
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Cycle Learning',
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                height: 25 / 18,
                color: context.ritu.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LearningCard extends StatelessWidget {
  const _LearningCard({required this.completedCycles});

  final int completedCycles;

  @override
  Widget build(BuildContext context) {
    final towardThree = completedCycles <= 0
        ? 10 / 326
        : (completedCycles / 3).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _learningBanner,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.ritu.borderDefault, width: 0.5),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 116,
            height: 118,
            child: ClipRect(
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Positioned(
                    left: -116 * 0.1034,
                    top: -118 * 0.0508,
                    width: 116 * 1.1293,
                    height: 118 * 1.1102,
                    child: Image.asset(
                      'assets/images/cycle_learning.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Learning your rhythm',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 24 / 18,
              color: context.ritu.textPrimary,
            ),
          ),
          Text(
            'Ritu needs more data to classify your cycle type',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 20 / 13,
              color: context.ritu.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final fill = (constraints.maxWidth * towardThree).clamp(
                10.0,
                constraints.maxWidth,
              );
              return Stack(
                children: [
                  Container(
                    height: 5,
                    decoration: BoxDecoration(
                      color: context.ritu.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  Container(
                    width: fill,
                    height: 5,
                    decoration: BoxDecoration(
                      color: context.ritu.meadow600,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            'Current status - Unclassified',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              height: 18 / 11,
              color: context.ritu.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.snapshot});

  final CycleSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final classification = snapshot.classification;
    final (background, border) = switch (classification) {
      CycleClassification.regular => (
        context.ritu.fillPositiveSecondary,
        context.ritu.borderPositive,
      ),
      CycleClassification.variable => (
        context.ritu.fillAttentionSecondary,
        context.ritu.cycleOvulation,
      ),
      CycleClassification.unpredictable => (
        context.ritu.fillCriticalSecondary,
        context.ritu.borderCritical,
      ),
      CycleClassification.unclassified => (
        _learningBanner,
        context.ritu.borderDefault,
      ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current status',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              height: 18 / 11,
              color: context.ritu.textTertiary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _statusTitle(classification),
            style: GoogleFonts.dmSans(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 26 / 22,
              color: context.ritu.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _statusBody(snapshot),
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 20 / 13,
              color: context.ritu.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.snapshot});

  final CycleSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final mean = snapshot.mean!.round();
    final variation = snapshot.mad!.round();
    final sample = snapshot.sample;
    final low = sample.reduce((a, b) => a < b ? a : b);
    final high = sample.reduce((a, b) => a > b ? a : b);
    final first = snapshot.classification == CycleClassification.regular
        ? (value: _dayCount(mean), label: 'Personal average')
        : (value: '$low-$high days', label: 'Typical range');

    return Row(
      children: [
        Expanded(
          child: _StatCard(value: first.value, label: first.label),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: _StatCard(
            value: '±${_dayCount(variation)}',
            label: 'Typical variation',
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: _StatCard(value: '${sample.length}', label: 'Cycles analyzed'),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.ritu.fillElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.ritu.borderDefault, width: 0.5),
      ),
      child: Column(
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 24 / 15,
              color: context.ritu.textPrimary,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              height: 18 / 11,
              color: context.ritu.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpectrumCard extends StatelessWidget {
  const _SpectrumCard({required this.classification});

  final CycleClassification classification;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.ritu.fillElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.ritu.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Where you fall',
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 24 / 15,
              color: context.ritu.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final markerLeft = switch (classification) {
                CycleClassification.regular => 28 / 326 * width,
                CycleClassification.variable => 147 / 326 * width,
                CycleClassification.unpredictable => 262 / 326 * width,
                CycleClassification.unclassified => 0.0,
              }.clamp(0.0, (width - 20).clamp(0.0, width));
              return SizedBox(
                height: 20,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 7,
                      height: 5,
                      child: Row(
                        key: Key('cycle-spectrum-bar'),
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 109,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: context.ritu.borderPositive,
                                borderRadius: BorderRadius.horizontal(
                                  left: Radius.circular(999),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 108,
                            child: ColoredBox(
                              color: context.ritu.cycleOvulation,
                            ),
                          ),
                          Expanded(
                            flex: 109,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: context.ritu.cycleMenstrual,
                                borderRadius: BorderRadius.horizontal(
                                  right: Radius.circular(999),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: markerLeft,
                      top: 0,
                      child: const _SpectrumMarker(),
                    ),
                  ],
                ),
              );
            },
          ),
          Row(
            children: [
              Expanded(child: Text('Regular', style: _spectrumLabel(context))),
              Expanded(
                child: Text(
                  'Variable',
                  textAlign: TextAlign.center,
                  style: _spectrumLabel(context),
                ),
              ),
              Expanded(
                child: Text(
                  'Unpredictable',
                  textAlign: TextAlign.right,
                  style: _spectrumLabel(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpectrumMarker extends StatelessWidget {
  const _SpectrumMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.ritu.sage500,
        border: Border.all(color: context.ritu.white, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 4.3,
            offset: Offset(0, 2),
          ),
        ],
      ),
    );
  }
}

class _HowCard extends StatelessWidget {
  const _HowCard({required this.snapshot});

  final CycleSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final color = switch (snapshot.classification) {
      CycleClassification.regular => context.ritu.textPositive,
      CycleClassification.variable => context.ritu.textAttention,
      CycleClassification.unpredictable => context.ritu.textCritical,
      CycleClassification.unclassified => context.ritu.textPositive,
    };
    final lines = _howLines(snapshot);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.ritu.fillElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.ritu.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How we figured this out',
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 24 / 15,
              color: context.ritu.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < lines.length; i++) ...[
            _HowLine(text: lines[i], color: color),
            if (i != lines.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _HowLine extends StatelessWidget {
  const _HowLine({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(LucideIcons.circleArrowRight, size: 16, color: color),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 20 / 13,
              color: context.ritu.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _ChangeNote extends StatelessWidget {
  const _ChangeNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.ritu.fillInfo,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'This can change. Ritu re-checks every time you log a new period',
        style: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          height: 20 / 13,
          color: context.ritu.textInfo,
        ),
      ),
    );
  }
}

TextStyle _spectrumLabel(BuildContext context) => GoogleFonts.dmSans(
  fontSize: 10,
  fontWeight: FontWeight.w500,
  height: 14 / 10,
  color: context.ritu.textTertiary,
);

String _statusTitle(CycleClassification classification) {
  return switch (classification) {
    CycleClassification.regular => 'Regular',
    CycleClassification.variable => 'Variable',
    CycleClassification.unpredictable => 'Unpredictable',
    CycleClassification.unclassified => 'Unclassified',
  };
}

String _statusBody(CycleSnapshot snapshot) {
  final count = snapshot.sample.length;
  final cycles = count == 1 ? 'cycle' : 'cycles';
  return switch (snapshot.classification) {
    CycleClassification.regular =>
      'Your cycles have stayed close to your own average for the last $count $cycles - one of the most consistent patterns Ritu tracks',
    CycleClassification.variable =>
      'Your cycle length has shifted by about ${_dayCount(snapshot.mad!.round())} on average over your last $count $cycles - common, and still very trackable, just with a bit more range',
    CycleClassification.unpredictable =>
      "Your cycle length has shifted by more than 10 days on average over your last $count $cycles. That's a wide swing, so Ritu won't guess at phases or a next date - just your logged periods",
    CycleClassification.unclassified =>
      'Ritu needs more data to classify your cycle type',
  };
}

List<String> _howLines(CycleSnapshot snapshot) {
  final count = snapshot.sample.length;
  final first = 'We look at your last $count logged cycle lengths';
  return switch (snapshot.classification) {
    CycleClassification.regular => [
      first,
      'We compare each one to your own average - never a fixed number like 28 days',
      "They're all within about 4 days of each other, so you're Regular",
    ],
    CycleClassification.variable => [
      first,
      'We compare each one to your own average, not a fixed number',
      "They differ by 5–9 days on average, so you're Variable, we'll show dates as ranges, not exact days",
    ],
    CycleClassification.unpredictable => [
      first,
      'We compare each one to your own average, not a fixed number',
      "They differ by 10 or more days on average, that's Unpredictable, not a diagnosis, just a pattern in your own data.",
    ],
    CycleClassification.unclassified => [first],
  };
}

String _dayCount(int days) => '$days ${days == 1 ? 'day' : 'days'}';
