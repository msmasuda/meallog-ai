import 'package:flutter/services.dart';

/// Apple Foundation Models / Gemini Nano への共通ブリッジ。
class NativeLlmBridge {
  NativeLlmBridge({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel(_channelName);

  static const _channelName = 'meallog_ai/native_llm';
  final MethodChannel _channel;

  Future<bool> isSupported() async {
    try {
      return await _channel.invokeMethod<bool>('isSupported') ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<void> prepare() async {
    await _channel.invokeMethod<void>('prepare');
  }

  Future<String> generate(String prompt) async {
    final result = await _channel.invokeMethod<String>(
      'generate',
      <String, Object?>{'prompt': prompt},
    );
    if (result == null || result.trim().isEmpty) {
      throw StateError('端末内AIから応答がありませんでした');
    }
    return result.trim();
  }
}
