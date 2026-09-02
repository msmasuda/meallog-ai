import 'package:flutter_test/flutter_test.dart';
import 'package:meallog_ai/core/agent/vision_api_client.dart';
import 'package:meallog_ai/features/meal_record/data/meal_image_service.dart';

void main() {
  group('MealImageService', () {
    test('sends meal prompt and schema, then maps structured result', () async {
      final client = _FakeVisionApiClient(
        const VisionAnalyzeResponse(
          content: {
            'dishName': ' カレーライス ',
            'candidates': ['キーマカレー', 'カレーライス'],
            'ingredients': ['玉ねぎ', '人参', '玉ねぎ'],
          },
          model: 'vision-model',
        ),
      );
      final service = MealImageService(visionClient: client);

      final result = await service.analyzeImage('/tmp/meal.jpg');

      expect(client.imagePath, '/tmp/meal.jpg');
      expect(client.prompt, contains('料理名'));
      expect(client.responseSchema, MealImageService.responseSchema);
      expect(result.primaryDishName, 'カレーライス');
      expect(result.candidates, ['キーマカレー', 'カレーライス']);
      expect(result.ingredients, ['玉ねぎ', '人参']);
    });

    test('accepts JSON string content and inserts primary candidate', () async {
      final client = _FakeVisionApiClient(
        const VisionAnalyzeResponse(
          content:
              '{"dishName":"寿司","candidates":["海鮮丼"],"ingredients":["魚","米"]}',
          model: 'vision-model',
        ),
      );
      final service = MealImageService(visionClient: client);

      final result = await service.analyzeImage('/tmp/sushi.png');

      expect(result.primaryDishName, '寿司');
      expect(result.candidates, ['寿司', '海鮮丼']);
    });

    test('rejects a structured result without dishName', () async {
      final client = _FakeVisionApiClient(
        const VisionAnalyzeResponse(
          content: {'candidates': <String>[], 'ingredients': <String>[]},
          model: 'vision-model',
        ),
      );
      final service = MealImageService(visionClient: client);

      expect(
        () => service.analyzeImage('/tmp/unknown.webp'),
        throwsA(isA<VisionApiException>()),
      );
    });
  });
}

class _FakeVisionApiClient implements VisionApiClient {
  _FakeVisionApiClient(this.response);

  final VisionAnalyzeResponse response;
  String? imagePath;
  String? prompt;
  Map<String, dynamic>? responseSchema;

  @override
  Future<VisionAnalyzeResponse> analyzeImage({
    required String imagePath,
    required String prompt,
    Map<String, dynamic>? responseSchema,
    String? model,
  }) async {
    this.imagePath = imagePath;
    this.prompt = prompt;
    this.responseSchema = responseSchema;
    return response;
  }
}
