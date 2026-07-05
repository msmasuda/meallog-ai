// lib/features/suggestion/providers/suggestion_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/llm/llm_provider.dart';
import '../../meal_record/providers/meal_record_provider.dart';

part 'suggestion_provider.g.dart';

@riverpod
Stream<String> mealSuggestion(MealSuggestionRef ref) async* {
  final llmService = await ref.watch(llmServiceNotifierProvider.future);
  final recentMeals = await ref.watch(recentMealsProvider.future);
  final buffer = StringBuffer();
  await for (final token in llmService.suggestNextMeal(recentMeals: recentMeals)) {
    buffer.write(token);
    yield buffer.toString();
  }
}
