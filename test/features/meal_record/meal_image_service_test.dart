import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:meallog_ai/features/meal_record/data/food_label_mapper.dart';
import 'package:meallog_ai/features/meal_record/data/meal_image_service.dart';
import 'package:mocktail/mocktail.dart';

class MockImageLabeler extends Mock implements ImageLabeler {}

void main() {
  setUpAll(() {
    registerFallbackValue(InputImage.fromFilePath('test.jpg'));
  });

  group('MealImageService', () {
    late MockImageLabeler mockFoodLabeler;
    late MockImageLabeler mockBaseLabeler;
    late MealImageService service;

    setUp(() {
      mockFoodLabeler = MockImageLabeler();
      mockBaseLabeler = MockImageLabeler();
      service = MealImageService(
        foodLabeler: mockFoodLabeler,
        baseLabeler: mockBaseLabeler,
      );
    });

    test('analyzes image and returns mapped result when food model detects specific dish', () async {
      when(() => mockFoodLabeler.processImage(any())).thenAnswer(
        (_) async => [
          ImageLabel(label: 'Yakisoba', confidence: 0.88, index: 475),
        ],
      );

      final result = await service.analyzeImage('dummy/path/yakisoba.jpg');

      expect(result, isNotNull);
      expect(result!.isFoodOrDrink, isTrue);
      expect(result.category, equals(FoodCategory.food));
      expect(result.primaryDishName, equals('焼きそば'));
      expect(result.candidates, contains('ソース焼きそば'));
      expect(result.ingredients, contains('中華麺'));
      expect(result.rawLabels.first.label, equals('Yakisoba'));
    });

    test('analyzes image and returns curry when food model detects curry', () async {
      when(() => mockFoodLabeler.processImage(any())).thenAnswer(
        (_) async => [
          ImageLabel(label: 'Curry', confidence: 0.92, index: 123),
        ],
      );

      final result = await service.analyzeImage('dummy/path/curry.jpg');

      expect(result, isNotNull);
      expect(result!.isFoodOrDrink, isTrue);
      expect(result.category, equals(FoodCategory.food));
      expect(result.primaryDishName, equals('カレーライス'));
      expect(result.candidates, contains('キーマカレー'));
      expect(result.ingredients, contains('カレールー'));
    });

    test('returns null when neither model detects any labels', () async {
      when(() => mockFoodLabeler.processImage(any())).thenAnswer((_) async => []);
      when(() => mockBaseLabeler.processImage(any())).thenAnswer((_) async => []);

      final result = await service.analyzeImage('dummy/path/empty.jpg');

      expect(result, isNull);
    });

    test('falls back to base model for beverage like coffee', () async {
      when(() => mockFoodLabeler.processImage(any())).thenAnswer((_) async => []);
      when(() => mockBaseLabeler.processImage(any())).thenAnswer(
        (_) async => [
          ImageLabel(label: 'Coffee', confidence: 0.95, index: 0),
          ImageLabel(label: 'Cup', confidence: 0.85, index: 1),
        ],
      );

      final result = await service.analyzeImage('dummy/path/coffee.jpg');

      expect(result, isNotNull);
      expect(result!.isFoodOrDrink, isTrue);
      expect(result.category, equals(FoodCategory.drink));
      expect(result.primaryDishName, equals('コーヒー'));
      expect(result.candidates, contains('カフェラテ'));
      expect(result.ingredients, contains('コーヒー豆'));
    });

    test('identifies non-food image like cat and returns non-food result', () async {
      when(() => mockFoodLabeler.processImage(any())).thenAnswer((_) async => []);
      when(() => mockBaseLabeler.processImage(any())).thenAnswer(
        (_) async => [
          ImageLabel(label: 'Cat', confidence: 0.98, index: 0),
          ImageLabel(label: 'Pet', confidence: 0.92, index: 1),
        ],
      );

      final result = await service.analyzeImage('dummy/path/cat.jpg');

      expect(result, isNotNull);
      expect(result!.isFoodOrDrink, isFalse);
      expect(result.category, equals(FoodCategory.nonFood));
      expect(result.primaryDishName, isEmpty);
      expect(result.nonFoodDescription, equals('猫'));
      expect(result.candidates, isEmpty);
    });
  });
}
