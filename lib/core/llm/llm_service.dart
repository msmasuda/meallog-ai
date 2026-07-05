// lib/core/llm/llm_service.dart
import 'package:llamadart/llamadart.dart';

class LlmService {
  LlamaEngine? _engine;
  bool get isReady => _engine != null;

  Future<void> loadModel(String modelPath) async {
    final engine = LlamaEngine(LlamaBackend());
    await engine.loadModel(
      modelPath,
      modelParams: const ModelParams(contextSize: 2048, gpuLayers: 0),
    );
    _engine = engine;
  }

  Stream<String> suggestNextMeal({
    required List<String> recentMeals,
    String mealType = '夕食',
  }) {
    if (_engine == null) throw StateError('モデルが未ロードです');
    return _engine!.generate(
      buildPrompt(recentMeals: recentMeals, mealType: mealType),
    );
  }

  static String buildPrompt({
    required List<String> recentMeals,
    String mealType = '夕食',
  }) {
    final historyText = recentMeals.isEmpty ? '（記録なし）' : recentMeals.join('、');
    // ChatML format required by Qwen2.5-Instruct
    return '<|im_start|>system\nあなたは献立提案アシスタントです。料理名だけを1行で答えてください。<|im_end|>\n<|im_start|>user\n直近の献立: $historyText\n次の$mealTypeを1つ提案してください。<|im_end|>\n<|im_start|>assistant\n';
  }

  Future<void> dispose() async {
    await _engine?.dispose();
    _engine = null;
  }
}
