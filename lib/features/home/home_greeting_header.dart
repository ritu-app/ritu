import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/home_greeting.dart';
import '../../theme/ritu_colors.dart';

/// Home header: dynamic greeting, streak flame, settings.
class HomeGreetingHeader extends StatelessWidget {
  const HomeGreetingHeader({
    super.key,
    required this.greeting,
    required this.name,
    required this.onSettingsTap,
    this.streak = 0,
  });

  final HomeGreeting greeting;
  final String name;
  final VoidCallback onSettingsTap;
  final int streak;

  @override
  Widget build(BuildContext context) {
    final line2 = greeting.showsName ? '$name ✨' : greeting.line2;
    final line2Style = greeting.showsName
        ? GoogleFonts.dmSerifDisplay(
            fontSize: 28,
            fontWeight: FontWeight.w400,
            height: 34 / 28,
            color: RituColors.textPrimary,
          )
        : GoogleFonts.dmSerifDisplay(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            height: 25 / 18,
            color: RituColors.textPrimary,
          );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting.line1,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 20 / 13,
                  color: RituColors.textSecondary,
                ),
              ),
              Text(
                line2,
                style: line2Style,
              ),
            ],
          ),
        ),
        Row(
          children: [
            Icon(
              LucideIcons.flame,
              size: 20,
              color: streak > 0
                  ? RituColors.iconAttention
                  : RituColors.textDisabled,
            ),
            const SizedBox(width: 4),
            Text(
              '$streak',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: streak > 0
                    ? RituColors.iconAttention
                    : RituColors.textDisabled,
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onSettingsTap,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  LucideIcons.settings,
                  size: 22,
                  color: RituColors.textDisabled,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
