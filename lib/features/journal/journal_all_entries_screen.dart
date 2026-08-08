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
  const JournalAllEntriesScreen({super.key});

  @override
  ConsumerState<JournalAllEntriesScreen> createState() =>
      _JournalAllEntriesScreenState();
}

class _JournalAllEntriesScreenState
    extends ConsumerState<JournalAllEntriesScreen> {
  static const _borderDefault = Color(0xFFE2DDD8);

  final _searchController = TextEditingController();
  var _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

    return Scaffold(
      backgroundColor: RituColors.backgroundPage,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: _AllEntriesHeader(
                borderColor: _borderDefault,
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
      ),
    );
  }
}

class _AllEntriesHeader extends StatelessWidget {
  const _AllEntriesHeader({required this.borderColor});

  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 24, height: 24),
            icon: const Icon(
              LucideIcons.chevronLeft,
              size: 24,
              color: RituColors.textPrimary,
            ),
            onPressed: () => Navigator.of(context).pop(),
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
        PopupMenuButton<_AllEntriesMenuAction>(
          icon: const Icon(
            LucideIcons.ellipsis,
            size: 24,
            color: RituColors.textPrimary,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 24, height: 24),
          offset: const Offset(-100, 28),
          color: RituColors.fillSubtle,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
            side: BorderSide(color: borderColor),
          ),
          onSelected: (_) {
            // Filter / Calendar / Select flows are not implemented yet.
          },
          itemBuilder: (context) => [
            _menuItem(
              _AllEntriesMenuAction.filter,
              LucideIcons.funnel,
              'Filter',
            ),
            _menuItem(
              _AllEntriesMenuAction.calendar,
              LucideIcons.calendar,
              'Calendar',
            ),
            _menuItem(
              _AllEntriesMenuAction.select,
              LucideIcons.circleCheck,
              'Select entries',
            ),
          ],
        ),
      ],
    );
  }

  PopupMenuItem<_AllEntriesMenuAction> _menuItem(
    _AllEntriesMenuAction value,
    IconData icon,
    String label,
  ) {
    return PopupMenuItem(
      value: value,
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
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

enum _AllEntriesMenuAction { filter, calendar, select }

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
    return SizedBox(
      height: 36,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          height: 18 / 11,
          color: RituColors.textPrimary,
        ),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: RituColors.fillSubtle,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 20, right: 8),
            child: Icon(
              LucideIcons.search,
              size: 16,
              color: RituColors.textTertiary,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 16,
          ),
          hintText: 'Search entries',
          hintStyle: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            height: 18 / 11,
            color: RituColors.textTertiary,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9999),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9999),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9999),
            borderSide: BorderSide(color: borderColor),
          ),
        ),
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
