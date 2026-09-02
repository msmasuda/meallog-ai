import 'package:flutter_test/flutter_test.dart';
import 'package:meallog_ai/features/meal_record/data/food_label_mapper.dart';

void main() {
  group('FoodLabelMapper', () {
    test('maps common food labels to Japanese dishes correctly', () {
      final curryResult = FoodLabelMapper.mapLabels(['Curry', 'Food', 'Dish']);
      expect(curryResult, isNotNull);
      expect(curryResult!.primaryDishName, equals('カレーライス'));
      expect(curryResult.candidates, contains('キーマカレー'));
      expect(curryResult.ingredients, contains('カレールー'));

      final ramenResult = FoodLabelMapper.mapLabels(['Ramen', 'Noodle']);
      expect(ramenResult, isNotNull);
      expect(ramenResult!.primaryDishName, equals('ラーメン'));

      final pastaResult = FoodLabelMapper.mapLabels(['Spaghetti', 'Pasta']);
      expect(pastaResult, isNotNull);
      expect(pastaResult!.primaryDishName, equals('スパゲッティ'));

      final saladResult = FoodLabelMapper.mapLabels(['Salad', 'Vegetable']);
      expect(saladResult, isNotNull);
      expect(saladResult!.primaryDishName, equals('サラダ'));

      final sushiResult = FoodLabelMapper.mapLabels(['Sushi', 'Japanese food']);
      expect(sushiResult, isNotNull);
      expect(sushiResult!.primaryDishName, equals('寿司'));
    });

    test('returns null when no known label matches', () {
      final result = FoodLabelMapper.mapLabels(['Chair', 'Table', 'Sky']);
      expect(result, isNull);
    });

    test('extractAllCandidates extracts unique candidate dishes across multiple labels', () {
      final candidates = FoodLabelMapper.extractAllCandidates(['Curry', 'Salad']);
      expect(candidates, contains('カレーライス'));
      expect(candidates, contains('サラダ'));
      expect(candidates, contains('キーマカレー'));
      expect(candidates, contains('グリーンサラダ'));
    });
  });
}
