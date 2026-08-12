import '../period_end_prompt_repository.dart';
import 'memory_ritu_store.dart';

class MemoryPeriodEndPromptRepository implements PeriodEndPromptRepository {
  MemoryPeriodEndPromptRepository(this._store);

  final MemoryRituStore _store;

  @override
  Future<PeriodEndPrompt> recordShown({
    required int periodLogId,
    required DateTime shownOn,
  }) async {
    final prompt = PeriodEndPrompt(
      id: _store.nextPeriodEndPromptId++,
      periodLogId: periodLogId,
      shownOn: shownOn,
      createdAt: DateTime.now(),
    );
    _store.periodEndPrompts.add(prompt);
    _store.notifyPeriodEndPrompts();
    return prompt;
  }

  @override
  Future<PeriodEndPrompt> recordResponse({
    required int promptId,
    required String response,
    required DateTime respondedOn,
  }) async {
    final index = _store.periodEndPrompts.indexWhere((p) => p.id == promptId);
    if (index == -1) {
      throw StateError('Prompt $promptId not found');
    }
    final existing = _store.periodEndPrompts[index];
    final updated = PeriodEndPrompt(
      id: existing.id,
      periodLogId: existing.periodLogId,
      shownOn: existing.shownOn,
      response: response,
      respondedOn: respondedOn,
      createdAt: existing.createdAt,
    );
    _store.periodEndPrompts[index] = updated;
    _store.notifyPeriodEndPrompts();
    return updated;
  }

  @override
  Future<PeriodEndPrompt?> getLatestForPeriod(int periodLogId) async {
    final matches = _store.periodEndPrompts
        .where((p) => p.periodLogId == periodLogId)
        .toList()
      ..sort((a, b) => b.shownOn.compareTo(a.shownOn));
    return matches.isEmpty ? null : matches.first;
  }

  @override
  Future<List<PeriodEndPrompt>> getAll() async {
    final all = List<PeriodEndPrompt>.from(_store.periodEndPrompts)
      ..sort((a, b) => b.shownOn.compareTo(a.shownOn));
    return all;
  }
}
