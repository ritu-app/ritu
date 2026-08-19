import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/home_greeting.dart';
import '../../theme/ritu_colors.dart';

/// Home header: dynamic greeting, streak flame, settings.
///
/// Figma `899:6234` (screen `899:6214`) — 358×49 content width, `space-between`
/// row. Greeting column: 4px gap, line 1 `text/md` medium, line 2 `display/xs`
/// or `display/md` when showing name. Trailing actions: 24px flame + streak
/// (0px gap), 8px gap, 24px settings (`text-primary`).
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

  static const _lineGap = 4.0;
  static const _actionsGap = 8.0;
  static const _iconSize = 24.0;

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

    final streakActive = streak > 0;
    final streakColor =
        streakActive ? RituColors.iconAttention : RituColors.textDisabled;

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
              const SizedBox(height: _lineGap),
              Text(
                line2,
                style: line2Style,
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.flame,
                  size: _iconSize,
                  color: streakColor,
                ),
                Text(
                  '$streak',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 20 / 13,
                    color: streakColor,
                  ),
                ),
              ],
            ),
            const SizedBox(width: _actionsGap),
            GestureDetector(
              onTap: onSettingsTap,
              behavior: HitTestBehavior.opaque,
              child: const SizedBox(
                width: _iconSize,
                height: _iconSize,
                child: Icon(
                  LucideIcons.settings,
                  size: _iconSize,
                  color: RituColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
