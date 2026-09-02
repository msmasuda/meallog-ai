// lib/features/meal_record/providers/meal_image_provider.dart
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/meal_image_service.dart';

part 'meal_image_provider.g.dart';

@riverpod
MealImageService mealImageService(MealImageServiceRef ref) {
  final service = MealImageService();
  ref.onDispose(() => service.dispose());
  return service;
}

class MealImageState {
  const MealImageState({
    this.imagePath,
    this.isLoading = false,
    this.result,
    this.errorMessage,
  });

  final String? imagePath;
  final bool isLoading;
  final MealRecognitionResult? result;
  final String? errorMessage;

  MealImageState copyWith({
    String? imagePath,
    bool? isLoading,
    MealRecognitionResult? result,
    String? errorMessage,
    bool clearImage = false,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return MealImageState(
      imagePath: clearImage ? null : (imagePath ?? this.imagePath),
      isLoading: isLoading ?? this.isLoading,
      result: clearResult ? null : (result ?? this.result),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

@riverpod
class MealImageNotifier extends _$MealImageNotifier {
  @override
  MealImageState build() {
    return const MealImageState();
  }

  Future<void> pickAndAnalyze({
    required ImageSource source,
    ImagePicker? picker,
  }) async {
    final imagePicker = picker ?? ImagePicker();
    final file = await imagePicker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (file == null) return;

    state = state.copyWith(
      imagePath: file.path,
      isLoading: true,
      clearResult: true,
      clearError: true,
    );

    try {
      final service = ref.read(mealImageServiceProvider);
      final result = await service.analyzeImage(file.path);
      state = state.copyWith(
        isLoading: false,
        result: result,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '画像の解析に失敗しました',
      );
    }
  }

  void clear() {
    state = const MealImageState();
  }
}
