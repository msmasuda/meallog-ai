import 'package:flutter_test/flutter_test.dart';
import 'package:meallog_ai/features/meal_record/data/meal_record_model.dart';
import 'package:meallog_ai/features/suggestion/data/suggestion_model.dart';

import '../../support/isar_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(initializeTestIsar);

  test('IsarService.init opens database with both schemas', () async {
    final isar = await openTestIsar();
    expect(isar.isOpen, isTrue);
    expect(isar.name, equals('meallog'));
    expect(await isar.mealRecords.count(), isZero);
    expect(await isar.suggestions.count(), isZero);
  });
}
