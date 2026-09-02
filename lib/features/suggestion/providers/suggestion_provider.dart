// lib/features/suggestion/providers/suggestion_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/agent/agent_api_provider.dart';
import '../../meal_record/providers/meal_record_provider.dart';

part 'suggestion_provider.g.dart';

@riverpod
Stream<String> mealSuggestion(MealSuggestionRef ref) async* {
  final agentClient = ref.watch(agentSuggestionClientProvider);
  final recentMeals = await ref.watch(recentMealsProvider.future);
  final buffer = StringBuffer();
  await for (final token
      in agentClient.suggestNextMeal(recentMeals: recentMeals)) {
    buffer.write(token);
    yield buffer.toString();
  }
}
