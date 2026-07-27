import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/app_scope.dart';
import '../../data/repositories/symptom_repository.dart';
import '../../theme/ritu_colors.dart';
import '../setup/widgets/choice_chips.dart';
import '../setup/widgets/setup_footer.dart';

/// Full-page custom symptom manager (Figma Settings → Custom Symptoms).
///
/// Additions and removals persist immediately — there's no separate Save.
class CustomSymptomsScreen extends StatefulWidget {
  const CustomSymptomsScreen({super.key});

  @override
  State<CustomSymptomsScreen> createState() => _CustomSymptomsScreenState();
}

class _CustomSymptomsScreenState extends State<CustomSymptomsScreen> {
  final _controller = TextEditingController();
  var _symptoms = const <CustomSymptom>[];
  var _loading = true;
  var _loadStarted = false;
  var _busy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadStarted) {
      _loadStarted = true;
      _load();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final symptoms = await AppScope.symptoms(context).getAll();
    if (!mounted) return;
    setState(() {
      _symptoms = symptoms;
      _loading = false;
    });
  }

  bool get _canAdd => !_busy && _controller.text.trim().isNotEmpty;

  Future<void> _addSymptom() async {
    final name = _controller.text.trim();
    if (name.isEmpty || _busy) return;

    setState(() => _busy = true);
    final added = await AppScope.symptoms(context).addSymptom(name);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _controller.clear();
      if (added != null && !_symptoms.any((s) => s.id == added.id)) {
        _symptoms = [..._symptoms, added];
      }
    });
  }

  Future<void> _removeSymptom(CustomSymptom symptom) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _symptoms = _symptoms.where((s) => s.id != symptom.id).toList();
    });
    await AppScope.symptoms(context).deleteSymptom(symptom.id);
    if (!mounted) return;
    setState(() => _busy = false);
  }

  void _pop() => Navigator.of(context).pop(_symptoms.length);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _pop();
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
                  onPressed: _pop,
                  icon: const Icon(
                    LucideIcons.chevronLeft,
                    size: 28,
                    color: RituColors.textPrimary,
                  ),
                ),
              ),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: RituColors.sage500,
                        ),
                      )
                    : SingleChildScrollView(
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
                            if (_symptoms.isNotEmpty) ...[
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final symptom in _symptoms)
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
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: RituColors.borderSubtle,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: RituColors.borderSubtle,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
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
            ],
          ),
        ),
      ),
    );
  }
}
