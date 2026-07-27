import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../theme/ritu_colors.dart';

class RituChoiceChip extends StatelessWidget {
  const RituChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.width,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? RituColors.fillSecondary : RituColors.fillMuted,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? RituColors.sage600 : RituColors.borderDisabled,
          ),
        ),
        alignment: width == null ? null : Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
            height: 20 / 13,
            color: selected ? RituColors.textPrimary : RituColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class RituDateChip extends StatelessWidget {
  const RituDateChip({
    super.key,
    required this.label,
    required this.onRemove,
  });

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      decoration: BoxDecoration(
        color: RituColors.fillSecondary,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: RituColors.sage600),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 20 / 13,
              color: RituColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRemove,
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(2),
              child: Icon(
                LucideIcons.x,
                size: 16,
                color: RituColors.sage600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
