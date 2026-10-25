import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../theme/ritu_palette.dart';

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
    final labelText = Text(
      label,
      softWrap: false,
      style: GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
        height: 20 / 13,
        color: selected ? context.ritu.textPrimary : context.ritu.textMuted,
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: width == null ? null : Alignment.center,
        decoration: BoxDecoration(
          color: selected ? context.ritu.fillSecondary : context.ritu.fillMuted,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? context.ritu.sage600
                : context.ritu.borderDisabled,
          ),
        ),
        child: width == null
            ? Row(mainAxisSize: MainAxisSize.min, children: [labelText])
            : labelText,
      ),
    );
  }
}

class RituDateChip extends StatelessWidget {
  const RituDateChip({super.key, required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      decoration: BoxDecoration(
        color: context.ritu.fillSecondary,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: context.ritu.sage600),
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
              color: context.ritu.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRemove,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.all(2),
              child: Icon(LucideIcons.x, size: 16, color: context.ritu.sage600),
            ),
          ),
        ],
      ),
    );
  }
}
