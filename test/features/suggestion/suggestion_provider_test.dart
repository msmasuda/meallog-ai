// test/features/suggestion/suggestion_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meallog_ai/core/agent/agent_api_client.dart';
import 'package:meallog_ai/core/agent/agent_api_provider.dart';
import 'package:meallog_ai/features/meal_record/providers/meal_record_provider.dart';
import 'package:meallog_ai/features/suggestion/providers/suggestion_provider.dart';

class MockAgentSuggestionClient extends Mock implements AgentSuggestionClient {}

void main() {
  test('mealSuggestionProvider accumulates tokens into growing string',
      () async {
    final mockAgent = MockAgentSuggestionClient();
    when(() => mockAgent.suggestNextMeal(
          recentMeals: any(named: 'recentMeals'),
          mealType: any(named: 'mealType'),
        )).thenAnswer((_) => Stream.fromIterable(['麻', '婆', '豆', '腐']));

    final container = ProviderContainer(overrides: [
      agentSuggestionClientProvider.overrideWithValue(mockAgent),
      recentMealsProvider.overrideWith((ref) async => ['鶏の照り焼き']),
    ]);
    addTearDown(container.dispose);

    // Collect all emitted values via listen (provider.future returns first emit, not last)
    final emitted = <String>[];
    container.listen<AsyncValue<String>>(
      mealSuggestionProvider,
      (_, next) => next.whenData(emitted.add),
      fireImmediately: true,
    );

    // Allow all synchronous microtasks from Stream.fromIterable to complete
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(emitted, isNotEmpty);
    expect(emitted.last, equals('麻婆豆腐'));
  });
}
