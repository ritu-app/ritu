import 'package:flutter/material.dart';
import 'package:ritu/core/date_format.dart';
import 'package:ritu/data/repositories/memory/memory_journal_entry_repository.dart';

import '../scope/ritu_repos.dart';

Future<void> applyJournalState({
  required RituRepos repos,
  required DateTime simulatedToday,
  required String todayBody,
  required int pastEntryCount,
}) async {
  final journal = repos.journalEntries as MemoryJournalEntryRepository;
  await journal.clearAll();

  final today = dateOnly(simulatedToday);
  final trimmed = todayBody.trim();
  if (trimmed.isNotEmpty) {
    await journal.upsert(loggedOn: today, body: trimmed);
  }

  for (var i = 1; i <= pastEntryCount; i++) {
    await journal.upsert(
      loggedOn: today.subtract(Duration(days: i)),
      body: i == 1
          ? 'Sample reflection from yesterday.'
          : 'Sample reflection from $i days ago.',
    );
  }
}

/// Control-panel UI for seeding Journal tab state.
class JournalControls extends StatefulWidget {
  const JournalControls({
    super.key,
    required this.todayBody,
    required this.pastEntryCount,
    required this.onTodayBodyChanged,
    required this.onPastEntryCountChanged,
  });

  final String todayBody;
  final int pastEntryCount;
  final ValueChanged<String> onTodayBodyChanged;
  final ValueChanged<int> onPastEntryCountChanged;

  @override
  State<JournalControls> createState() => _JournalControlsState();
}

class _JournalControlsState extends State<JournalControls> {
  late final TextEditingController _todayController;

  @override
  void initState() {
    super.initState();
    _todayController = TextEditingController(text: widget.todayBody);
  }

  @override
  void didUpdateWidget(covariant JournalControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.todayBody != oldWidget.todayBody &&
        widget.todayBody != _todayController.text) {
      _todayController.text = widget.todayBody;
    }
  }

  @override
  void dispose() {
    _todayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Journal', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Text(
          'Seed today and past reflections for the Journal tab. '
          'Navigate to Journal in the preview to verify.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _todayController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: "Today's entry",
            hintText: 'Leave empty for no today entry',
            isDense: true,
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          onChanged: widget.onTodayBodyChanged,
        ),
        const SizedBox(height: 16),
        Text('Past entries: ${widget.pastEntryCount}'),
        Slider(
          value: widget.pastEntryCount.toDouble(),
          min: 0,
          max: 10,
          divisions: 10,
          label: '${widget.pastEntryCount}',
          onChanged: (value) => widget.onPastEntryCountChanged(value.round()),
        ),
      ],
    );
  }
}
