import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/date_format.dart';
import '../../data/repositories/journal_entry_repository.dart';
import '../../providers/journal_entry_providers.dart';
import '../../providers/repository_providers.dart';
import '../../theme/ritu_colors.dart';

/// Journal tab: daily reflection with persisted entries.
class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final _controller = TextEditingController();
  var _editingToday = false;
  var _showAllPast = false;
  JournalEntry? _loadedTodayEntry;

  static const _heroBackground = Color(0xFFFDF2ED);
  static const _heroBorder = Color(0xFFE2DDD8);

  static const _helpItems = [
    (
      LucideIcons.smile,
      RituColors.fillCriticalSecondary,
      RituColors.iconCritical,
      'Reduce stress',
      'Writing helps you release your thoughts',
    ),
    (
      LucideIcons.sparkle,
      RituColors.fillPositiveSecondary,
      RituColors.textPositive,
      'Increase clarity',
      'Journaling helps you think more clearly',
    ),
    (
      LucideIcons.orbit,
      RituColors.fillInfoSecondary,
      RituColors.iconInfo,
      'Improve well-being',
      'Boost your mood and support daily balance',
    ),
    (
      LucideIcons.brain,
      RituColors.fillAttentionSecondary,
      RituColors.iconAttention,
      'Build self awareness',
      'Learn from your thoughts and experiences',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncControllerFromRepo(JournalEntry? todayEntry, {required bool showInput}) {
    if (!showInput || _editingToday) return;
    if (todayEntry?.id == _loadedTodayEntry?.id &&
        todayEntry?.body == _loadedTodayEntry?.body) {
      return;
    }
    _loadedTodayEntry = todayEntry;
    _controller.text = todayEntry?.body ?? '';
  }

  bool _canSave(JournalEntry? todayEntry) {
    final text = _controller.text.trim();
    if (text.isEmpty) return false;
    return todayEntry == null || text != todayEntry.body;
  }

  Future<void> _saveEntry() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    await ref.read(journalEntryRepositoryProvider).upsert(
          loggedOn: DateTime.now(),
          body: text,
        );

    if (!mounted) return;
    setState(() {
      _editingToday = false;
      _loadedTodayEntry = null;
    });
    FocusScope.of(context).unfocus();
  }

  void _startEditingToday(JournalEntry entry) {
    setState(() {
      _editingToday = true;
      _controller.text = entry.body;
    });
  }

  Future<void> _deleteEntry(JournalEntry entry) async {
    await ref.read(journalEntryRepositoryProvider).delete(entry.id);
  }

  @override
  Widget build(BuildContext context) {
    final todayAsync = ref.watch(todayJournalEntryProvider);
    final pastAsync = ref.watch(pastJournalEntriesProvider);

    final todayEntry = todayAsync.valueOrNull;
    final pastEntries = pastAsync.valueOrNull ?? const [];
    final hasPastEntries = pastEntries.isNotEmpty;
    final showInput =
        hasPastEntries || todayEntry == null || _editingToday;
    final showSavedCard = !showInput;
    final showHelp = !hasPastEntries;
    final previewCount = _showAllPast ? pastEntries.length : 2;
    final visiblePast = pastEntries.take(previewCount).toList();

    ref.listen(todayJournalEntryProvider, (previous, next) {
      final entry = next.valueOrNull;
      final past = ref.read(pastJournalEntriesProvider).valueOrNull ?? [];
      final input = past.isNotEmpty || entry == null || _editingToday;
      _syncControllerFromRepo(entry, showInput: input);
    });
    _syncControllerFromRepo(todayEntry, showInput: showInput);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text(
          'Journal',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 28,
            fontWeight: FontWeight.w400,
            height: 34 / 28,
            color: RituColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Your space to reflect',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 20 / 13,
            color: RituColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        const _HeroCard(),
        const SizedBox(height: 20),
        if (showInput)
          _ReflectionCard(
            controller: _controller,
            canSave: _canSave(todayEntry),
            onSave: _saveEntry,
            onChanged: () => setState(() {}),
          ),
        if (showSavedCard)
          _SavedReflectionCard(
            entry: todayEntry,
            onEdit: () => _startEditingToday(todayEntry),
          ),
        if (hasPastEntries) ...[
          const SizedBox(height: 20),
          _PastEntriesHeader(
            showAll: _showAllPast,
            canExpand: pastEntries.length > 2,
            onViewAll: () => setState(() => _showAllPast = true),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < visiblePast.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            _PastEntryCard(
              entry: visiblePast[i],
              onDelete: () => _deleteEntry(visiblePast[i]),
            ),
          ],
        ],
        if (showHelp) ...[
          const SizedBox(height: 20),
          Text(
            'Journal helps you',
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 24 / 15,
              color: RituColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < _helpItems.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            _HelpRow(
              icon: _helpItems[i].$1,
              iconBackground: _helpItems[i].$2,
              iconColor: _helpItems[i].$3,
              title: _helpItems[i].$4,
              subtitle: _helpItems[i].$5,
            ),
          ],
        ],
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _JournalScreenState._heroBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _JournalScreenState._heroBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 116,
            height: 118,
            child: ClipRect(
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Positioned(
                    left: -116 * 0.1767,
                    top: -118 * 0.089,
                    width: 116 * 1.3578,
                    height: 118 * 1.3347,
                    child: Image.asset(
                      'assets/images/journal_reflection.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'A space for you, just as you are',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 24 / 18,
              color: RituColors.textPrimary,
            ),
          ),
          Text(
            'Write about how your body feels, your mood, or anything you noticed',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 20 / 13,
              color: RituColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(
            height: 1,
            thickness: 0.5,
            color: RituColors.divider,
          ),
          const SizedBox(height: 12),
          Text(
            'Every small note you write brings meaningful insights',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 18 / 11,
              color: RituColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReflectionCard extends StatelessWidget {
  const _ReflectionCard({
    required this.controller,
    required this.canSave,
    required this.onSave,
    required this.onChanged,
  });

  final TextEditingController controller;
  final bool canSave;
  final VoidCallback onSave;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RituColors.textDisabled),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today’s reflection',
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 24 / 15,
              color: RituColors.textPrimary,
            ),
          ),
          Text(
            'How are you feeling in your body today?',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 20 / 13,
              color: RituColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 177,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: RituColors.fillElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: RituColors.borderSubtle),
            ),
            child: TextField(
              controller: controller,
              onChanged: (_) => onChanged(),
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                height: 20 / 13,
                color: RituColors.textPrimary,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: 'Write freely......',
                hintStyle: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  height: 20 / 13,
                  color: RituColors.textDisabled,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: FilledButton(
              onPressed: canSave ? onSave : null,
              style: FilledButton.styleFrom(
                backgroundColor: RituColors.sage500,
                disabledBackgroundColor:
                    RituColors.sage500.withValues(alpha: 0.5),
                foregroundColor: RituColors.white,
                disabledForegroundColor: RituColors.white,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: const StadiumBorder(),
                textStyle: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 20 / 13,
                ),
              ),
              child: const Text('Save entry'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedReflectionCard extends StatelessWidget {
  const _SavedReflectionCard({
    required this.entry,
    required this.onEdit,
  });

  final JournalEntry entry;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RituColors.fillSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RituColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.circleCheck,
                size: 24,
                color: RituColors.sage600,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Today’s reflection saved',
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 24 / 15,
                    color: RituColors.textPrimary,
                  ),
                ),
              ),
              TextButton(
                onPressed: onEdit,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: RituColors.sage600,
                ),
                child: Text(
                  'Edit',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 20 / 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            entry.body,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 20 / 13,
              color: RituColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PastEntriesHeader extends StatelessWidget {
  const _PastEntriesHeader({
    required this.showAll,
    required this.canExpand,
    required this.onViewAll,
  });

  final bool showAll;
  final bool canExpand;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Past entries',
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 24 / 15,
              color: RituColors.textPrimary,
            ),
          ),
        ),
        if (canExpand && !showAll)
          TextButton(
            onPressed: onViewAll,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: RituColors.sage600,
            ),
            child: Text(
              'View all',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 20 / 13,
              ),
            ),
          ),
      ],
    );
  }
}

class _PastEntryCard extends StatelessWidget {
  const _PastEntryCard({
    required this.entry,
    required this.onDelete,
  });

  final JournalEntry entry;
  final VoidCallback onDelete;

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
              PopupMenuButton<String>(
                icon: const Icon(
                  LucideIcons.ellipsis,
                  size: 24,
                  color: RituColors.textSecondary,
                ),
                padding: EdgeInsets.zero,
                onSelected: (value) {
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Delete',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            entry.body,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 20 / 13,
              color: RituColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpRow extends StatelessWidget {
  const _HelpRow({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final String subtitle;

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
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 20 / 13,
                    color: RituColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    height: 18 / 11,
                    color: RituColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
