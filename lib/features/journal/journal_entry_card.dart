import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/cycle_context.dart';
import '../../core/date_format.dart';
import '../../data/repositories/journal_entry_repository.dart';
import '../../providers/period_providers.dart';
import '../../providers/repository_providers.dart';
import '../../theme/ritu_colors.dart';
import 'journal_delete_dialog.dart';
import 'journal_entry_menu.dart';
import 'journal_entry_modal.dart';

class JournalEntryCard extends ConsumerWidget {
  const JournalEntryCard({
    super.key,
    required this.entry,
    this.showMenu = true,
    this.highlightQuery,
  });

  final JournalEntry entry;
  final bool showMenu;

  /// Case-insensitive match drawn on the body, when the list is searched.
  final String? highlightQuery;

  Future<void> _editEntry(BuildContext context, WidgetRef ref) async {
    final periods = ref.read(allPeriodsProvider).valueOrNull ?? const [];
    final contextLine = formatJournalEntryContextLine(entry.loggedOn, periods);

    final updatedBody = await showJournalEntryModal(
      context,
      entry: entry,
      mode: JournalEntryModalMode.edit,
      contextLine: contextLine,
    );
    if (updatedBody == null || !context.mounted) return;

    await ref
        .read(journalEntryRepositoryProvider)
        .upsert(loggedOn: entry.loggedOn, body: updatedBody);
  }

  Future<void> _viewEntry(BuildContext context, WidgetRef ref) async {
    final periods = ref.read(allPeriodsProvider).valueOrNull ?? const [];
    final contextLine = formatJournalEntryContextLine(entry.loggedOn, periods);

    await showJournalEntryModal(
      context,
      entry: entry,
      mode: JournalEntryModalMode.view,
      contextLine: contextLine,
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showJournalDeleteDialog(context);
    if (!confirmed || !context.mounted) return;
    await ref.read(journalEntryRepositoryProvider).delete(entry.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(allPeriodsProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RituColors.fillElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RituColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  formatJournalEntryDate(entry.loggedOn),
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 20 / 13,
                    color: RituColors.textSecondary,
                  ),
                ),
              ),
              if (showMenu)
                JournalEntryMenuButton(
                  onEdit: () => _editEntry(context, ref),
                  onView: () => _viewEntry(context, ref),
                  onDelete: () => _confirmDelete(context, ref),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _HighlightedBody(text: entry.body, query: highlightQuery ?? ''),
        ],
      ),
    );
  }
}

class _HighlightedBody extends StatelessWidget {
  const _HighlightedBody({required this.text, required this.query});

  final String text;
  final String query;

  static final _style = GoogleFonts.dmSans(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 20 / 13,
    color: RituColors.textPrimary,
  );

  @override
  Widget build(BuildContext context) {
    final needle = query.trim();
    if (needle.isEmpty) {
      return Text(text, style: _style);
    }

    final lower = text.toLowerCase();
    final match = needle.toLowerCase();
    final spans = <InlineSpan>[];
    var start = 0;
    while (start < text.length) {
      final index = lower.indexOf(match, start);
      if (index < 0) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }
      final word = text.substring(index, index + match.length);
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: RituColors.fillAttention,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(word, style: _style),
            ),
          ),
        ),
      );
      start = index + match.length;
    }

    return Text.rich(TextSpan(style: _style, children: spans));
  }
}
