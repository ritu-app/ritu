import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/luna_colors.dart';

class LunaChoiceChip extends StatelessWidget {
  const LunaChoiceChip({
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
          color: selected ? LunaColors.fillSecondary : LunaColors.fillMuted,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? LunaColors.sage600 : LunaColors.borderDisabled,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
            height: 20 / 13,
            color: selected ? LunaColors.textPrimary : LunaColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class LunaDateChip extends StatelessWidget {
  const LunaDateChip({
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: LunaColors.fillSecondary,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: LunaColors.sage600),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 20 / 13,
              color: LunaColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRemove,
            behavior: HitTestBehavior.opaque,
            child: const Icon(
              Icons.close,
              size: 16,
              color: LunaColors.sage600,
            ),
          ),
        ],
      ),
    );
  }
}
