import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/ritu_colors.dart';

Future<bool> showJournalDeleteDialog(BuildContext context) {
  return showDialog<bool>(
        context: context,
        barrierColor: const Color(0xB3000000),
        builder: (dialogContext) => const _JournalDeleteDialog(),
      ).then(
        (value) => value ?? false,
      );
}

class _JournalDeleteDialog extends StatelessWidget {
  const _JournalDeleteDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: RituColors.fillElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: RituColors.borderSubtle,
            width: 0.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delete this entry?',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 24 / 18,
                  color: RituColors.textPrimary,
                ),
              ),
              Text(
                'This can\'t be undone. Your entry will be permanently removed',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  height: 20 / 13,
                  color: RituColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(77, 36),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: RituColors.textCritical,
                    ),
                    child: Text(
                      'Delete',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 20 / 13,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(77, 36),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: RituColors.textTertiary,
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 20 / 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
