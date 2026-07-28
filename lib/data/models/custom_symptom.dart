/// A user-defined body signal / symptom shown in the daily log.
class CustomSymptom {
  const CustomSymptom({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  final int id;
  final String name;
  final DateTime createdAt;
}
