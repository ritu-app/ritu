import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/date_format.dart';
import '../../data/models/journal_entry.dart';
import '../../providers/journal_entry_providers.dart';
import '../../providers/period_providers.dart';
import '../../providers/simulated_today_provider.dart';
import '../../theme/ritu_colors.dart';
import '../journal/journal_entry_card.dart';
import '../setup/widgets/ritu_calendar.dart';
import 'summary_time_range.dart';

enum _SummaryPage { options, dates, journals }

enum _DateEndpoint { from, to }

/// Generate-summary sheet (Figma 965-3320, 973-4621, 984-3457, 984-3728).
Future<void> showGenerateSummarySheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0xB3000000),
    isScrollControlled: true,
    builder: (sheetContext) => const _GenerateSummarySheet(),
  );
}

class _GenerateSummarySheet extends ConsumerStatefulWidget {
  const _GenerateSummarySheet();

  @override
  ConsumerState<_GenerateSummarySheet> createState() =>
      _GenerateSummarySheetState();
}

class _GenerateSummarySheetState extends ConsumerState<_GenerateSummarySheet> {
  var _page = _SummaryPage.options;
  var _range = SummaryTimeRange.last3Months;
  DateTime? _customFrom;
  DateTime? _customTo;
  var _picking = _DateEndpoint.from;
  late DateTime _visibleMonth;

  var _cycleLength = true;
  var _moodPatterns = false;
  var _energyPatterns = false;
  var _bodySignals = false;
  var _sleepLogs = true;
  var _wellbeingScore = true;
  var _journalEntries = true;
  Set<int> _selectedJournalIds = {};
  Set<int> _journalDraft = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
  }

  void _openCustomDates(DateTime today) {
    final anchor = _customFrom ?? _customTo ?? today;
    setState(() {
      _page = _SummaryPage.dates;
      _picking = _customFrom == null ? _DateEndpoint.from : _DateEndpoint.to;
      _visibleMonth = DateTime(anchor.year, anchor.month);
    });
  }

  void _applyCustomRange() {
    final from = _customFrom;
    final to = _customTo;
    if (from == null || to == null) return;
    setState(() {
      if (dateOnly(to).isBefore(dateOnly(from))) {
        _customFrom = dateOnly(to);
        _customTo = dateOnly(from);
      }
      _range = SummaryTimeRange.custom;
      _page = _SummaryPage.options;
    });
  }

  void _onCalendarDate(DateTime date) {
    final day = dateOnly(date);
    setState(() {
      if (_picking == _DateEndpoint.from) {
        _customFrom = day;
        if (_customTo != null && dateOnly(_customTo!).isBefore(day)) {
          _customTo = null;
        }
        _picking = _DateEndpoint.to;
      } else {
        _customTo = day;
        if (_customFrom != null && day.isBefore(dateOnly(_customFrom!))) {
          final previousFrom = dateOnly(_customFrom!);
          _customFrom = day;
          _customTo = previousFrom;
          _picking = _DateEndpoint.to;
        }
      }
      _visibleMonth = DateTime(day.year, day.month);
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = dateOnly(ref.watch(simulatedTodayProvider));
    final periods = ref.watch(allPeriodsProvider).valueOrNull ?? const [];
    final entries =
        ref.watch(allJournalEntriesProvider).valueOrNull ?? const [];
    final periodStarts = [for (final period in periods) period.startedOn];
    final window = summaryWindow(
      range: _range,
      today: today,
      periodStarts: periodStarts,
      customFrom: _customFrom,
      customTo: _customTo,
    );
    final inRange = [
      for (final entry in entries)
        if (window.contains(entry.loggedOn)) entry,
    ];
    final inRangeIds = {for (final entry in inRange) entry.id};
    final selectedInRange = _selectedJournalIds.intersection(inRangeIds);

    final media = MediaQuery.of(context);
    final maxHeight = media.size.height * 0.92;
    final pageHeight = maxHeight - media.padding.bottom;

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Material(
          color: RituColors.backgroundPage,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            side: BorderSide(color: RituColors.borderSubtle),
          ),
          clipBehavior: Clip.antiAlias,
          child: SafeArea(
            top: false,
            child: switch (_page) {
              _SummaryPage.options => SizedBox(
                height: pageHeight,
                child: _OptionsPage(
                  range: _range,
                  journalCount: selectedInRange.length,
                  cycleLength: _cycleLength,
                  moodPatterns: _moodPatterns,
                  energyPatterns: _energyPatterns,
                  bodySignals: _bodySignals,
                  sleepLogs: _sleepLogs,
                  wellbeingScore: _wellbeingScore,
                  journalEntries: _journalEntries,
                  onClose: () => Navigator.of(context).pop(),
                  onRange: (range) {
                    if (range == SummaryTimeRange.custom) {
                      _openCustomDates(today);
                      return;
                    }
                    setState(() => _range = range);
                  },
                  onToggleCycle: () =>
                      setState(() => _cycleLength = !_cycleLength),
                  onToggleMood: () =>
                      setState(() => _moodPatterns = !_moodPatterns),
                  onToggleEnergy: () =>
                      setState(() => _energyPatterns = !_energyPatterns),
                  onToggleBody: () =>
                      setState(() => _bodySignals = !_bodySignals),
                  onToggleSleep: () => setState(() => _sleepLogs = !_sleepLogs),
                  onToggleWellbeing: () =>
                      setState(() => _wellbeingScore = !_wellbeingScore),
                  onToggleJournal: () =>
                      setState(() => _journalEntries = !_journalEntries),
                  onChooseJournals: () => setState(() {
                    _journalDraft = {...selectedInRange};
                    _page = _SummaryPage.journals;
                  }),
                ),
              ),
              _SummaryPage.dates => _DateRangePage(
                from: _customFrom,
                to: _customTo,
                picking: _picking,
                visibleMonth: _visibleMonth,
                today: today,
                onBack: () => setState(() => _page = _SummaryPage.options),
                onPickFrom: () => setState(() {
                  _picking = _DateEndpoint.from;
                  final anchor = _customFrom;
                  if (anchor != null) {
                    _visibleMonth = DateTime(anchor.year, anchor.month);
                  }
                }),
                onPickTo: () => setState(() {
                  _picking = _DateEndpoint.to;
                  final anchor = _customTo;
                  if (anchor != null) {
                    _visibleMonth = DateTime(anchor.year, anchor.month);
                  }
                }),
                onMonthChanged: (month) =>
                    setState(() => _visibleMonth = month),
                onDateSelected: _onCalendarDate,
                onConfirm: _customFrom != null && _customTo != null
                    ? _applyCustomRange
                    : null,
              ),
              _SummaryPage.journals => SizedBox(
                height: pageHeight,
                child: _JournalPickerPage(
                  entries: inRange,
                  selectedIds: _journalDraft,
                  rangePhrase: summaryRangePhrase(
                    range: _range,
                    customFrom: _customFrom,
                    customTo: _customTo,
                  ),
                  onClose: () => setState(() => _page = _SummaryPage.options),
                  onToggle: (id) {
                    setState(() {
                      if (_journalDraft.contains(id)) {
                        _journalDraft.remove(id);
                      } else {
                        _journalDraft.add(id);
                      }
                    });
                  },
                  onAdd: _journalDraft.isEmpty
                      ? null
                      : () => setState(() {
                          _selectedJournalIds = {..._journalDraft};
                          _journalEntries = true;
                          _page = _SummaryPage.options;
                        }),
                ),
              ),
            },
          ),
        ),
      ),
    );
  }
}

class _OptionsPage extends StatelessWidget {
  const _OptionsPage({
    required this.range,
    required this.journalCount,
    required this.cycleLength,
    required this.moodPatterns,
    required this.energyPatterns,
    required this.bodySignals,
    required this.sleepLogs,
    required this.wellbeingScore,
    required this.journalEntries,
    required this.onClose,
    required this.onRange,
    required this.onToggleCycle,
    required this.onToggleMood,
    required this.onToggleEnergy,
    required this.onToggleBody,
    required this.onToggleSleep,
    required this.onToggleWellbeing,
    required this.onToggleJournal,
    required this.onChooseJournals,
  });

  final SummaryTimeRange range;
  final int journalCount;
  final bool cycleLength;
  final bool moodPatterns;
  final bool energyPatterns;
  final bool bodySignals;
  final bool sleepLogs;
  final bool wellbeingScore;
  final bool journalEntries;
  final VoidCallback onClose;
  final ValueChanged<SummaryTimeRange> onRange;
  final VoidCallback onToggleCycle;
  final VoidCallback onToggleMood;
  final VoidCallback onToggleEnergy;
  final VoidCallback onToggleBody;
  final VoidCallback onToggleSleep;
  final VoidCallback onToggleWellbeing;
  final VoidCallback onToggleJournal;
  final VoidCallback onChooseJournals;

  @override
  Widget build(BuildContext context) {
    final journalSubtitle = journalCount == 0
        ? 'Tap to choose which ones'
        : '${_entryCount(journalCount)} selected · Tap to edit';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SheetHeader(
                  title: 'Generate summary',
                  subtitle: 'Choose what to include in your summary',
                  onClose: onClose,
                ),
                const SizedBox(height: 16),
                const _SectionLabel('Time range'),
                const SizedBox(height: 8),
                _OptionCard(
                  children: [
                    for (var i = 0; i < SummaryTimeRange.values.length; i++)
                      _ChoiceRow(
                        label: SummaryTimeRange.values[i].label,
                        selected: range == SummaryTimeRange.values[i],
                        radio: true,
                        showDivider: i < SummaryTimeRange.values.length - 1,
                        onTap: () => onRange(SummaryTimeRange.values[i]),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                const _SectionLabel('Includes'),
                const SizedBox(height: 8),
                _OptionCard(
                  children: [
                    _ChoiceRow(
                      label: 'Cycle length',
                      selected: cycleLength,
                      showDivider: true,
                      onTap: onToggleCycle,
                    ),
                    _ChoiceRow(
                      label: 'Mood patterns',
                      selected: moodPatterns,
                      showDivider: true,
                      onTap: onToggleMood,
                    ),
                    _ChoiceRow(
                      label: 'Energy patterns',
                      selected: energyPatterns,
                      showDivider: true,
                      onTap: onToggleEnergy,
                    ),
                    _ChoiceRow(
                      label: 'Body signals',
                      selected: bodySignals,
                      showDivider: true,
                      onTap: onToggleBody,
                    ),
                    _ChoiceRow(
                      label: 'Sleep logs',
                      selected: sleepLogs,
                      showDivider: true,
                      onTap: onToggleSleep,
                    ),
                    _ChoiceRow(
                      label: 'Wellbeing score',
                      selected: wellbeingScore,
                      showDivider: true,
                      onTap: onToggleWellbeing,
                    ),
                    _ChoiceRow(
                      label: 'Journal entries',
                      subtitle: journalSubtitle,
                      subtitleColor: journalCount == 0
                          ? RituColors.textTertiary
                          : RituColors.sage600,
                      selected: journalEntries,
                      trailing: const Icon(
                        LucideIcons.chevronRight,
                        size: 16,
                        color: RituColors.textPrimary,
                      ),
                      onTap: onChooseJournals,
                      onMarkTap: onToggleJournal,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: FilledButton(
            onPressed: () {},
            child: const Text('Generate PDF'),
          ),
        ),
      ],
    );
  }
}

class _DateRangePage extends StatelessWidget {
  const _DateRangePage({
    required this.from,
    required this.to,
    required this.picking,
    required this.visibleMonth,
    required this.today,
    required this.onBack,
    required this.onPickFrom,
    required this.onPickTo,
    required this.onMonthChanged,
    required this.onDateSelected,
    required this.onConfirm,
  });

  final DateTime? from;
  final DateTime? to;
  final _DateEndpoint picking;
  final DateTime visibleMonth;
  final DateTime today;
  final VoidCallback onBack;
  final VoidCallback onPickFrom;
  final VoidCallback onPickTo;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    final activeDate = picking == _DateEndpoint.from ? from : to;

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: onBack,
              behavior: HitTestBehavior.opaque,
              child: const SizedBox(
                width: 24,
                height: 24,
                child: Icon(
                  LucideIcons.chevronLeft,
                  size: 24,
                  color: RituColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Select date range',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 24 / 18,
                  color: RituColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _DateField(
              label: 'From',
              value: from == null ? null : formatShortMonthDayYear(from!),
              active: picking == _DateEndpoint.from,
              onTap: onPickFrom,
            ),
            const SizedBox(width: 40),
            _DateField(
              label: 'To',
              value: to == null ? null : formatShortMonthDayYear(to!),
              active: picking == _DateEndpoint.to,
              onTap: onPickTo,
            ),
          ],
        ),
        const SizedBox(height: 16),
        RituCalendar(
          month: visibleMonth,
          selectedDate: activeDate,
          maxSelectableDate: today,
          onMonthChanged: onMonthChanged,
          onDateSelected: onDateSelected,
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: onConfirm,
          style: FilledButton.styleFrom(
            backgroundColor: RituColors.sage500,
            disabledBackgroundColor: RituColors.fillSecondaryHover,
            foregroundColor: RituColors.white,
            disabledForegroundColor: RituColors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 48),
            shape: const StadiumBorder(),
            textStyle: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 24 / 15,
            ),
          ),
          child: const Text('Confirm range'),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.active,
    required this.onTap,
  });

  final String label;
  final String? value;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 120,
        height: 55,
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 7),
        decoration: BoxDecoration(
          color: active ? RituColors.fillSecondary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? RituColors.sage600 : RituColors.borderDisabled,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                height: 18 / 11,
                color: RituColors.textSecondary,
              ),
            ),
            Text(
              value ?? 'Select date',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 20 / 13,
                color: value == null
                    ? RituColors.textTertiary
                    : active
                    ? RituColors.sage600
                    : RituColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JournalPickerPage extends StatelessWidget {
  const _JournalPickerPage({
    required this.entries,
    required this.selectedIds,
    required this.rangePhrase,
    required this.onClose,
    required this.onToggle,
    required this.onAdd,
  });

  final List<JournalEntry> entries;
  final Set<int> selectedIds;
  final String rangePhrase;
  final VoidCallback onClose;
  final ValueChanged<int> onToggle;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final groups = _groupByMonth(entries);
    final count = selectedIds.length;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            children: [
              _SheetHeader(
                title: 'Choose journal entries',
                subtitle: 'Showing entries from $rangePhrase',
                onClose: onClose,
              ),
              const SizedBox(height: 16),
              if (groups.isEmpty)
                Text(
                  'No journal entries in this range',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 20 / 13,
                    color: RituColors.textSecondary,
                  ),
                )
              else
                for (var i = 0; i < groups.length; i++) ...[
                  if (i > 0) const SizedBox(height: 16),
                  Text(
                    formatMonthYear(groups[i].month),
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 24 / 15,
                      color: RituColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (var j = 0; j < groups[i].entries.length; j++) ...[
                    if (j > 0) const SizedBox(height: 8),
                    _JournalSelectRow(
                      entry: groups[i].entries[j],
                      selected: selectedIds.contains(groups[i].entries[j].id),
                      onToggle: () => onToggle(groups[i].entries[j].id),
                    ),
                  ],
                ],
              const SizedBox(height: 16),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: FilledButton(
            onPressed: onAdd,
            child: Text(count == 1 ? 'Add 1 entry' : 'Add $count entries'),
          ),
        ),
      ],
    );
  }
}

class _MonthGroup {
  const _MonthGroup({required this.month, required this.entries});

  final DateTime month;
  final List<JournalEntry> entries;
}

List<_MonthGroup> _groupByMonth(List<JournalEntry> entries) {
  final grouped = <DateTime, List<JournalEntry>>{};
  for (final entry in entries) {
    final month = DateTime(entry.loggedOn.year, entry.loggedOn.month);
    grouped.putIfAbsent(month, () => []).add(entry);
  }
  final months = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
  return [
    for (final month in months)
      _MonthGroup(
        month: month,
        entries: [...grouped[month]!]
          ..sort((a, b) => a.loggedOn.compareTo(b.loggedOn)),
      ),
  ];
}

class _JournalSelectRow extends StatelessWidget {
  const _JournalSelectRow({
    required this.entry,
    required this.selected,
    required this.onToggle,
  });

  final JournalEntry entry;
  final bool selected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onToggle,
          behavior: HitTestBehavior.opaque,
          child: _CheckMark(selected: selected, size: 24),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: JournalEntryCard(entry: entry, showMenu: false),
          ),
        ),
      ],
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({
    required this.title,
    required this.subtitle,
    required this.onClose,
  });

  final String title;
  final String subtitle;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 24 / 18,
                  color: RituColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  height: 20 / 13,
                  color: RituColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onClose,
          behavior: HitTestBehavior.opaque,
          child: const SizedBox(
            width: 24,
            height: 24,
            child: Icon(LucideIcons.x, size: 24, color: RituColors.textPrimary),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 24 / 15,
        color: RituColors.textPrimary,
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RituColors.fillElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RituColors.borderSubtle),
      ),
      child: Column(children: children),
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.label,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.subtitleColor = RituColors.textTertiary,
    this.radio = false,
    this.showDivider = false,
    this.trailing,
    this.onMarkTap,
  });

  final String label;
  final String? subtitle;
  final Color subtitleColor;
  final bool selected;
  final bool radio;
  final bool showDivider;
  final Widget? trailing;
  final VoidCallback onTap;
  final VoidCallback? onMarkTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: showDivider
              ? const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: RituColors.borderSubtle,
                      width: 0.5,
                    ),
                  ),
                )
              : null,
          child: Row(
            children: [
              GestureDetector(
                onTap: onMarkTap ?? onTap,
                behavior: HitTestBehavior.opaque,
                child: radio
                    ? _RadioMark(selected: selected)
                    : _CheckMark(selected: selected, size: 16),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        height: 20 / 13,
                        color: RituColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          height: 18 / 11,
                          color: subtitleColor,
                        ),
                      ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _RadioMark extends StatelessWidget {
  const _RadioMark({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    if (selected) {
      return Container(
        width: 16,
        height: 16,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: RituColors.sage600),
        ),
        child: Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: RituColors.fillBrandPressed,
            shape: BoxShape.circle,
          ),
        ),
      );
    }

    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: RituColors.textDisabled),
      ),
    );
  }
}

class _CheckMark extends StatelessWidget {
  const _CheckMark({required this.selected, required this.size});

  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (selected) {
      return Icon(
        LucideIcons.circleCheck,
        size: size,
        color: RituColors.sage500,
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: RituColors.textDisabled),
      ),
    );
  }
}

String _entryCount(int count) => count == 1 ? '1 entry' : '$count entries';
