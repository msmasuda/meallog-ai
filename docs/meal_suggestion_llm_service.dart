// pubspec.yaml に以下を追加してから使う:
// dependencies:
//   llamadart: ^最新バージョン
//
// モデルファイル(.gguf)は初回起動時にダウンロードするか、
// assets に同梱する(同梱する場合はサイズに注意)。
// 例: gemma-3-1b-it-Q4_K_M.gguf など。

import 'package:llamadart/llamadart.dart';

/// 献立履歴を渡すと、AIが次の献立を提案してくれるサービス。
/// オンデバイスLLM(llama.cpp/GGUF)を使う。
class MealSuggestionLlmService {
  LlamaEngine? _engine;
  bool get isReady => _engine != null;

  /// モデルをロードする。アプリ起動時や設定画面で一度だけ呼ぶ想定。
  Future<void> loadModel(String modelPath) async {
    final engine = LlamaEngine();
    await engine.loadModel(
      path: modelPath,
      contextSize: 2048, // 献立履歴+プロンプトなら2048で十分なはず
      gpuLayers: 20,      // 端末のGPU性能に応じて調整(0=CPUのみ)
    );
    _engine = engine;
  }

  /// 直近の献立履歴から、次の献立を提案してもらう。
  ///
  /// [recentMeals] 例: ["鶏の照り焼き", "豚汁", "サバの味噌煮", "麻婆豆腐"]
  /// 戻り値はストリーミングで返る(UIでStreamBuilderに繋ぐ想定)。
  Stream<String> suggestNextMeal({
    required List<String> recentMeals,
    String mealType = "夕食",
  }) {
    if (_engine == null) {
      throw StateError('モデルが未ロードです。先に loadModel() を呼んでください。');
    }

    final prompt = _buildPrompt(recentMeals, mealType);
    return _engine!.generate(prompt);
  }

  /// プロンプトを組み立てる。
  /// オンデバイスの小型モデルは「知識」よりも「整形・言い換え」が得意なので、
  /// タスクを絞ったシンプルな指示にするのがポイント。
  String _buildPrompt(List<String> recentMeals, String mealType) {
    final historyText = recentMeals.join('、');
    return '''
あなたは献立提案アシスタントです。以下の直近の献立履歴を見て、
同じ食材や調理法が続かないように、次の$mealTypeの献立を1つだけ提案してください。

# 直近の献立履歴
$historyText

# 出力形式
料理名だけを1行で答えてください。理由は不要です。
''';
  }

  Future<void> dispose() async {
    // メモリ解放。画面遷移や不使用時に呼ぶ。
    _engine = null; // 実際のAPIに合わせて close() 等があれば呼ぶ
  }
}
