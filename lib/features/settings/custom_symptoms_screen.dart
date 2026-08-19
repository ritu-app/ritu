import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../providers/repository_providers.dart';
import '../../providers/symptom_providers.dart';
import '../../data/repositories/symptom_repository.dart';
import '../../theme/ritu_colors.dart';
import '../setup/widgets/choice_chips.dart';
import '../setup/widgets/setup_footer.dart';

/// Full-page custom symptom manager (Figma Settings → Custom Symptoms).
///
/// Additions and removals persist immediately — there's no separate Save.
class CustomSymptomsScreen extends ConsumerStatefulWidget {
  const CustomSymptomsScreen({super.key});

  @override
  ConsumerState<CustomSymptomsScreen> createState() =>
      _CustomSymptomsScreenState();
}

class _CustomSymptomsScreenState extends ConsumerState<CustomSymptomsScreen> {
  final _controller = TextEditingController();
  var _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canAdd => !_busy && _controller.text.trim().isNotEmpty;

  Future<void> _addSymptom() async {
    final name = _controller.text.trim();
    if (name.isEmpty || _busy) return;

    setState(() => _busy = true);
    await ref.read(symptomRepositoryProvider).addSymptom(name);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _controller.clear();
    });
  }

  Future<void> _removeSymptom(CustomSymptom symptom) async {
    if (_busy) return;
    setState(() => _busy = true);
    await ref.read(symptomRepositoryProvider).deleteSymptom(symptom.id);
    if (!mounted) return;
    setState(() => _busy = false);
  }

  void _pop(int count) => Navigator.of(context).pop(count);

  @override
  Widget build(BuildContext context) {
    final symptomsAsync = ref.watch(customSymptomsProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final count = symptomsAsync.valueOrNull?.length ?? 0;
        _pop(count);
      },
      child: Scaffold(
        backgroundColor: RituColors.backgroundPage,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: IconButton(
                  onPressed: () {
                    final count = symptomsAsync.valueOrNull?.length ?? 0;
                    _pop(count);
                  },
                  icon: const Icon(
                    LucideIcons.chevronLeft,
                    size: 28,
                    color: RituColors.textPrimary,
                  ),
                ),
              ),
              Expanded(
                child: symptomsAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: RituColors.sage500),
                  ),
                  error: (error, _) => Center(child: Text('$error')),
                  data: (symptoms) => SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Add your own body signals',
                          style: GoogleFonts.dmSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            height: 24 / 18,
                            color: RituColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'These always show up in your daily log',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            height: 20 / 13,
                            color: RituColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (symptoms.isNotEmpty) ...[
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final symptom in symptoms)
                                RituDateChip(
                                  label: symptom.name,
                                  onRemove: () => _removeSymptom(symptom),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                        TextField(
                          controller: _controller,
                          textInputAction: TextInputAction.done,
                          onChanged: (_) => setState(() {}),
                          onSubmitted: (_) => _addSymptom(),
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            height: 24 / 15,
                            color: RituColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Name your signal',
                            hintStyle: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              height: 24 / 15,
                              color: RituColors.textDisabled,
                            ),
                            filled: true,
                            fillColor: RituColors.fillElevated,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: RituColors.borderSubtle,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: RituColors.borderSubtle,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: RituColors.sage500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedPillButton(
                          label: 'Add body signal',
                          onPressed: _canAdd ? _addSymptom : null,
                        ),
                      ],
                    ),
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
