# Bonsai 27B 実機検証(実験用ブランチ)設計

## 背景・目的

2026-07-14にPrismMLが発表した27Bパラメータモデル「Bonsai 27B」を試したい。1-bit量子化(Q1_0)で重み約3.8GBまで圧縮されており、GGUF形式でllama.cpp互換とされている([PrismML公式発表](https://prismml.com/news/bonsai-27b), [HuggingFace: prism-ml/Bonsai-27B-gguf](https://huggingface.co/prism-ml/Bonsai-27B-gguf))。

本アプリ(MealLog AI)は現在 Qwen2.5-1.5B-Instruct(重み約1.1GB)をllamadart経由でオンデバイス推論している。過去の調査([[se2-context-creation-failure]])で、iPhone SE2(3GB RAM)は1.1GBの重みですら`Failed to create context`で失敗し、iPhone 17実機では成功することが確定している。Bonsai 27Bはその3倍以上のサイズであり、対応デバイス層が根本的に変わる。

**目的**: 本番の`develop`ブランチには一切影響を与えず、使い捨ての実験用ブランチでBonsai 27Bをダウンロード→ロード→提案生成までE2Eで動かし、手元のiPhone 17実機で「動くかどうか」だけを検証する。UIでのモデル選択やマージは前提としない。

## スコープ

- `develop`から新規ブランチ(例: `experiment/bonsai-27b`)を作成
- 既存のモデル差し替え箇所を一時的にBonsai 27B向けに書き換える
- iPhone 17実機で通常のオンボーディング(モデルダウンロード画面→ホーム画面→提案生成)を通しで確認する
- 検証後、ブランチはマージせず破棄する前提(結果次第で本設計をベースに正式な機能設計を別途起こす)

### スコープ外

- モデル選択UI、環境フラグ、ビルドフレーバーなどの恒久的な切り替え機構は作らない
- マルチモーダル投影ファイル(`Bonsai-27B-mmproj-*.gguf`)や投機的デコード用ドラフトモデル(`Bonsai-27B-dspark-*.gguf`)は使わない
- 自動テストは追加しない(手動の実機スパイク)
- iPhone SE2 など低RAM機種での動作検証は対象外(そもそも現行1.5Bでも動かないため)

## 変更内容

### 1. モデル配信設定 (`lib/core/llm/model_download_service.dart`)

`kDefaultModelUrl` と `_modelFileName` を差し替える:

- URL: `https://huggingface.co/prism-ml/Bonsai-27B-gguf/resolve/main/Bonsai-27B-Q1_0.gguf`(1-bit量子化, 約3.8GB)
- ファイル名: `bonsai-27b-q1_0.gguf`

`ModelDownloadService.download`(Dioラッパー、進捗コールバック)自体はサイズ非依存の実装なので変更不要。

### 2. `ModelParams` 調整 (`lib/core/llm/llm_service.dart`)

`loadModel`内の`ModelParams`:

- `gpuLayers: 0 → 99` — CPU推論では27B級は非現実的に遅いため、Metal GPUへほぼ全レイヤーオフロードする(iPhone 17は既存の1.5Bテストで Metal バックエンド動作実績あり)
- `contextSize: 512`, `batchSize: 128` は現行値を維持 — ベンダー公称でQ1_0は4Kコンテキスト時ピーク約5.2GB RAM。小さいコンテキストのままメモリに余裕を持たせる

### 3. プロンプト生成方式

現行の`buildPrompt`はQwen2.5-Instruct向けに手書きしたChatML文字列を`engine.generate(prompt)`に渡す方式。Bonsai 27B(Qwen3.6ベース)の正確なチャットテンプレートは未公開であり、Qwen3系モデルは`<think>`推論ブロックを含むことがあるなど差異のリスクがある。

そのためllamadart 0.8.12に既存の構造化チャットAPIを使う:

```dart
engine.create(
  [LlamaChatMessage.fromText(role: LlamaChatRole.system, text: ...), ...],
  enableThinking: false,
)
```

このAPIはGGUFに埋め込まれたモデル自身のJinjaチャットテンプレートを自動適用するため、テンプレート形式を手動で当てにいく必要がない。返り値は`Stream<LlamaCompletionChunk>`(OpenAI形式のdelta)なので、`chunk.choices.first.delta.content`を取り出して既存の「累積文字列をStream<String>で流す」契約(`mealSuggestionProvider`が前提とする、各emitが全文であってdeltaでない)に変換する。

実装は`LlmService`に既存の`suggestNextMeal`/`buildPrompt`とは別のメソッド(例: `suggestNextMealViaChat`)として追加し、デフォルトモデル用の既存経路には触れない。呼び出し側(`mealSuggestionProvider`)の切り替えは実験ブランチ内でこの新メソッドを呼ぶよう一時的に変更する。

## 成功基準

- iPhone 17実機で3.8GBのモデルファイルがダウンロード完了する
- `LlmService.loadModel`が例外なく完了する(`Failed to create context`が出ない)
- ホーム画面から提案リクエストを送り、料理名を含むテキストがストリーミングで返ってくる

## リスク・不明点

- Bonsai 27Bの実際のチャットテンプレートやRAM消費は未検証(ベンダー公称値のみ)。`create()`経由でも失敗する場合はテンプレート形式の追加調査が必要。
- 3.8GBのダウンロードにDioのデフォルトタイムアウト設定で問題が出る可能性(未検証、発生時は個別対応)。
- iPhone 17(base, Pro不明)の実RAM容量は未確認。ピーク5.2GB前後が実機の空きメモリに収まるかは実測が必要。
