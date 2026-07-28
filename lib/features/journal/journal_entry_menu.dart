import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../theme/ritu_colors.dart';

class JournalEntryMenuButton extends StatelessWidget {
  const JournalEntryMenuButton({
    super.key,
    required this.onEdit,
    required this.onView,
    required this.onDelete,
  });

  final VoidCallback onEdit;
  final VoidCallback onView;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_JournalEntryAction>(
      icon: const Icon(
        LucideIcons.ellipsis,
        size: 24,
        color: RituColors.textSecondary,
      ),
      padding: EdgeInsets.zero,
      offset: const Offset(-90, 28),
      color: RituColors.backgroundPage,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(7),
        side: const BorderSide(color: Color(0xFFE2DDD8)),
      ),
      onSelected: (action) {
        switch (action) {
          case _JournalEntryAction.edit:
            onEdit();
          case _JournalEntryAction.view:
            onView();
          case _JournalEntryAction.delete:
            onDelete();
        }
      },
      itemBuilder: (context) => [
        _menuItem(_JournalEntryAction.edit, LucideIcons.pen, 'Edit'),
        _menuItem(_JournalEntryAction.view, LucideIcons.eye, 'View'),
        _menuItem(_JournalEntryAction.delete, LucideIcons.trash2, 'Delete'),
      ],
    );
  }

  PopupMenuItem<_JournalEntryAction> _menuItem(
    _JournalEntryAction value,
    IconData icon,
    String label,
  ) {
    return PopupMenuItem(
      value: value,
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: RituColors.textSecondary),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 20 / 13,
              color: RituColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

enum _JournalEntryAction { edit, view, delete }
