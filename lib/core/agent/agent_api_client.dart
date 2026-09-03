import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';

abstract interface class AgentSuggestionClient {
  Stream<String> suggestNextMeal({
    required List<String> recentMeals,
    String mealType = '夕食',
  });
}

class AgentApiException implements Exception {
  const AgentApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class LangGraphAgentClient implements AgentSuggestionClient {
  LangGraphAgentClient({
    required String baseUrl,
    String? accessToken,
    Dio? dio,
  })  : _accessToken = accessToken?.trim(),
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: _normalizeBaseUrl(baseUrl),
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(minutes: 3),
                sendTimeout: const Duration(seconds: 10),
                headers: const {'Accept': 'application/json'},
              ),
            );

  final Dio _dio;
  final String? _accessToken;
  final Random _random = Random.secure();

  static String _normalizeBaseUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(value, 'baseUrl', '接続先URLが空です');
    }
    return trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
  }

  @override
  Stream<String> suggestNextMeal({
    required List<String> recentMeals,
    String mealType = '夕食',
  }) async* {
    try {
      final conversationId = await _createConversation();
      final response = await _dio.post<ResponseBody>(
        '/v1/conversations/$conversationId/messages/stream',
        data: {'content': buildMealSuggestionPrompt(recentMeals, mealType)},
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            ..._authorizationHeaders,
            'Accept': 'text/event-stream',
            'Content-Type': 'application/json',
            'Idempotency-Key': _newRequestId(),
          },
        ),
      );

      final body = response.data;
      if (body == null) {
        throw const AgentApiException('エージェントから応答を受信できませんでした');
      }

      var completed = false;
      var receivedDelta = false;
      await for (final event in parseSse(body.stream)) {
        switch (event.name) {
          case 'assistant.delta':
            final delta =
                _readText(event.data, const ['delta', 'content', 'text']);
            if (delta != null && delta.isNotEmpty) {
              receivedDelta = true;
              yield delta;
            }
            break;
          case 'message.completed':
            completed = true;
            if (!receivedDelta) {
              final content =
                  _readText(event.data, const ['content', 'text', 'message']);
              if (content != null && content.isNotEmpty) yield content;
            }
            break;
          case 'message.failed':
            throw AgentApiException(
              _readText(event.data, const ['message', 'detail', 'error']) ??
                  '献立提案の生成に失敗しました',
            );
          default:
            break;
        }
      }

      if (!completed) {
        throw const AgentApiException('エージェントとの接続が途中で終了しました');
      }
    } on DioException catch (error) {
      throw AgentApiException(_dioErrorMessage(error));
    }
  }

  Future<String> _createConversation() async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/v1/conversations',
      options: Options(headers: _authorizationHeaders),
    );
    final id = response.data?['id'];
    if (id is! String || id.isEmpty) {
      throw const AgentApiException('会話の開始に失敗しました');
    }
    return id;
  }

  Map<String, String> get _authorizationHeaders {
    final token = _accessToken;
    return token == null || token.isEmpty
        ? const {}
        : {'Authorization': 'Bearer $token'};
  }

  String _newRequestId() {
    final micros = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
    final suffix = _random.nextInt(0x7fffffff).toRadixString(16);
    return 'meallog-$micros-$suffix';
  }

  static String _dioErrorMessage(DioException error) {
    final status = error.response?.statusCode;
    if (status == 401 || status == 403) {
      return 'エージェントの認証に失敗しました';
    }
    if (status == 409) return 'エージェントが別の処理を実行中です';
    if (status != null) return 'エージェントがエラーを返しました ($status)';
    return 'エージェントに接続できません';
  }

  static String? _readText(String data, List<String> keys) {
    try {
      final decoded = jsonDecode(data);
      if (decoded is String) return decoded;
      if (decoded is Map<String, dynamic>) {
        for (final key in keys) {
          final value = decoded[key];
          if (value is String) return value;
          if (value is Map<String, dynamic>) {
            final nested = value['message'] ?? value['detail'];
            if (nested is String) return nested;
          }
        }
      }
    } on FormatException {
      return data.trim().isEmpty ? null : data;
    }
    return null;
  }
}

String buildMealSuggestionPrompt(List<String> recentMeals, String mealType) {
  final history = recentMeals.isEmpty
      ? '・記録なし'
      : recentMeals.map((meal) => '・$meal').join('\n');
  return 'あなたは献立提案アシスタントです。\n'
      '以下は直近7日間の食事です。\n\n'
      '$history\n\n'
      '過去の献立との重複を避け、次の$mealTypeを1つ提案してください。\n'
      'ツールは使用せず、料理名だけを1行で返してください。';
}

class SseEvent {
  const SseEvent({required this.name, required this.data});

  final String name;
  final String data;
}

Stream<SseEvent> parseSse(Stream<List<int>> bytes) async* {
  var eventName = 'message';
  final dataLines = <String>[];

  await for (final line in bytes
      .map<List<int>>((chunk) => chunk)
      .transform(utf8.decoder)
      .transform(const LineSplitter())) {
    if (line.isEmpty) {
      if (dataLines.isNotEmpty) {
        yield SseEvent(name: eventName, data: dataLines.join('\n'));
      }
      eventName = 'message';
      dataLines.clear();
      continue;
    }
    if (line.startsWith(':')) continue;
    if (line.startsWith('event:')) {
      eventName = line.substring(6).trim();
    } else if (line.startsWith('data:')) {
      dataLines.add(line.substring(5).trimLeft());
    }
  }

  if (dataLines.isNotEmpty) {
    yield SseEvent(name: eventName, data: dataLines.join('\n'));
  }
}
