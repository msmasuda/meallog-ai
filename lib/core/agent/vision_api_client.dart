import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

abstract interface class VisionApiClient {
  Future<VisionAnalyzeResponse> analyzeImage({
    required String imagePath,
    required String prompt,
    Map<String, dynamic>? responseSchema,
    String? model,
  });
}

class VisionAnalyzeResponse {
  const VisionAnalyzeResponse({required this.content, required this.model});

  final Object? content;
  final String model;
}

class VisionApiException implements Exception {
  const VisionApiException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

class LangGraphVisionApiClient implements VisionApiClient {
  LangGraphVisionApiClient({
    required String baseUrl,
    String? accessToken,
    Dio? dio,
  })  : _accessToken = accessToken?.trim(),
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: _normalizeBaseUrl(baseUrl),
                connectTimeout: const Duration(seconds: 10),
                // The backend applies its own 120-second vision timeout. Keep
                // the client timeout longer so its structured 504 response is
                // received instead of being reported as a network failure.
                receiveTimeout: const Duration(minutes: 3),
                sendTimeout: const Duration(minutes: 1),
                headers: const {'Accept': 'application/json'},
              ),
            );

  final Dio _dio;
  final String? _accessToken;

  @override
  Future<VisionAnalyzeResponse> analyzeImage({
    required String imagePath,
    required String prompt,
    Map<String, dynamic>? responseSchema,
    String? model,
  }) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imagePath,
          contentType: _contentTypeFor(imagePath),
        ),
        'prompt': prompt,
        if (responseSchema != null)
          'response_schema': jsonEncode(responseSchema),
        if (model != null && model.trim().isNotEmpty) 'model': model.trim(),
      });
      final response = await _dio.post<Map<String, dynamic>>(
        '/v1/vision/analyze',
        data: formData,
        options: Options(headers: _authorizationHeaders),
      );
      final data = response.data;
      final modelName = data?['model'];
      if (data == null || modelName is! String) {
        throw const VisionApiException('画像解析APIの応答形式が不正です');
      }
      return VisionAnalyzeResponse(content: data['content'], model: modelName);
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  Map<String, String> get _authorizationHeaders {
    final token = _accessToken;
    return token == null || token.isEmpty
        ? const {}
        : {'Authorization': 'Bearer $token'};
  }

  static MediaType _contentTypeFor(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return MediaType('image', 'png');
    if (lower.endsWith('.webp')) return MediaType('image', 'webp');
    return MediaType('image', 'jpeg');
  }

  static VisionApiException _toApiException(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final detail = data['error'];
      if (detail is Map<String, dynamic>) {
        final message = detail['message'];
        final code = detail['code'];
        if (message is String) {
          return VisionApiException(
            message,
            code: code is String ? code : null,
          );
        }
      }
    }
    final status = error.response?.statusCode;
    if (status == 401 || status == 403) {
      return const VisionApiException('エージェントの認証に失敗しました');
    }
    if (status == 413) {
      return const VisionApiException('画像サイズが大きすぎます');
    }
    if (status == 429) {
      return const VisionApiException('画像解析の利用上限に達しました');
    }
    if (status != null) {
      return VisionApiException('画像解析APIがエラーを返しました ($status)');
    }
    if (error.type == DioExceptionType.receiveTimeout) {
      return const VisionApiException(
        '画像解析に時間がかかりすぎました。もう一度お試しください',
        code: 'vision_client_timeout',
      );
    }
    if (error.type == DioExceptionType.connectionTimeout) {
      return const VisionApiException(
        '画像解析エージェントへの接続がタイムアウトしました',
        code: 'vision_connection_timeout',
      );
    }
    return const VisionApiException('画像解析エージェントに接続できません');
  }

  static String _normalizeBaseUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(value, 'baseUrl', '接続先URLが空です');
    }
    return trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
  }
}
