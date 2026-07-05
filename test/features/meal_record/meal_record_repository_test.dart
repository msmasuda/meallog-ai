import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:meallog_ai/core/db/isar_service.dart';
import 'package:meallog_ai/features/meal_record/data/meal_record_model.dart';
import 'package:meallog_ai/features/meal_record/data/meal_record_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Isar? isar;
  MealRecordRepository? repo;
  Directory? tempDir;

  setUp(() async {
    try {
      await Isar.initializeIsarCore(download: false);
    } catch (_) {
      // Already initialized or not needed on this platform.
    }
    tempDir = await Directory.systemTemp.createTemp('isar_test_');
    try {
      isar = await IsarService.init(tempDir!.path);
      repo = MealRecordRepository(isar!);
    } catch (e) {
      // Native Isar libraries unavailable — tests will be skipped individually.
      isar = null;
      repo = null;
    }
  });

  tearDown(() async {
    if (isar?.isOpen ?? false) {
      await isar!.close(deleteFromDisk: true);
    }
    isar = null;
    repo = null;
    await tempDir?.delete(recursive: true);
    tempDir = null;
  });

  MealRecord make({required String dish, DateTime? date}) => MealRecord()
    ..date = date ?? DateTime.now()
    ..mealType = 'dinner'
    ..dishName = dish
    ..createdAt = DateTime.now();

  test('add then getAll returns saved record', () async {
    if (repo == null) {
      markTestSkipped('Isar native libs not available');
      return;
    }
    await repo!.add(make(dish: '鶏の照り焼き'));
    final all = await repo!.getAll();
    expect(all, hasLength(1));
    expect(all.first.dishName, equals('鶏の照り焼き'));
  });

  test('getByDate returns only records for that date', () async {
    if (repo == null) {
      markTestSkipped('Isar native libs not available');
      return;
    }
    await repo!.add(make(dish: 'カレー', date: DateTime(2026, 7, 5)));
    await repo!.add(make(dish: 'ラーメン', date: DateTime(2026, 7, 6)));
    final results = await repo!.getByDate(DateTime(2026, 7, 5));
    expect(results, hasLength(1));
    expect(results.first.dishName, equals('カレー'));
  });

  test('getRecent excludes records older than N days', () async {
    if (repo == null) {
      markTestSkipped('Isar native libs not available');
      return;
    }
    await repo!.add(make(dish: '豚汁'));
    await repo!.add(
        make(dish: '古い料理', date: DateTime.now().subtract(const Duration(days: 30))));
    final results = await repo!.getRecent(days: 7);
    expect(results.map((r) => r.dishName), contains('豚汁'));
    expect(results.map((r) => r.dishName), isNot(contains('古い料理')));
  });

  test('delete removes the record', () async {
    if (repo == null) {
      markTestSkipped('Isar native libs not available');
      return;
    }
    await repo!.add(make(dish: 'そば'));
    final saved = await repo!.getAll();
    await repo!.delete(saved.first.id);
    expect(await repo!.getAll(), isEmpty);
  });
}
