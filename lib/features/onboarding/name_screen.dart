import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/luna_colors.dart';

class NameScreen extends StatefulWidget {
  const NameScreen({super.key, this.onContinue});

  final ValueChanged<String>? onContinue;

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  bool get _canContinue => _controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
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
    widget.onContinue?.call(name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LunaColors.backgroundPage,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Image.asset(
                'assets/images/luna_logo.png',
                width: 96,
                height: 96,
                filterQuality: FilterQuality.high,
              ),
              const SizedBox(height: 48),
              Text(
                'What should Luna call you?',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  height: 26 / 22,
                  color: LunaColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Just your first name—stays on your phone, never shared anywhere',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  height: 24 / 15,
                  color: LunaColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.words,
                autofocus: true,
                onSubmitted: (_) => _submit(),
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 24 / 15,
                  color: LunaColors.textPrimary,
                ),
                cursorColor: LunaColors.sage500,
                decoration: InputDecoration(
                  hintText: 'Your first name',
                  hintStyle: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 24 / 15,
                    color: LunaColors.textDisabled,
                  ),
                  filled: true,
                  fillColor: LunaColors.fillElevated,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: LunaColors.borderSubtle,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: LunaColors.sage500,
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _canContinue ? _submit : null,
                  child: const Text('Continue'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
