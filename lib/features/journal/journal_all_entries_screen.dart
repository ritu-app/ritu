import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../providers/journal_entry_providers.dart';
import '../../theme/ritu_colors.dart';
import 'journal_entry_card.dart';

class JournalAllEntriesScreen extends ConsumerWidget {
  const JournalAllEntriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pastAsync = ref.watch(pastJournalEntriesProvider);
    final pastEntries = pastAsync.valueOrNull ?? const [];

    return Scaffold(
      backgroundColor: RituColors.backgroundPage,
      appBar: AppBar(
        backgroundColor: RituColors.backgroundPage,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: RituColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Past entries',
          style: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            height: 24 / 15,
            color: RituColors.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: pastAsync.isLoading && pastEntries.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: RituColors.sage500),
            )
          : pastEntries.isEmpty
          ? Center(
              child: Text(
                'No past entries yet',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: RituColors.textSecondary,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: pastEntries.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return JournalEntryCard(entry: pastEntries[index]);
              },
            ),
    );
  }
}
