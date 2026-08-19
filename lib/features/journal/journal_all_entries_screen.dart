import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/date_format.dart';
import '../../data/repositories/journal_entry_repository.dart';
import '../../providers/journal_entry_providers.dart';
import '../../providers/repository_providers.dart';
import '../../providers/simulated_today_provider.dart';
import '../../theme/ritu_colors.dart';
import 'journal_calendar_sheet.dart';
import 'journal_delete_dialog.dart';
import 'journal_entry_card.dart';
import 'journal_time_range.dart';
import 'journal_time_range_sheet.dart';

class JournalAllEntriesScreen extends ConsumerStatefulWidget {
  const JournalAllEntriesScreen({
    super.key,
    this.onBack,
    this.onSelectionModeChanged,
  });

  /// When set (Journal tab embed), back uses this instead of [Navigator.pop]
  /// so the home bottom nav stays visible.
  final VoidCallback? onBack;

  /// Notifies Home when multi-select should hide the tab bar.
  final ValueChanged<bool>? onSelectionModeChanged;

  @override
  ConsumerState<JournalAllEntriesScreen> createState() =>
      _JournalAllEntriesScreenState();
}

class _JournalAllEntriesScreenState
    extends ConsumerState<JournalAllEntriesScreen> {
  static const _borderDefault = Color(0xFFE2DDD8);

  final _searchController = TextEditingController();
  var _query = '';
  var _menuOpen = false;
  var _selecting = false;
  final _selectedIds = <int>{};
  JournalTimeRange? _timeRange;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (_selecting) {
      _exitSelectMode();
      return;
    }
    if (widget.onBack != null) {
      widget.onBack!();
      return;
    }
    Navigator.of(context).pop();
  }

  void _closeMenu() {
    if (!_menuOpen) return;
    setState(() => _menuOpen = false);
  }

  bool get _hasActiveFilter => _timeRange != null || _selectedDate != null;

  void _enterSelectMode() {
    _closeMenu();
    if (_selecting) return;
    setState(() {
      _selecting = true;
      _selectedIds.clear();
    });
    widget.onSelectionModeChanged?.call(true);
  }

  void _exitSelectMode() {
    if (!_selecting) return;
    setState(() {
      _selecting = false;
      _selectedIds.clear();
    });
    widget.onSelectionModeChanged?.call(false);
  }

  void _toggleSelected(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _deleteSelected() async {
    final ids = _selectedIds.toList();
    if (ids.isEmpty) return;

    final confirmed = await showJournalDeleteDialog(
      context,
      count: ids.length,
    );
    if (!confirmed || !mounted) return;

    final repo = ref.read(journalEntryRepositoryProvider);
    for (final id in ids) {
      await repo.delete(id);
    }
    if (!mounted) return;
    _exitSelectMode();
  }

  Future<void> _openTimeRangeFilter() async {
    _closeMenu();
    final selected = await showJournalTimeRangeSheet(
      context,
      selected: _timeRange,
    );
    if (!mounted || selected == null) return;
    setState(() {
      _timeRange = selected;
      _selectedDate = null;
    });
  }

  Future<void> _openCalendarFilter(List<JournalEntry> pastEntries) async {
    _closeMenu();
    final today = ref.read(simulatedTodayProvider);
    final entryDates = {
      for (final entry in pastEntries) dateOnly(entry.loggedOn),
    };
    final selected = await showJournalCalendarSheet(
      context,
      selectedDate: _selectedDate,
      maxSelectableDate: today,
      entryDates: entryDates,
    );
    if (!mounted || selected == null) return;
    setState(() {
      _selectedDate = selected;
      _timeRange = null;
    });
  }

  List<_MonthGroup> _groupByMonth(List<JournalEntry> entries) {
    final groups = <_MonthGroup>[];
    for (final entry in entries) {
      final key = DateTime(entry.loggedOn.year, entry.loggedOn.month);
      if (groups.isEmpty ||
          groups.last.month.year != key.year ||
          groups.last.month.month != key.month) {
        groups.add(_MonthGroup(month: key, entries: [entry]));
      } else {
        groups.last.entries.add(entry);
      }
    }
    return groups;
  }

  List<JournalEntry> _filtered(
    List<JournalEntry> entries, {
    required DateTime today,
  }) {
    var result = entries;
    final selected = _selectedDate;
    if (selected != null) {
      result = result
          .where((entry) => isSameCalendarDay(entry.loggedOn, selected))
          .toList();
    } else {
      final rangeStart = _timeRange?.startOnOrAfter(today);
      if (rangeStart != null) {
        result = result
            .where(
              (entry) =>
                  !dateOnly(entry.loggedOn).isBefore(dateOnly(rangeStart)),
            )
            .toList();
      }
    }
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return result;
    return result
        .where((entry) => entry.body.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final pastAsync = ref.watch(pastJournalEntriesProvider);
    final today = ref.watch(simulatedTodayProvider);
    final pastEntries = pastAsync.valueOrNull ?? const [];
    final filtered = _filtered(pastEntries, today: today);
    final groups = _groupByMonth(filtered);

    // Figma 865:3175 — header top 8px in safe area; menu flush under icons.
    const headerTop = 8.0;
    const headerHeight = 25.0;

    return ColoredBox(
      color: RituColors.backgroundPage,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, headerTop, 16, 0),
                child: _AllEntriesHeader(
                  onBack: _handleBack,
                  menuEnabled: !_selecting,
                  onMenuTap: () => setState(() => _menuOpen = !_menuOpen),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _SearchField(
                  controller: _searchController,
                  borderColor: _borderDefault,
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: pastAsync.isLoading && pastEntries.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: RituColors.sage500,
                        ),
                      )
                    : filtered.isEmpty
                    ? Center(
                        child: Text(
                          _query.trim().isEmpty && !_hasActiveFilter
                              ? 'No past entries yet'
                              : 'No matching entries',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: RituColors.textSecondary,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          0,
                          16,
                          _selecting ? 16 : 24,
                        ),
                        itemCount: groups.length,
                        itemBuilder: (context, index) {
                          final group = groups[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index == groups.length - 1 ? 0 : 24,
                            ),
                            child: _MonthSection(
                              group: group,
                              selecting: _selecting,
                              selectedIds: _selectedIds,
                              onToggle: _toggleSelected,
                            ),
                          );
                        },
                      ),
              ),
              if (_selecting)
                _SelectionActionBar(
                  selectedCount: _selectedIds.length,
                  onCancel: _exitSelectMode,
                  onDelete: _deleteSelected,
                ),
            ],
          ),
          if (_menuOpen && !_selecting) ...[
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _closeMenu,
              ),
            ),
            // Figma 865:3277 — flush under header, overlaps search, right = 16.
            Positioned(
              top: headerTop + headerHeight,
              right: 16,
              child: _AllEntriesOverflowMenu(
                borderColor: _borderDefault,
                onFilter: _openTimeRangeFilter,
                onCalendar: () => _openCalendarFilter(pastEntries),
                onSelectEntries: _enterSelectMode,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AllEntriesHeader extends StatelessWidget {
  const _AllEntriesHeader({
    required this.onBack,
    required this.onMenuTap,
    this.menuEnabled = true,
  });

  final VoidCallback onBack;
  final VoidCallback onMenuTap;
  final bool menuEnabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 25,
      child: Row(
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
              'All entries',
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                height: 25 / 18,
                color: RituColors.textPrimary,
              ),
            ),
          ),
          GestureDetector(
            onTap: menuEnabled ? onMenuTap : null,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 24,
              height: 24,
              child: Icon(
                LucideIcons.ellipsis,
                size: 24,
                color: menuEnabled
                    ? RituColors.textPrimary
                    : RituColors.textDisabled,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Figma 865:3277 — cream panel, 12px pad/gap, radius-md (12px).
class _AllEntriesOverflowMenu extends StatelessWidget {
  const _AllEntriesOverflowMenu({
    required this.borderColor,
    required this.onFilter,
    required this.onCalendar,
    required this.onSelectEntries,
  });

  final Color borderColor;
  final VoidCallback onFilter;
  final VoidCallback onCalendar;
  final VoidCallback onSelectEntries;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: ConstrainedBox(
        // Figma frame is 137; allow a hair more so DM Sans doesn't clip.
        constraints: const BoxConstraints(minWidth: 137),
        child: IntrinsicWidth(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: RituColors.fillSubtle,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _menuRow(LucideIcons.funnel, 'Filter', onFilter),
                const SizedBox(height: 12),
                // Spelling matches Figma label.
                _menuRow(LucideIcons.calendar, 'Calender', onCalendar),
                const SizedBox(height: 12),
                _menuRow(
                  LucideIcons.circleCheck,
                  'Select entries',
                  onSelectEntries,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuRow(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
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
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.borderColor,
    required this.onChanged,
  });

  final TextEditingController controller;
  final Color borderColor;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.dmSans(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      height: 18 / 11,
      color: RituColors.textPrimary,
    );
    final hintStyle = GoogleFonts.dmSans(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      height: 18 / 11,
      color: RituColors.textTertiary,
    );

    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: RituColors.fillSubtle,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: borderColor),
      ),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          const Icon(
            LucideIcons.search,
            size: 16,
            color: RituColors.textTertiary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Theme(
              data: Theme.of(context).copyWith(
                inputDecorationTheme: const InputDecorationTheme(
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                cursorColor: RituColors.sage500,
                style: textStyle,
                decoration: InputDecoration(
                  isDense: true,
                  isCollapsed: true,
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  hintText: 'Search entries',
                  hintStyle: hintStyle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthSection extends StatelessWidget {
  const _MonthSection({
    required this.group,
    required this.selecting,
    required this.selectedIds,
    required this.onToggle,
  });

  final _MonthGroup group;
  final bool selecting;
  final Set<int> selectedIds;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    final count = group.entries.length;
    final countLabel = count == 1 ? '1 entry' : '$count entries';
    final entryGap = selecting ? 8.0 : 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                formatMonthYear(group.month),
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 24 / 15,
                  color: RituColors.textPrimary,
                ),
              ),
            ),
            Text(
              countLabel,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 20 / 13,
                color: RituColors.textTertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < group.entries.length; i++) ...[
          if (i > 0) SizedBox(height: entryGap),
          _SelectableEntryRow(
            entry: group.entries[i],
            selecting: selecting,
            selected: selectedIds.contains(group.entries[i].id),
            onToggle: () => onToggle(group.entries[i].id),
          ),
        ],
      ],
    );
  }
}

/// Figma 865:3893 — checkbox + card row in select mode.
class _SelectableEntryRow extends StatelessWidget {
  const _SelectableEntryRow({
    required this.entry,
    required this.selecting,
    required this.selected,
    required this.onToggle,
  });

  final JournalEntry entry;
  final bool selecting;
  final bool selected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final card = JournalEntryCard(entry: entry, showMenu: !selecting);

    if (!selecting) return card;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onToggle,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _SelectMark(selected: selected),
          const SizedBox(width: 6),
          Expanded(child: card),
        ],
      ),
    );
  }
}

class _SelectMark extends StatelessWidget {
  const _SelectMark({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    if (selected) {
      return const Icon(
        LucideIcons.circleCheck,
        size: 24,
        color: RituColors.sage600,
      );
    }

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: RituColors.textDisabled),
      ),
    );
  }
}

/// Figma 867:4008 — Cancel / count / Delete bar while selecting.
class _SelectionActionBar extends StatelessWidget {
  const _SelectionActionBar({
    required this.selectedCount,
    required this.onCancel,
    required this.onDelete,
  });

  final int selectedCount;
  final VoidCallback onCancel;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final countLabel = selectedCount == 1
        ? '1 entry selected'
        : '$selectedCount entries selected';
    final canDelete = selectedCount > 0;

    return ColoredBox(
      color: RituColors.fillElevated,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onCancel,
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 20 / 13,
                      color: RituColors.textTertiary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    countLabel,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      height: 18 / 11,
                      color: RituColors.sage600,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: canDelete ? onDelete : null,
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    'Delete',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 20 / 13,
                      color: canDelete
                          ? RituColors.textCritical
                          : RituColors.textDisabled,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MonthGroup {
  _MonthGroup({required this.month, required this.entries});

  final DateTime month;
  final List<JournalEntry> entries;
}
