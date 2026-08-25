// lib/features/meal_record/data/meal_image_service.dart
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:path_provider/path_provider.dart';
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
    this.isFoodOrDrink = true,
    this.category = FoodCategory.food,
    this.nonFoodDescription,
  });

  final String primaryDishName;
  final List<String> candidates;
  final List<String> ingredients;
  final List<RawImageLabel> rawLabels;
  final bool isFoodOrDrink;
  final FoodCategory category;
  final String? nonFoodDescription;
}

class MealImageService {
  MealImageService({
    ImageLabeler? foodLabeler,
    ImageLabeler? baseLabeler,
  })  : _foodLabeler = foodLabeler,
        _baseLabeler = baseLabeler;

  ImageLabeler? _foodLabeler;
  ImageLabeler? _baseLabeler;
  bool _isInitialized = false;

  /// アセットからモデルファイルをローカルに展開し、Custom Local ImageLabeler を準備
  Future<void> _initLabelers() async {
    if (_isInitialized) return;

    if (_foodLabeler == null) {
      try {
        final modelPath = await _copyAssetModelToFile();
        _foodLabeler = ImageLabeler(
          options: LocalLabelerOptions(
            modelPath: modelPath,
            confidenceThreshold: 0.15,
            maxCount: 5,
          ),
        );
      } catch (e) {
        // モデル展開に失敗した場合はベースモデルにフォールバック
        _foodLabeler = null;
      }
    }

    _baseLabeler ??= ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: 0.4),
    );

    _isInitialized = true;
  }

  /// assets 内の tflite モデルをローカルファイルシステムにコピー
  Future<String> _copyAssetModelToFile() async {
    final docDir = await getApplicationSupportDirectory();
    final modelFile = File('${docDir.path}/food_classifier.tflite');
    if (!await modelFile.exists() || await modelFile.length() == 0) {
      final byteData = await rootBundle.load('assets/models/food_classifier.tflite');
      final bytes = byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      );
      await modelFile.writeAsBytes(bytes, flush: true);
    }
    return modelFile.path;
  }

  Future<MealRecognitionResult?> analyzeImage(String imagePath) async {
    await _initLabelers();

    final inputImage = InputImage.fromFilePath(imagePath);

    // 1. まず料理特化モデル (Food Classifier TFLite) で解析
    if (_foodLabeler != null) {
      try {
        final foodLabels = await _foodLabeler!.processImage(inputImage);
        final validLabels = foodLabels
            .where((l) => l.label.toLowerCase() != '__background__' && l.confidence >= 0.15)
            .toList();

        if (validLabels.isNotEmpty) {
          final rawLabels = validLabels
              .map((l) => RawImageLabel(label: l.label, confidence: l.confidence))
              .toList();
          final labelNames = validLabels.map((l) => l.label).toList();

          final mapping = FoodLabelMapper.mapLabels(labelNames);
          final allCandidates = FoodLabelMapper.extractAllCandidates(labelNames);

          if (mapping != null) {
            return MealRecognitionResult(
              primaryDishName: mapping.primaryDishName,
              candidates: allCandidates.isNotEmpty ? allCandidates : mapping.candidates,
              ingredients: mapping.ingredients,
              rawLabels: rawLabels,
              isFoodOrDrink: true,
              category: mapping.category,
            );
          }

          // 辞書に直接ないが料理モデルが特定したラベルの場合
          final topLabel = validLabels.first.label;
          return MealRecognitionResult(
            primaryDishName: topLabel,
            candidates: allCandidates.isNotEmpty
                ? allCandidates
                : [topLabel, ...FoodLabelMapper.defaultMealCandidates],
            ingredients: const [],
            rawLabels: rawLabels,
            isFoodOrDrink: true,
            category: FoodCategory.food,
          );
        }
      } catch (_) {
        // 特化モデル推論エラー時はベースモデルへフォールバック
      }
    }

    // 2. 特化モデルで検出されなかった場合、ベースモデル（ML Kit 標準）で判定
    final baseLabeler = _baseLabeler ?? ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.4));
    try {
      final baseLabels = await baseLabeler.processImage(inputImage);
      if (baseLabels.isEmpty) return null;

      final rawLabels = baseLabels
          .map((l) => RawImageLabel(label: l.label, confidence: l.confidence))
          .toList();
      final labelNames = baseLabels.map((l) => l.label).toList();
      final isFood = FoodLabelMapper.isFoodOrDrink(labelNames);

      // 食事・飲み物ではない場合（猫、犬、人物、家具、電子機器等）
      if (!isFood) {
        final topLabel = baseLabels.first.label;
        final translated = FoodLabelMapper.translateNonFoodLabel(topLabel);
        return MealRecognitionResult(
          primaryDishName: '',
          candidates: const [],
          ingredients: const [],
          rawLabels: rawLabels,
          isFoodOrDrink: false,
          category: FoodCategory.nonFood,
          nonFoodDescription: translated,
        );
      }

      final mapping = FoodLabelMapper.mapLabels(labelNames);
      final allCandidates = FoodLabelMapper.extractAllCandidates(labelNames);

      if (mapping != null) {
        return MealRecognitionResult(
          primaryDishName: mapping.primaryDishName,
          candidates: allCandidates.isNotEmpty ? allCandidates : mapping.candidates,
          ingredients: mapping.ingredients,
          rawLabels: rawLabels,
          isFoodOrDrink: true,
          category: mapping.category,
        );
      }

      return MealRecognitionResult(
        primaryDishName: '料理・食事',
        candidates: allCandidates.isNotEmpty
            ? allCandidates
            : FoodLabelMapper.defaultMealCandidates,
        ingredients: const [],
        rawLabels: rawLabels,
        isFoodOrDrink: true,
        category: FoodCategory.food,
      );
    } finally {
      // 内部生成の一時インスタンスがあればクリーンアップ
    }
  }

  Future<void> dispose() async {
    await _foodLabeler?.close();
    await _baseLabeler?.close();
  }
}
