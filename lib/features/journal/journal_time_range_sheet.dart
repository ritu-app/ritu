import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../theme/ritu_colors.dart';
import 'journal_time_range.dart';

/// Figma 865:3625 — Time range bottom sheet.
Future<JournalTimeRange?> showJournalTimeRangeSheet(
  BuildContext context, {
  JournalTimeRange? selected,
}) {
  return showModalBottomSheet<JournalTimeRange>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0xB3000000),
    isScrollControlled: true,
    builder: (sheetContext) => _JournalTimeRangeSheet(selected: selected),
  );
}

class _JournalTimeRangeSheet extends StatelessWidget {
  const _JournalTimeRangeSheet({this.selected});

  final JournalTimeRange? selected;

  static const _options = JournalTimeRange.values;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: RituColors.backgroundPage,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        side: BorderSide(color: RituColors.borderSubtle),
      ),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'Time range',
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 24 / 18,
                        color: RituColors.textPrimary,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    behavior: HitTestBehavior.opaque,
                    child: const SizedBox(
                      width: 24,
                      height: 24,
                      child: Icon(
                        LucideIcons.x,
                        size: 24,
                        color: RituColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: RituColors.fillElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: RituColors.borderSubtle),
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < _options.length; i++)
                      _TimeRangeRow(
                        range: _options[i],
                        selected: selected == _options[i],
                        showDivider: i < _options.length - 1,
                        onTap: _options[i].isEnabled
                            ? () => Navigator.of(context).pop(_options[i])
                            : null,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeRangeRow extends StatelessWidget {
  const _TimeRangeRow({
    required this.range,
    required this.selected,
    required this.showDivider,
    this.onTap,
  });

  final JournalTimeRange range;
  final bool selected;
  final bool showDivider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final labelColor =
        enabled ? RituColors.textPrimary : RituColors.textDisabled;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: showDivider
              ? const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: RituColors.borderSubtle,
                      width: 0.5,
                    ),
                  ),
                )
              : null,
          child: Row(
            children: [
              _RadioMark(selected: selected && enabled, enabled: enabled),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  range.label,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 20 / 13,
                    color: labelColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadioMark extends StatelessWidget {
  const _RadioMark({required this.selected, required this.enabled});

  final bool selected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (selected) {
      return Container(
        width: 16,
        height: 16,
        decoration: const BoxDecoration(
          color: RituColors.fillBrandPressed,
          shape: BoxShape.circle,
        ),
      );
    }

    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: enabled ? RituColors.textDisabled : RituColors.borderSubtle,
        ),
      ),
    );
  }
}
