import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/app_scope.dart';
import '../../core/date_format.dart';
import '../../theme/ritu_colors.dart';
import '../setup/widgets/choice_chips.dart';
import '../setup/widgets/progress_dots.dart';
import 'widgets/add_symptom_dialog.dart';
import 'widgets/log_slider_card.dart';

const _flowOptions = ['None', 'Spotting', 'Light', 'Medium', 'Heavy'];
const _moodOptions = [
  'Calm',
  'Irritable',
  'Focused',
  'Anxious',
  'Flat',
  'Sad',
  'Happy',
  'Overwhelmed',
  'Content',
  'Restless',
];
const _energyOptions = ['Drained', 'Low', 'Moderate', 'High', 'Vibrant'];
const _sleepOptions = ['Poor', 'Restless', 'Okay', 'Good', 'Great'];
const _presetSymptoms = [
  'Bloating',
  'Headache',
  'Acne',
  'Tender chest',
  'Back pain',
  'Nausea',
  'Brain fog',
  'Dry skin',
  'Craving sweets',
  'Craving salt',
  'Swollen fingers',
  'Pelvic pressure',
  'Sensitivity to light',
];

const _totalSteps = 4;

/// Home "Log today" daily check-in — a 4-step wizard (flow, mood, body
/// signals, notes) that upserts a single [lib/data/local/tables/daily_logs.dart]
/// row for the given day (Figma node-id 293-407 / 293-485 / 293-624 / 308-762).
class DailyLogFlow extends StatefulWidget {
  DailyLogFlow({super.key, DateTime? date})
    : date = dateOnly(date ?? DateTime.now());

  final DateTime date;

  @override
  State<DailyLogFlow> createState() => _DailyLogFlowState();
}

class _DailyLogFlowState extends State<DailyLogFlow> {
  int _step = 0;
  var _loading = true;
  var _loadStarted = false;
  var _saving = false;

  String? _flowIntensity;
  int _crampIntensity = 0;
  final _moods = <String>{};
  String? _energyLevel;
  String? _sleepQuality;
  int _wellbeing = 0;
  final _symptoms = <String>{};
  var _customSymptomNames = const <String>[];
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
  }

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
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final dailyLogs = AppScope.dailyLogs(context);
    final symptoms = AppScope.symptoms(context);
    final existing = await dailyLogs.getByDate(widget.date);
    final customSymptoms = await symptoms.getAll();
    if (!mounted) return;
    setState(() {
      _customSymptomNames = customSymptoms.map((s) => s.name).toList();
      if (existing != null) {
        _flowIntensity = existing.flowIntensity;
        _crampIntensity = existing.crampIntensity ?? 0;
        _moods.addAll(existing.moods);
        _energyLevel = existing.energyLevel;
        _sleepQuality = existing.sleepQuality;
        _wellbeing = existing.wellbeing ?? 0;
        _symptoms.addAll(existing.symptoms);
        _notesController.text = existing.notes ?? '';
      }
      _loading = false;
    });
  }

  List<String> get _symptomOptions => [
    ..._presetSymptoms,
    for (final name in _customSymptomNames)
      if (!_presetSymptoms.contains(name)) name,
  ];

  void _goNext() {
    if (_step >= _totalSteps - 1) return;
    setState(() => _step += 1);
  }

  void _goBack() {
    if (_step == 0) {
      Navigator.of(context).pop(false);
      return;
    }
    setState(() => _step -= 1);
  }

  Future<void> _addOwnSymptom() async {
    final name = await showAddSymptomDialog(context);
    if (name == null || name.trim().isEmpty || !mounted) return;
    final added = await AppScope.symptoms(context).addSymptom(name);
    if (!mounted || added == null) return;
    setState(() {
      if (!_customSymptomNames.contains(added.name)) {
        _customSymptomNames = [..._customSymptomNames, added.name];
      }
      _symptoms.add(added.name);
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    await AppScope.dailyLogs(context).upsert(
      loggedOn: widget.date,
      flowIntensity: _flowIntensity,
      crampIntensity: _crampIntensity,
      moods: _moods.toList(),
      energyLevel: _energyLevel,
      sleepQuality: _sleepQuality,
      wellbeing: _wellbeing,
      symptoms: _symptoms.toList(),
      notes: _notesController.text,
    );
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _goBack();
      },
      child: Scaffold(
        backgroundColor: RituColors.backgroundPage,
        body: SafeArea(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: RituColors.sage500),
                )
              : Column(
                  children: [
                    const SizedBox(height: 16),
                    ProgressDots(
                      currentStep: _step + 1,
                      totalSteps: _totalSteps,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        child: _buildStep(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: _buildFooter(),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    return switch (_step) {
      0 => _FlowStep(
        heading: 'Any flow today?',
        subtitle: 'Tap one, or skip this step entirely',
        selected: _flowIntensity,
        onSelected: (v) => setState(() => _flowIntensity = v),
        crampIntensity: _crampIntensity,
        onCrampChanged: (v) => setState(() => _crampIntensity = v),
      ),
      1 => _MoodStep(
        heading: 'How are you feeling?',
        subtitle: 'Pick all that feel true',
        moods: _moods,
        onMoodToggled: (v) => setState(() {
          if (!_moods.remove(v)) _moods.add(v);
        }),
        energyLevel: _energyLevel,
        onEnergySelected: (v) => setState(() => _energyLevel = v),
        sleepQuality: _sleepQuality,
        onSleepSelected: (v) => setState(() => _sleepQuality = v),
        wellbeing: _wellbeing,
        onWellbeingChanged: (v) => setState(() => _wellbeing = v),
      ),
      2 => _BodySignalsStep(
        heading: 'Any body signals?',
        subtitle: 'Tap everything that applies',
        options: _symptomOptions,
        selected: _symptoms,
        onToggled: (v) => setState(() {
          if (!_symptoms.remove(v)) _symptoms.add(v);
        }),
        onAddOwn: _addOwnSymptom,
      ),
      _ => _NotesStep(
        heading: 'Notes',
        subtitle:
            "Share anything you'd like to remember about today. Ritu learns "
            'from these entries to identify patterns over time',
        controller: _notesController,
      ),
    };
  }

  Widget _buildFooter() {
    final isLastStep = _step == _totalSteps - 1;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(
            onPressed: isLastStep ? (_saving ? null : _save) : _goNext,
            style: FilledButton.styleFrom(
              backgroundColor: RituColors.sage500,
              disabledBackgroundColor: RituColors.sage500.withValues(
                alpha: 0.4,
              ),
              foregroundColor: RituColors.white,
              disabledForegroundColor: RituColors.white,
              elevation: 0,
              padding: EdgeInsets.zero,
              shape: const StadiumBorder(),
              textStyle: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 24 / 15,
              ),
            ),
            child: Text(isLastStep ? 'Save log' : 'Next'),
          ),
        ),
        if (!isLastStep) ...[
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _goNext,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'Skip',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 24 / 15,
                  color: RituColors.textTertiary,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.heading, required this.subtitle});

  final String heading;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: GoogleFonts.dmSans(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            height: 26 / 22,
            color: RituColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            height: 24 / 15,
            color: RituColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _FlowStep extends StatelessWidget {
  const _FlowStep({
    required this.heading,
    required this.subtitle,
    required this.selected,
    required this.onSelected,
    required this.crampIntensity,
    required this.onCrampChanged,
  });

  final String heading;
  final String subtitle;
  final String? selected;
  final ValueChanged<String> onSelected;
  final int crampIntensity;
  final ValueChanged<int> onCrampChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepHeader(heading: heading, subtitle: subtitle),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in _flowOptions)
              RituChoiceChip(
                label: option,
                selected: selected == option,
                onTap: () => onSelected(option),
              ),
          ],
        ),
        const SizedBox(height: 16),
        LogSliderCard(
          title: 'Cramp intensity',
          value: crampIntensity,
          labels: const ['None', 'Moderate', 'Intense'],
          onChanged: onCrampChanged,
        ),
      ],
    );
  }
}

class _MoodStep extends StatelessWidget {
  const _MoodStep({
    required this.heading,
    required this.subtitle,
    required this.moods,
    required this.onMoodToggled,
    required this.energyLevel,
    required this.onEnergySelected,
    required this.sleepQuality,
    required this.onSleepSelected,
    required this.wellbeing,
    required this.onWellbeingChanged,
  });

  final String heading;
  final String subtitle;
  final Set<String> moods;
  final ValueChanged<String> onMoodToggled;
  final String? energyLevel;
  final ValueChanged<String> onEnergySelected;
  final String? sleepQuality;
  final ValueChanged<String> onSleepSelected;
  final int wellbeing;
  final ValueChanged<int> onWellbeingChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepHeader(heading: heading, subtitle: subtitle),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in _moodOptions)
              RituChoiceChip(
                label: option,
                selected: moods.contains(option),
                onTap: () => onMoodToggled(option),
              ),
          ],
        ),
        const SizedBox(height: 20),
        _SectionLabel('Energy level'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in _energyOptions)
              RituChoiceChip(
                label: option,
                selected: energyLevel == option,
                onTap: () => onEnergySelected(option),
              ),
          ],
        ),
        const SizedBox(height: 20),
        _SectionLabel('Sleep last night'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in _sleepOptions)
              RituChoiceChip(
                label: option,
                selected: sleepQuality == option,
                onTap: () => onSleepSelected(option),
              ),
          ],
        ),
        const SizedBox(height: 16),
        LogSliderCard(
          title: 'Overall wellbeing',
          value: wellbeing,
          labels: const ['Struggling', 'Thriving'],
          onChanged: onWellbeingChanged,
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 24 / 15,
        color: RituColors.textPrimary,
      ),
    );
  }
}

class _BodySignalsStep extends StatelessWidget {
  const _BodySignalsStep({
    required this.heading,
    required this.subtitle,
    required this.options,
    required this.selected,
    required this.onToggled,
    required this.onAddOwn,
  });

  final String heading;
  final String subtitle;
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onToggled;
  final VoidCallback onAddOwn;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepHeader(heading: heading, subtitle: subtitle),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in options)
              RituChoiceChip(
                label: option,
                selected: selected.contains(option),
                onTap: () => onToggled(option),
              ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onAddOwn,
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                LucideIcons.plus,
                size: 16,
                color: RituColors.textPositive,
              ),
              const SizedBox(width: 4),
              Text(
                'Add your own',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 20 / 13,
                  color: RituColors.textPositive,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NotesStep extends StatelessWidget {
  const _NotesStep({
    required this.heading,
    required this.subtitle,
    required this.controller,
  });

  final String heading;
  final String subtitle;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepHeader(heading: heading, subtitle: subtitle),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: RituColors.fillElevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: RituColors.borderSubtle),
          ),
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: controller,
            minLines: 5,
            maxLines: 8,
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              height: 24 / 15,
              color: RituColors.textPrimary,
            ),
            decoration: InputDecoration(
              isCollapsed: true,
              border: InputBorder.none,
              hintText: "What's on your mind.....",
              hintStyle: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                height: 24 / 15,
                color: RituColors.textDisabled,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Every note is saved to your Journal',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 20 / 13,
              color: RituColors.textTertiary,
            ),
          ),
        ),
      ],
    );
  }
}
