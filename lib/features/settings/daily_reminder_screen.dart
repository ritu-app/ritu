import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/models/daily_reminder.dart';
import '../../providers/daily_reminder_provider.dart';
import '../../services/daily_reminder_notifications.dart';
import '../../theme/ritu_colors.dart';

/// Figma 452:1272 — Settings → Daily Reminder.
class DailyReminderScreen extends ConsumerWidget {
  const DailyReminderScreen({super.key});

  Future<void> _setEnabled(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    if (enabled) {
      final granted = await DailyReminderNotifications.requestPermission();
      if (!granted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Notifications are off for Ritu. Enable them in system settings to get a daily reminder.',
              ),
            ),
          );
        }
        await ref.read(dailyReminderProvider.notifier).setEnabled(false);
        return;
      }
    }
    await ref.read(dailyReminderProvider.notifier).setEnabled(enabled);
  }

  Future<void> _pickTime(
    BuildContext context,
    WidgetRef ref,
    DailyReminder current,
  ) async {
    final initial = TimeOfDay(hour: current.hour, minute: current.minute);
    final platform = Theme.of(context).platform;
    final picked = platform == TargetPlatform.iOS ||
            platform == TargetPlatform.macOS
        ? await _showCupertinoTimePicker(context, initial: initial)
        : await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    await ref.read(dailyReminderProvider.notifier).setTime(
          hour: picked.hour,
          minute: picked.minute,
        );
  }

  Future<TimeOfDay?> _showCupertinoTimePicker(
    BuildContext context, {
    required TimeOfDay initial,
  }) {
    var selected = DateTime(2000, 1, 1, initial.hour, initial.minute);
    return showCupertinoModalPopup<TimeOfDay>(
      context: context,
      builder: (context) {
        return Container(
          height: 280,
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: Column(
            children: [
              SizedBox(
                height: 44,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          color: RituColors.textTertiary,
                        ),
                      ),
                    ),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      onPressed: () => Navigator.of(context).pop(
                        TimeOfDay(
                          hour: selected.hour,
                          minute: selected.minute,
                        ),
                      ),
                      child: Text(
                        'Done',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: RituColors.sage600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: selected,
                  use24hFormat: MediaQuery.alwaysUse24HourFormatOf(context),
                  onDateTimeChanged: (value) => selected = value,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminder =
        ref.watch(dailyReminderProvider).valueOrNull ?? DailyReminder.defaults;

    return Scaffold(
      backgroundColor: RituColors.backgroundPage,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  behavior: HitTestBehavior.opaque,
                  child: const SizedBox(
                    width: 24,
                    height: 24,
                    child: Icon(
                      LucideIcons.chevronLeft,
                      size: 24,
                      color: RituColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                children: [
                  Text(
                    'Set a daily reminder',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 24 / 18,
                      color: RituColors.textPrimary,
                    ),
                  ),
                  Text(
                    'We’ll remind you to log and reflect each day',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      height: 20 / 13,
                      color: RituColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _Card(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Daily reminder',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 20 / 13,
                              color: RituColors.textPrimary,
                            ),
                          ),
                        ),
                        Switch.adaptive(
                          value: reminder.enabled,
                          onChanged: (value) =>
                              _setEnabled(context, ref, value),
                          activeTrackColor: RituColors.sage600,
                          activeThumbColor: RituColors.fillElevated,
                          inactiveTrackColor: RituColors.borderDisabled,
                          inactiveThumbColor: RituColors.fillElevated,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _Card(
                    onTap: () => _pickTime(context, ref, reminder),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reminder time',
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  height: 20 / 13,
                                  color: RituColors.textPrimary,
                                ),
                              ),
                              Text(
                                reminder.timeLabel,
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  height: 18 / 11,
                                  color: RituColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          LucideIcons.chevronRight,
                          size: 16,
                          color: RituColors.textTertiary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: RituColors.fillElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: RituColors.borderSubtle),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}
