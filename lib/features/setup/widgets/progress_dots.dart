import 'package:flutter/material.dart';

import '../../../theme/luna_colors.dart';

class ProgressDots extends StatelessWidget {
  const ProgressDots({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
  });

  /// 1-based step index.
  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 1; i <= totalSteps; i++) ...[
          if (i > 1) const SizedBox(width: 8),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i <= currentStep
                  ? LunaColors.sage500
                  : LunaColors.borderDisabled,
            ),
          ),
        ],
      ],
    );
  }
}
