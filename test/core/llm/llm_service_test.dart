// test/core/llm/llm_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:meallog_ai/core/llm/llm_service.dart';

void main() {
  test('buildPrompt contains all recent meals and meal type', () {
    final prompt = LlmService.buildPrompt(
      recentMeals: ['鶏の照り焼き', '豚汁', 'サバの味噌煮'],
      mealType: '夕食',
    );
    expect(prompt, contains('鶏の照り焼き'));
    expect(prompt, contains('豚汁'));
    expect(prompt, contains('サバの味噌煮'));
    expect(prompt, contains('夕食'));
    expect(prompt, contains('料理名だけを1行'));
  });

  test('buildPrompt uses 夕食 as default mealType', () {
    final prompt = LlmService.buildPrompt(recentMeals: ['そば']);
    expect(prompt, contains('夕食'));
  });
}
