import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../providers/daily_log_providers.dart';
import '../../providers/journal_entry_providers.dart';
import '../../providers/repository_providers.dart';
import 'apply_flow_period_effect.dart';
import '../../providers/symptom_providers.dart';
import '../../core/date_format.dart';
import '../../data/models/custom_symptom.dart';
import '../../data/models/daily_log_entry.dart';
import '../../data/models/journal_entry.dart';
import '../../theme/ritu_palette.dart';
import '../setup/widgets/choice_chips.dart';
import '../setup/widgets/progress_dots.dart';
import 'widgets/add_symptom_dialog.dart';
import 'widgets/discard_log_dialog.dart';
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
/// signals, notes). Structured answers upsert a
/// [lib/data/local/tables/daily_logs.dart] row; the notes step writes to
/// [lib/data/local/tables/journal_entries.dart] (Figma node-id 293-407 /
/// 293-485 / 293-624 / 308-762).
class DailyLogFlow extends ConsumerStatefulWidget {
  DailyLogFlow({super.key, DateTime? date})
    : date = dateOnly(date ?? DateTime.now());

  final DateTime date;

  @override
  ConsumerState<DailyLogFlow> createState() => _DailyLogFlowState();
}

class _DailyLogFlowState extends ConsumerState<DailyLogFlow> {
  int _step = 0;
  var _hydrated = false;
  var _saving = false;
  var _canPop = false;
  var _confirmingDiscard = false;
  var _hadExistingLog = false;
  var _wroteStructured = false;
  var _dbDiffersFromInitial = false;

  String? _initialFlow;
  int? _initialCramp;
  var _initialMoods = <String>{};
  String? _initialEnergy;
  String? _initialSleep;
  int? _initialWellbeing;
  var _initialSymptoms = <String>{};
  var _initialNotes = '';

  String? _flowIntensity;
  int? _crampIntensity;
  var _crampSet = false;
  final _moods = <String>{};
  String? _energyLevel;
  String? _sleepQuality;
  int? _wellbeing;
  var _wellbeingSet = false;
  final _symptoms = <String>{};
  var _customSymptomNames = const <String>[];
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _maybeHydrate(
    AsyncValue<DailyLogEntry?> logAsync,
    AsyncValue<JournalEntry?> journalAsync,
    AsyncValue<List<CustomSymptom>> symptomsAsync,
  ) {
    if (_hydrated ||
        logAsync.isLoading ||
        journalAsync.isLoading ||
        symptomsAsync.isLoading) {
      return;
    }
    _hydrated = true;

    _customSymptomNames =
        symptomsAsync.valueOrNull?.map((s) => s.name).toList() ?? [];
    final existing = logAsync.valueOrNull;
    _hadExistingLog = existing != null;
    if (existing != null) {
      _flowIntensity = existing.flowIntensity;
      _crampIntensity = existing.crampIntensity;
      _crampSet = existing.crampIntensity != null;
      _moods.addAll(existing.moods);
      _energyLevel = existing.energyLevel;
      _sleepQuality = existing.sleepQuality;
      _wellbeing = existing.wellbeing;
      _wellbeingSet = existing.wellbeing != null;
      _symptoms.addAll(existing.symptoms);
    }
    _notesController.text = journalAsync.valueOrNull?.body ?? '';
    _initialFlow = _flowIntensity;
    _initialCramp = _crampSet ? _crampIntensity : null;
    _initialMoods = Set.of(_moods);
    _initialEnergy = _energyLevel;
    _initialSleep = _sleepQuality;
    _initialWellbeing = _wellbeingSet ? _wellbeing : null;
    _initialSymptoms = Set.of(_symptoms);
    _initialNotes = _notesController.text.trim();
  }

  bool _sameMembers(Set<String> left, Set<String> right) {
    return left.length == right.length && left.containsAll(right);
  }

  int? get _persistedCramp => _crampSet ? _crampIntensity : null;

  int? get _persistedWellbeing => _wellbeingSet ? _wellbeing : null;

  bool get _structuredDiffersFromInitial =>
      _flowIntensity != _initialFlow ||
      _persistedCramp != _initialCramp ||
      !_sameMembers(_moods, _initialMoods) ||
      _energyLevel != _initialEnergy ||
      _sleepQuality != _initialSleep ||
      _persistedWellbeing != _initialWellbeing ||
      !_sameMembers(_symptoms, _initialSymptoms);

  bool get _shouldConfirmDiscard =>
      _structuredDiffersFromInitial ||
      _notesController.text.trim() != _initialNotes ||
      _dbDiffersFromInitial;

  bool get _hasStructuredAnswers =>
      _flowIntensity != null ||
      _crampIntensity != null ||
      _moods.isNotEmpty ||
      _energyLevel != null ||
      _sleepQuality != null ||
      _wellbeing != null ||
      _symptoms.isNotEmpty;

  List<String> get _symptomOptions => [
    ..._presetSymptoms,
    for (final name in _customSymptomNames)
      if (!_presetSymptoms.contains(name)) name,
  ];

  bool get _currentStepHasAnswers => switch (_step) {
    0 => _flowIntensity != null || _crampSet,
    1 =>
      _moods.isNotEmpty ||
          _energyLevel != null ||
          _sleepQuality != null ||
          _wellbeingSet,
    2 => _symptoms.isNotEmpty,
    _ => false,
  };

  Future<void> _persistCurrentStep() async {
    // Next writes the step only when something was chosen. An untouched
    // step, including a slider left at its empty display value, is not stored.
    if (!_currentStepHasAnswers) return;
    await _persistStructured();
  }

  Future<void> _persistStructured() async {
    await ref
        .read(dailyLogRepositoryProvider)
        .upsert(
          loggedOn: widget.date,
          flowIntensity: _flowIntensity,
          crampIntensity: _persistedCramp,
          moods: _moods.toList(),
          energyLevel: _energyLevel,
          sleepQuality: _sleepQuality,
          wellbeing: _persistedWellbeing,
          symptoms: _symptoms.toList(),
        );
    _wroteStructured = true;
    _dbDiffersFromInitial = _structuredDiffersFromInitial;
  }

  Future<void> _revertSessionWrite() async {
    if (!_wroteStructured || !_dbDiffersFromInitial) return;
    final repository = ref.read(dailyLogRepositoryProvider);
    if (!_hadExistingLog) {
      await repository.deleteByDate(widget.date);
      return;
    }
    await repository.upsert(
      loggedOn: widget.date,
      flowIntensity: _initialFlow,
      crampIntensity: _initialCramp,
      moods: _initialMoods.toList(),
      energyLevel: _initialEnergy,
      sleepQuality: _initialSleep,
      wellbeing: _initialWellbeing,
      symptoms: _initialSymptoms.toList(),
    );
  }

  Future<void> _advance() async {
    if (_saving) return;
    if (_step >= _totalSteps - 1) {
      await _save();
      return;
    }
    setState(() => _saving = true);
    try {
      await _persistCurrentStep();
      if (!mounted) return;
      setState(() => _step += 1);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _goBack() {
    if (_step == 0 || _saving) return;
    setState(() => _step -= 1);
  }

  Future<void> _close() async {
    if (_saving || _confirmingDiscard) return;
    if (_shouldConfirmDiscard) {
      setState(() => _confirmingDiscard = true);
      final discard = await showDiscardLogDialog(
        context,
        editing: _hadExistingLog,
      );
      if (!mounted) return;
      setState(() => _confirmingDiscard = false);
      if (!discard) return;
      await _revertSessionWrite();
      if (!mounted) return;
    }
    _leave(false);
  }

  void _leave(bool saved) {
    if (!mounted) return;
    setState(() => _canPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pop(saved);
    });
  }

  Future<void> _addOwnSymptom() async {
    final name = await showAddSymptomDialog(context);
    if (name == null || name.trim().isEmpty || !mounted) return;
    final added = await ref.read(symptomRepositoryProvider).addSymptom(name);
    if (!mounted || added == null) return;
    setState(() {
      if (!_customSymptomNames.contains(added.name)) {
        _customSymptomNames = [..._customSymptomNames, added.name];
      }
      _symptoms.add(added.name);
    });
  }

  Future<void> _syncPeriodFromFlow() async {
    final typical = (await ref.read(profileRepositoryProvider).getProfile())
        ?.typicalPeriodDays;
    await applyFlowPeriodEffect(
      periods: ref.read(periodRepositoryProvider),
      loggedOn: widget.date,
      flowIntensity: _flowIntensity,
      typicalPeriodDays: typical,
    );
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    final notes = _notesController.text.trim();
    final hasStructured = _hasStructuredAnswers;
    // Moving through every step without a selection does not create a log.
    if (!hasStructured && notes.isEmpty) {
      _leave(false);
      return;
    }

    if (hasStructured) {
      await _persistStructured();
      await _syncPeriodFromFlow();
    }
    if (notes.isNotEmpty) {
      await ref
          .read(journalEntryRepositoryProvider)
          .upsert(loggedOn: widget.date, body: notes);
    }
    _leave(true);
  }

  @override
  Widget build(BuildContext context) {
    final logAsync = ref.watch(dailyLogByDateProvider(widget.date));
    final journalAsync = ref.watch(journalEntryByDateProvider(widget.date));
    final symptomsAsync = ref.watch(customSymptomsProvider);
    _maybeHydrate(logAsync, journalAsync, symptomsAsync);

    return PopScope(
      canPop: _canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _goBack();
      },
      child: Scaffold(
        backgroundColor: context.ritu.backgroundPage,
        body: SafeArea(
          child: !_hydrated
              ? Center(
                  child: CircularProgressIndicator(color: context.ritu.sage500),
                )
              : Column(
                  children: [
                    const SizedBox(height: 8),
                    _LogHeader(step: _step, onBack: _goBack, onClose: _close),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
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
        crampIntensity: _crampIntensity ?? 0,
        onCrampChanged: (v) => setState(() {
          _crampIntensity = v;
          _crampSet = true;
        }),
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
        wellbeing: _wellbeing ?? 0,
        onWellbeingChanged: (v) => setState(() {
          _wellbeing = v;
          _wellbeingSet = true;
        }),
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
        heading: "Today's Reflection",
        subtitle: "Share anything you'd like to remember about today.",
        controller: _notesController,
      ),
    };
  }

  Widget _buildFooter() {
    final isLastStep = _step == _totalSteps - 1;
    final label = _hadExistingLog
        ? (isLastStep ? 'Save changes' : 'Done')
        : (isLastStep ? 'Save log' : 'Next');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(
            onPressed: _saving ? null : _advance,
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
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 24 / 15,
              ),
            ),
            child: Text(label),
          ),
        ),
      ],
    );
  }
}

class _LogHeader extends StatelessWidget {
  const _LogHeader({
    required this.step,
    required this.onBack,
    required this.onClose,
  });

  final int step;
  final VoidCallback onBack;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 24,
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: step == 0
                  ? null
                  : GestureDetector(
                      onTap: onBack,
                      behavior: HitTestBehavior.opaque,
                      child: Icon(
                        LucideIcons.chevronLeft,
                        size: 24,
                        color: context.ritu.iconPrimary,
                        semanticLabel: 'Back',
                      ),
                    ),
            ),
            Expanded(
              child: ProgressDots(
                currentStep: step + 1,
                totalSteps: _totalSteps,
              ),
            ),
            SizedBox(
              width: 24,
              height: 24,
              child: GestureDetector(
                onTap: onClose,
                behavior: HitTestBehavior.opaque,
                child: Icon(
                  LucideIcons.x,
                  size: 24,
                  color: context.ritu.iconPrimary,
                  semanticLabel: 'Close',
                ),
              ),
            ),
          ],
        ),
      ),
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
            color: context.ritu.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            height: 24 / 15,
            color: context.ritu.textSecondary,
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
          runSpacing: 16,
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
          runSpacing: 16,
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
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 16,
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
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 16,
          children: [
            for (final option in _sleepOptions)
              RituChoiceChip(
                label: option,
                selected: sleepQuality == option,
                onTap: () => onSleepSelected(option),
              ),
          ],
        ),
        const SizedBox(height: 20),
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
        color: context.ritu.textPrimary,
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
          runSpacing: 16,
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
              Icon(
                LucideIcons.plus,
                size: 16,
                color: context.ritu.textPositive,
              ),
              const SizedBox(width: 4),
              Text(
                'Add your own',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 20 / 13,
                  color: context.ritu.textPositive,
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
        const SizedBox(height: 16),
        Container(
          height: 140,
          decoration: BoxDecoration(
            color: context.ritu.fillElevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.ritu.borderSubtle),
          ),
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: controller,
            expands: true,
            maxLines: null,
            textAlignVertical: TextAlignVertical.top,
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              height: 24 / 15,
              color: context.ritu.textPrimary,
            ),
            decoration: InputDecoration(
              isCollapsed: true,
              filled: false,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              hintText: "What's on your mind.....",
              hintStyle: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                height: 24 / 15,
                color: context.ritu.textDisabled,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Every reflection is saved to your Journal',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 20 / 13,
              color: context.ritu.textTertiary,
            ),
          ),
        ),
      ],
    );
  }
}
