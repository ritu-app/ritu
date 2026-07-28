/// One Journal tab reflection for a calendar day.
class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.loggedOn,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final DateTime loggedOn;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;
}
