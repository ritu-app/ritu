class PeriodEndPromptResponses {
  static const stillGoing = 'still_going';
  static const ended = 'ended';
  static const dismissed = 'dismissed';
}

class PeriodEndPrompt {
  const PeriodEndPrompt({
    required this.id,
    required this.periodLogId,
    required this.shownOn,
    required this.createdAt,
    this.response,
    this.respondedOn,
    this.periodStartedOn,
  });

  final int id;
  final int periodLogId;
  final DateTime shownOn;
  final String? response;
  final DateTime? respondedOn;
  final DateTime createdAt;

  /// Included in backup JSON to remap [periodLogId] after import.
  final DateTime? periodStartedOn;

  bool get isAnswered => response != null;
}
