import '../models/period_end_prompt.dart';

export '../models/period_end_prompt.dart';

abstract class PeriodEndPromptRepository {
  Future<PeriodEndPrompt> recordShown({
    required int periodLogId,
    required DateTime shownOn,
  });

  Future<PeriodEndPrompt> recordResponse({
    required int promptId,
    required String response,
    required DateTime respondedOn,
  });

  Future<PeriodEndPrompt?> getLatestForPeriod(int periodLogId);

  Future<List<PeriodEndPrompt>> getAll();
}
