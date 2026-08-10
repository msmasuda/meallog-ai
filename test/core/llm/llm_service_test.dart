// test/core/llm/llm_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:llamadart/llamadart.dart';
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

  test('buildPlainPrompt contains history and asks for one dish name', () {
    final prompt = LlmService.buildPlainPrompt(
      recentMeals: ['そば', 'カレー'],
      mealType: '昼食',
    );
    expect(prompt, contains('そば、カレー'));
    expect(prompt, contains('昼食'));
    expect(prompt, contains('料理名だけを1行'));
  });

  test('buildChatMessages includes history and meal type', () {
    final messages = LlmService.buildChatMessages(
      recentMeals: ['そば', 'カレー'],
      mealType: '昼食',
    );

    expect(messages, hasLength(2));
    expect(messages.first.role, LlamaChatRole.system);
    expect(messages.last.role, LlamaChatRole.user);
    expect(messages.last.content, contains('そば、カレー'));
    expect(messages.last.content, contains('昼食'));
  });

  test('chatDeltaContent yields only non-empty content in order', () async {
    final chunks = Stream<LlamaCompletionChunk>.fromIterable([
      _chunkWithContent('親'),
      _chunkWithContent(null),
      _chunkWithContent(''),
      _chunkWithContent('子丼'),
      LlamaCompletionChunk(
        id: 'test',
        object: 'chat.completion.chunk',
        created: 0,
        model: 'qwen3.5-0.8b',
        choices: const [],
      ),
    ]);

    expect(await LlmService.chatDeltaContent(chunks).toList(), ['親', '子丼']);
  });
}

LlamaCompletionChunk _chunkWithContent(String? content) {
  return LlamaCompletionChunk(
    id: 'test',
    object: 'chat.completion.chunk',
    created: 0,
    model: 'qwen3.5-0.8b',
    choices: [
      LlamaCompletionChunkChoice(
        index: 0,
        delta: LlamaCompletionChunkDelta(content: content),
      ),
    ],
  );
}
