// lib/features/meal_record/data/meal_image_service.dart
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'food_label_mapper.dart';

class RawImageLabel {
  const RawImageLabel({required this.label, required this.confidence});
  final String label;
  final double confidence;
}

class MealRecognitionResult {
  const MealRecognitionResult({
    required this.primaryDishName,
    this.candidates = const [],
    this.ingredients = const [],
    this.rawLabels = const [],
  });

  final String primaryDishName;
  final List<String> candidates;
  final List<String> ingredients;
  final List<RawImageLabel> rawLabels;
}

class MealImageService {
  MealImageService({ImageLabeler? labeler}) : _labeler = labeler;

  final ImageLabeler? _labeler;

  Future<MealRecognitionResult?> analyzeImage(String imagePath) async {
    final labeler = _labeler ??
        ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.5));
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final labels = await labeler.processImage(inputImage);
      if (labels.isEmpty) return null;

      final rawLabels = labels
          .map((l) => RawImageLabel(label: l.label, confidence: l.confidence))
          .toList();

      final labelNames = labels.map((l) => l.label).toList();
      final mapping = FoodLabelMapper.mapLabels(labelNames);
      final allCandidates = FoodLabelMapper.extractAllCandidates(labelNames);

      if (mapping != null) {
        return MealRecognitionResult(
          primaryDishName: mapping.primaryDishName,
          candidates: allCandidates.isNotEmpty ? allCandidates : [mapping.primaryDishName],
          ingredients: mapping.ingredients,
          rawLabels: rawLabels,
        );
      }

      // 辞書に直接ヒットしなかった場合、信頼度最上位ラベルを使用
      final topLabel = labels.first.label;
      return MealRecognitionResult(
        primaryDishName: topLabel,
        candidates: allCandidates.isNotEmpty ? allCandidates : [topLabel],
        ingredients: const [],
        rawLabels: rawLabels,
      );
    } finally {
      if (_labeler == null) {
        await labeler.close();
      }
    }
  }

  Future<void> dispose() async {
    await _labeler?.close();
  }
}
