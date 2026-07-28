import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/custom_symptom.dart';
import 'repository_providers.dart';

final customSymptomsProvider = StreamProvider<List<CustomSymptom>>((ref) {
  return ref.watch(symptomRepositoryProvider).watchAll();
});
