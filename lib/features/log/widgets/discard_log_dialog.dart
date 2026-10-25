import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/ritu_palette.dart';

/// Asks before leaving a daily log that already has answers.
/// Returns true when the entry should be discarded.
Future<bool> showDiscardLogDialog(
  BuildContext context, {
  required bool editing,
}) {
  return showDialog<bool>(
    context: context,
    barrierColor: context.ritu.barrier,
    builder: (dialogContext) => _DiscardLogDialog(editing: editing),
  ).then((value) => value ?? false);
}

class _DiscardLogDialog extends StatelessWidget {
  const _DiscardLogDialog({required this.editing});

  final bool editing;

  @override
  Widget build(BuildContext context) {
    final title = editing ? 'Discard your changes?' : 'Discard this log?';
    final body = editing
        ? 'Your original log stays as it was.'
        : "What you've entered so far won't be saved.";
    final keepLabel = editing ? 'Keep editing' : 'Keep logging';
    final discardLabel = editing ? 'Discard changes' : 'Discard';
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 358),
        child: Material(
          color: context.ritu.fillElevated,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: context.ritu.borderSubtle, width: 0.5),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 24 / 18,
                    color: context.ritu.textPrimary,
                  ),
                ),
                Text(
                  body,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 20 / 13,
                    color: context.ritu.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _DialogAction(
                      label: keepLabel,
                      color: context.ritu.sage600,
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    const SizedBox(width: 32),
                    _DialogAction(
                      label: discardLabel,
                      color: context.ritu.textTertiary,
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogAction extends StatelessWidget {
  const _DialogAction({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(0, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: color,
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          height: 20 / 13,
        ),
      ),
    );
  }
}
