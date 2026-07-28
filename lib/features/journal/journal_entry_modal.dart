import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/cycle_context.dart';
import '../../data/repositories/journal_entry_repository.dart';
import '../../theme/ritu_colors.dart';

enum JournalEntryModalMode { edit, view }

Future<String?> showJournalEntryModal(
  BuildContext context, {
  required JournalEntry entry,
  required JournalEntryModalMode mode,
  required String contextLine,
}) {
  return showDialog<String>(
    context: context,
    barrierColor: const Color(0xB3000000),
    builder: (dialogContext) {
      return _JournalEntryModal(
        entry: entry,
        mode: mode,
        contextLine: contextLine,
      );
    },
  );
}

class _JournalEntryModal extends StatefulWidget {
  const _JournalEntryModal({
    required this.entry,
    required this.mode,
    required this.contextLine,
  });

  final JournalEntry entry;
  final JournalEntryModalMode mode;
  final String contextLine;

  @override
  State<_JournalEntryModal> createState() => _JournalEntryModalState();
}

class _JournalEntryModalState extends State<_JournalEntryModal> {
  late final TextEditingController _controller;
  late final String _originalBody;
  final _focusNode = FocusNode();

  bool get _isEdit => widget.mode == JournalEntryModalMode.edit;

  bool get _canSave =>
      _isEdit &&
      _controller.text.trim().isNotEmpty &&
      _controller.text.trim() != _originalBody;

  @override
  void initState() {
    super.initState();
    _originalBody = widget.entry.body;
    _controller = TextEditingController(text: _originalBody);
    if (_isEdit) {
      _controller.addListener(() => setState(() {}));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
        _controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _controller.text.length,
        );
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _save() {
    if (!_canSave) return;
    Navigator.of(context).pop(_controller.text.trim());
  }

  void _discard() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: RituColors.backgroundPage,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: RituColors.textDisabled),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatJournalEntryModalTitle(widget.entry.loggedOn),
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            height: 24 / 15,
                            color: RituColors.textPrimary,
                          ),
                        ),
                        Text(
                          widget.contextLine,
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 20 / 13,
                            color: RituColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _discard,
                    behavior: HitTestBehavior.opaque,
                    child: const Icon(
                      LucideIcons.x,
                      size: 24,
                      color: RituColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                height: 177,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: RituColors.fillElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: RituColors.borderSubtle),
                ),
                child: _isEdit
                    ? TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          height: 20 / 13,
                          color: RituColors.textPrimary,
                        ),
                        decoration: const InputDecoration(
                          isCollapsed: true,
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      )
                    : SingleChildScrollView(
                        child: Text(
                          widget.entry.body,
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            height: 20 / 13,
                            color: RituColors.textPrimary,
                          ),
                        ),
                      ),
              ),
              if (_isEdit) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: FilledButton(
                    onPressed: _canSave ? _save : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: RituColors.sage500,
                      disabledBackgroundColor:
                          RituColors.sage500.withValues(alpha: 0.5),
                      foregroundColor: RituColors.white,
                      disabledForegroundColor: RituColors.white,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: const StadiumBorder(),
                      textStyle: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 20 / 13,
                      ),
                    ),
                    child: const Text('Save entry'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: TextButton(
                    onPressed: _discard,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: RituColors.textTertiary,
                    ),
                    child: Text(
                      'Discard changes',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 20 / 13,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
