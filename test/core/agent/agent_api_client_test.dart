import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:meallog_ai/core/agent/agent_api_client.dart';

void main() {
  test('meal suggestion prompt contains history, meal type, and output rule',
      () {
    final prompt = buildMealSuggestionPrompt(
      ['鶏の照り焼き', '豚汁'],
      '昼食',
    );

    expect(prompt, contains('鶏の照り焼き'));
    expect(prompt, contains('豚汁'));
    expect(prompt, contains('昼食'));
    expect(prompt, contains('料理名だけを1行'));
    expect(prompt, contains('ツールは使用せず'));
  });

  test('SSE parser ignores heartbeats and emits named events', () async {
    final source = Stream<List<int>>.fromIterable([
      utf8.encode(': stream-heartbeat\n\n'),
      utf8.encode(
        'event: assistant.delta\n'
        'data: {"delta":"麻"}\n\n'
        'event: message.completed\n'
        'data: {"content":"麻婆豆腐"}\n\n',
      ),
    ]);

    final events = await parseSse(source).toList();

    expect(events, hasLength(2));
    expect(events.first.name, 'assistant.delta');
    expect(events.first.data, '{"delta":"麻"}');
    expect(events.last.name, 'message.completed');
  });

  test('SSE parser joins multiline data', () async {
    final source = Stream.value(
      utf8.encode('event: example\ndata: first\ndata: second\n\n'),
    );

    final event = await parseSse(source).single;

    expect(event.name, 'example');
    expect(event.data, 'first\nsecond');
  });
}
