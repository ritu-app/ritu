import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/ritu_colors.dart';

/// White card with a title, a "current/max" value, a 0-10 slider, and axis
/// labels underneath (e.g. "Cramp intensity" / "Overall wellbeing").
class LogSliderCard extends StatelessWidget {
  const LogSliderCard({
    super.key,
    required this.title,
    required this.value,
    required this.labels,
    required this.onChanged,
    this.max = 10,
  });

  final String title;
  final int value;
  final int max;

  /// 2 or 3 evenly-spaced axis labels, e.g. `['None', 'Moderate', 'Intense']`.
  final List<String> labels;
  final ValueChanged<int> onChanged;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 24 / 15,
                    color: RituColors.textPrimary,
                  ),
                ),
              ),
              Text(
                '$value/$max',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  height: 20 / 13,
                  color: RituColors.sage600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 5,
              activeTrackColor: RituColors.meadow600,
              inactiveTrackColor: RituColors.fillMuted,
              thumbColor: RituColors.fillElevated,
              overlayColor: RituColors.sage500.withValues(alpha: 0.1),
              thumbShape: const _ShadowedThumbShape(),
            ),
            child: Slider(
              value: value.toDouble(),
              min: 0,
              max: max.toDouble(),
              divisions: max,
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final label in labels)
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    height: 14 / 10,
                    color: RituColors.textTertiary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShadowedThumbShape extends SliderComponentShape {
  const _ShadowedThumbShape();

  static const radius = 10.0;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size.fromRadius(radius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawCircle(center, radius, Paint()..color = Colors.white);
  }
}
