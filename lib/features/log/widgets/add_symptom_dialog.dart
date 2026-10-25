import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../theme/ritu_palette.dart';

/// Small "+ Add your own" body signal dialog shown from the daily log flow.
/// Returns the trimmed symptom name, or null if cancelled.
Future<String?> showAddSymptomDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    barrierColor: context.ritu.barrier,
    builder: (_) => const _AddSymptomDialog(),
  );
}

class _AddSymptomDialog extends StatefulWidget {
  const _AddSymptomDialog();

  @override
  State<_AddSymptomDialog> createState() => _AddSymptomDialogState();
}

class _AddSymptomDialogState extends State<_AddSymptomDialog> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  bool get _canAdd => _controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: context.ritu.backgroundPage,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'Add your own body signal',
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 24 / 18,
                        color: context.ritu.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    behavior: HitTestBehavior.opaque,
                    child: Icon(
                      LucideIcons.x,
                      size: 24,
                      color: context.ritu.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _submit(),
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 20 / 13,
                  color: context.ritu.textPrimary,
                ),
                cursorColor: context.ritu.sage500,
                decoration: InputDecoration(
                  hintText: 'Name your signal',
                  hintStyle: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 20 / 13,
                    color: context.ritu.textDisabled,
                  ),
                  filled: true,
                  fillColor: context.ritu.fillElevated,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.ritu.borderSubtle),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.ritu.sage500),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 36,
                child: FilledButton(
                  onPressed: _canAdd ? _submit : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: context.ritu.sage500,
                    disabledBackgroundColor: context.ritu.sage500.withValues(
                      alpha: 0.4,
                    ),
                    foregroundColor: context.ritu.white,
                    disabledForegroundColor: context.ritu.white,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: const StadiumBorder(),
                    textStyle: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 20 / 13,
                    ),
                  ),
                  child: const Text('Add'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
