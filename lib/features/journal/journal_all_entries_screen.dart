import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/date_format.dart';
import '../../data/repositories/journal_entry_repository.dart';
import '../../providers/journal_entry_providers.dart';
import '../../theme/ritu_colors.dart';
import 'journal_entry_card.dart';

class JournalAllEntriesScreen extends ConsumerStatefulWidget {
  const JournalAllEntriesScreen({super.key, this.onBack});

  /// When set (Journal tab embed), back uses this instead of [Navigator.pop]
  /// so the home bottom nav stays visible.
  final VoidCallback? onBack;

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleBack() {
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

  List<JournalEntry> _filtered(List<JournalEntry> entries) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return entries;
    return entries
        .where((entry) => entry.body.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final pastAsync = ref.watch(pastJournalEntriesProvider);
    final pastEntries = pastAsync.valueOrNull ?? const [];
    final filtered = _filtered(pastEntries);
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
                          _query.trim().isEmpty
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
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: groups.length,
                        itemBuilder: (context, index) {
                          final group = groups[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index == groups.length - 1 ? 0 : 24,
                            ),
                            child: _MonthSection(group: group),
                          );
                        },
                      ),
              ),
            ],
          ),
          if (_menuOpen) ...[
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
                onSelect: _closeMenu,
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
  });

  final VoidCallback onBack;
  final VoidCallback onMenuTap;

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
            onTap: onMenuTap,
            behavior: HitTestBehavior.opaque,
            child: const SizedBox(
              width: 24,
              height: 24,
              child: Icon(
                LucideIcons.ellipsis,
                size: 24,
                color: RituColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Figma 865:3277 — cream panel, 12px pad/gap, radius 7.
class _AllEntriesOverflowMenu extends StatelessWidget {
  const _AllEntriesOverflowMenu({
    required this.borderColor,
    required this.onSelect,
  });

  final Color borderColor;
  final VoidCallback onSelect;

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
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _menuRow(LucideIcons.funnel, 'Filter'),
                const SizedBox(height: 12),
                // Spelling matches Figma label.
                _menuRow(LucideIcons.calendar, 'Calender'),
                const SizedBox(height: 12),
                _menuRow(LucideIcons.circleCheck, 'Select entries'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuRow(IconData icon, String label) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onSelect,
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
  const _MonthSection({required this.group});

  final _MonthGroup group;

  @override
  Widget build(BuildContext context) {
    final count = group.entries.length;
    final countLabel = count == 1 ? '1 entry' : '$count entries';

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
          if (i > 0) const SizedBox(height: 16),
          JournalEntryCard(entry: group.entries[i]),
        ],
      ],
    );
  }
}

class _MonthGroup {
  _MonthGroup({required this.month, required this.entries});

  final DateTime month;
  final List<JournalEntry> entries;
}
