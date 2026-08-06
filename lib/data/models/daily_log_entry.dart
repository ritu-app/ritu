/// One daily check-in entry from the Home "Log today" flow.
class DailyLogEntry {
  const DailyLogEntry({
    required this.id,
    required this.loggedOn,
    required this.createdAt,
    required this.updatedAt,
    this.flowIntensity,
    this.crampIntensity,
    this.moods = const [],
    this.energyLevel,
    this.sleepQuality,
    this.wellbeing,
    this.symptoms = const [],
  });

  final int id;
  final DateTime loggedOn;
  final String? flowIntensity;
  final int? crampIntensity;
  final List<String> moods;
  final String? energyLevel;
  final String? sleepQuality;
  final int? wellbeing;
  final List<String> symptoms;
  final DateTime createdAt;
  final DateTime updatedAt;
}
