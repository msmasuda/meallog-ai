import 'dart:convert';

import '../../../core/agent/vision_api_client.dart';

class MealRecognitionResult {
  const MealRecognitionResult({
    required this.primaryDishName,
    this.candidates = const [],
    this.ingredients = const [],
  });

  final String primaryDishName;
  final List<String> candidates;
  final List<String> ingredients;
}

class MealImageService {
  const MealImageService({
    required VisionApiClient visionClient,
    this.model,
  }) : _visionClient = visionClient;

  final VisionApiClient _visionClient;
  final String? model;

  static const prompt = 'この画像に写っている料理を日本語で推定してください。'
      '最も可能性が高い料理名、ほかの料理候補、'
      '画像から確認できる推定食材を返してください。'
      '確認できない食材を断定しないでください。';

  static const responseSchema = <String, dynamic>{
    'type': 'object',
    'properties': {
      'dishName': {'type': 'string'},
      'candidates': {
        'type': 'array',
        'items': {'type': 'string'},
      },
      'ingredients': {
        'type': 'array',
        'items': {'type': 'string'},
      },
    },
    'required': ['dishName', 'candidates', 'ingredients'],
    'additionalProperties': false,
  };

  Future<MealRecognitionResult> analyzeImage(String imagePath) async {
    final response = await _visionClient.analyzeImage(
      imagePath: imagePath,
      prompt: prompt,
      responseSchema: responseSchema,
      model: model,
    );
    final content = _asMap(response.content);
    final dishName = content['dishName'];
    if (dishName is! String || dishName.trim().isEmpty) {
      throw const VisionApiException('料理名を認識できませんでした');
    }
    final primary = dishName.trim();
    final candidates = _stringList(content['candidates']);
    if (!candidates.contains(primary)) candidates.insert(0, primary);
    return MealRecognitionResult(
      primaryDishName: primary,
      candidates: candidates,
      ingredients: _stringList(content['ingredients']),
    );
  }

  static Map<String, dynamic> _asMap(Object? content) {
    if (content is Map<String, dynamic>) return content;
    if (content is Map) return Map<String, dynamic>.from(content);
    if (content is String) {
      try {
        final decoded = jsonDecode(content);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } on FormatException {
        // The response must be structured JSON for this feature.
      }
    }
    throw const VisionApiException('画像解析結果の形式が不正です');
  }

  static List<String> _stringList(Object? value) {
    if (value is! List) return [];
    return value
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList();
  }
}
