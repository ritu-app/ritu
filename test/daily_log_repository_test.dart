import 'package:flutter_test/flutter_test.dart';

import 'package:ritu/data/local/app_database.dart';
import 'package:ritu/data/repositories/daily_log_repository.dart';
import 'package:ritu/data/repositories/drift/drift_daily_log_repository.dart';

void main() {
  late AppDatabase database;
  late DailyLogRepository repository;

  setUp(() {
    database = AppDatabase.memory();
    repository = DriftDailyLogRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  DateTime daysAgo(int days) => DateTime.now().subtract(Duration(days: days));

  test('streak is 0 with no logs', () async {
    expect(await repository.getCurrentStreak(), 0);
  });

  test('streak is 1 after logging just today', () async {
    await repository.upsert(loggedOn: DateTime.now());
    expect(await repository.getCurrentStreak(), 1);
  });

  test('streak counts consecutive days ending today', () async {
    await repository.upsert(loggedOn: daysAgo(2));
    await repository.upsert(loggedOn: daysAgo(1));
    await repository.upsert(loggedOn: daysAgo(0));
    expect(await repository.getCurrentStreak(), 3);
  });

  test(
    'streak stays alive for today if only logged through yesterday',
    () async {
      await repository.upsert(loggedOn: daysAgo(2));
      await repository.upsert(loggedOn: daysAgo(1));
      expect(await repository.getCurrentStreak(), 2);
    },
  );

  test('streak resets to 0 once a day is missed', () async {
    await repository.upsert(loggedOn: daysAgo(5));
    await repository.upsert(loggedOn: daysAgo(4));
    // Gap at daysAgo(3) and daysAgo(2) breaks the streak before today.
    expect(await repository.getCurrentStreak(), 0);
  });

  test('a gap in the middle only counts the most recent run', () async {
    await repository.upsert(loggedOn: daysAgo(10));
    await repository.upsert(loggedOn: daysAgo(1));
    await repository.upsert(loggedOn: daysAgo(0));
    expect(await repository.getCurrentStreak(), 2);
  });
}
