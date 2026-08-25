import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:meallog_ai/features/meal_record/data/meal_image_service.dart';
import 'package:mocktail/mocktail.dart';

class MockImageLabeler extends Mock implements ImageLabeler {}

void main() {
  setUpAll(() {
    registerFallbackValue(InputImage.fromFilePath('test.jpg'));
  });

  group('MealImageService', () {
    late MockImageLabeler mockLabeler;
    late MealImageService service;

    setUp(() {
      mockLabeler = MockImageLabeler();
      service = MealImageService(labeler: mockLabeler);
    });

    test('analyzes image and returns mapped result when food labels detected', () async {
      when(() => mockLabeler.processImage(any())).thenAnswer(
        (_) async => [
          ImageLabel(label: 'Curry', confidence: 0.95, index: 0),
          ImageLabel(label: 'Rice', confidence: 0.88, index: 1),
        ],
      );

      final result = await service.analyzeImage('dummy/path/curry.jpg');

      expect(result, isNotNull);
      expect(result!.primaryDishName, equals('カレーライス'));
      expect(result.candidates, contains('カレーライス'));
      expect(result.ingredients, contains('カレールー'));
      expect(result.rawLabels.length, equals(2));
      expect(result.rawLabels.first.label, equals('Curry'));
    });

    test('returns null when no labels detected', () async {
      when(() => mockLabeler.processImage(any())).thenAnswer((_) async => []);

      final result = await service.analyzeImage('dummy/path/empty.jpg');

      expect(result, isNull);
    });

    test('falls back to top label when no dictionary match is found', () async {
      when(() => mockLabeler.processImage(any())).thenAnswer(
        (_) async => [
          ImageLabel(label: 'UnknownSpecialty', confidence: 0.8, index: 0),
        ],
      );

      final result = await service.analyzeImage('dummy/path/unknown.jpg');

      expect(result, isNotNull);
      expect(result!.primaryDishName, equals('UnknownSpecialty'));
      expect(result.ingredients, isEmpty);
    });
  });
}
