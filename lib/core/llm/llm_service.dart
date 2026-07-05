// lib/core/llm/llm_service.dart
import 'package:llamadart/llamadart.dart';

class LlmService {
  LlamaEngine? _engine;
  bool get isReady => _engine != null;

  Future<void> loadModel(String modelPath) async {
    final engine = LlamaEngine(LlamaBackend());
    await engine.loadModel(
      modelPath,
      modelParams: const ModelParams(contextSize: 2048, gpuLayers: 20),
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
    final historyText = recentMeals.join('、');
    return '''
あなたは献立提案アシスタントです。以下の直近の献立履歴を見て、
同じ食材や調理法が続かないように、次の$mealType の献立を1つだけ提案してください。

# 直近の献立履歴
$historyText

# 出力形式
料理名だけを1行で答えてください。理由は不要です。
''';
  }

  Future<void> dispose() async {
    await _engine?.dispose();
    _engine = null;
  }
}
