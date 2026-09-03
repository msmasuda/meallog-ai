import 'package:flutter_test/flutter_test.dart';
import 'package:meallog_ai/features/meal_record/data/meal_record_model.dart';
import 'package:meallog_ai/features/meal_record/data/meal_record_repository.dart';

import '../../support/isar_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MealRecordRepository repo;

  setUpAll(initializeTestIsar);

  setUp(() async {
    repo = MealRecordRepository(await openTestIsar());
  });

  MealRecord make({required String dish, DateTime? date}) => MealRecord()
    ..date = date ?? DateTime.now()
    ..mealType = 'dinner'
    ..dishName = dish
    ..createdAt = DateTime.now();

  test('add then getAll returns saved record', () async {
    await repo.add(make(dish: '鶏の照り焼き'));
    final all = await repo.getAll();
    expect(all, hasLength(1));
    expect(all.first.dishName, equals('鶏の照り焼き'));
  });

  test('getByDate returns only records for that date', () async {
    await repo.add(make(dish: 'カレー', date: DateTime(2026, 7, 5)));
    await repo.add(make(dish: 'ラーメン', date: DateTime(2026, 7, 6)));
    final results = await repo.getByDate(DateTime(2026, 7, 5));
    expect(results, hasLength(1));
    expect(results.first.dishName, equals('カレー'));
  });

  test('getRecent excludes records older than N days', () async {
    await repo.add(make(dish: '豚汁'));
    await repo.add(make(
        dish: '古い料理', date: DateTime.now().subtract(const Duration(days: 30))));
    final results = await repo.getRecent(days: 7);
    expect(results.map((r) => r.dishName), contains('豚汁'));
    expect(results.map((r) => r.dishName), isNot(contains('古い料理')));
  });

  test('delete removes the record', () async {
    await repo.add(make(dish: 'そば'));
    final saved = await repo.getAll();
    await repo.delete(saved.first.id);
    expect(await repo.getAll(), isEmpty);
  });
}
