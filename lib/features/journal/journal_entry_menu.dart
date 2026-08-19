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

  static const _borderDefault = Color(0xFFE2DDD8);

  Future<void> _open(BuildContext context) async {
    final button = context.findRenderObject() as RenderBox?;
    if (button == null || !button.hasSize) return;

    final origin = button.localToGlobal(Offset.zero);
    final screenWidth = MediaQuery.sizeOf(context).width;
    // Sit just under the ellipsis, right-aligned with the icon.
    final top = origin.dy + button.size.height + 4;
    final right = screenWidth - (origin.dx + button.size.width);

    final action = await showDialog<_JournalEntryAction>(
      context: context,
      barrierColor: Colors.transparent,
      useSafeArea: false,
      builder: (dialogContext) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(dialogContext).pop(),
              ),
            ),
            Positioned(
              right: right.clamp(8.0, screenWidth - 8),
              top: top,
              child: Material(
                color: Colors.transparent,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 110),
                  child: IntrinsicWidth(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: RituColors.fillSubtle,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _borderDefault),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _menuRow(
                            dialogContext,
                            _JournalEntryAction.edit,
                            LucideIcons.pen,
                            'Edit',
                          ),
                          const SizedBox(height: 12),
                          _menuRow(
                            dialogContext,
                            _JournalEntryAction.view,
                            LucideIcons.eye,
                            'View',
                          ),
                          const SizedBox(height: 12),
                          _menuRow(
                            dialogContext,
                            _JournalEntryAction.delete,
                            LucideIcons.trash2,
                            'Delete',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    switch (action) {
      case _JournalEntryAction.edit:
        onEdit();
      case _JournalEntryAction.view:
        onView();
      case _JournalEntryAction.delete:
        onDelete();
      case null:
        break;
    }
  }

  Widget _menuRow(
    BuildContext context,
    _JournalEntryAction action,
    IconData icon,
    String label,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pop(action),
      child: Row(
        mainAxisSize: MainAxisSize.min,
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _open(context),
      behavior: HitTestBehavior.opaque,
      child: const SizedBox(
        width: 24,
        height: 24,
        child: Icon(
          LucideIcons.ellipsis,
          size: 24,
          color: RituColors.textSecondary,
        ),
      ),
    );
  }
}

enum _JournalEntryAction { edit, view, delete }
