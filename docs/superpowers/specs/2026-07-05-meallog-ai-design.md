# MealLog AI (つぎのごはん) — 設計ドキュメント

**作成日:** 2026-07-05  
**ストア表示名:** つぎのごはん  
**開発内部名:** MealLog AI  
**プラットフォーム:** Flutter (iOS / Android)

---

## 1. 概要

日々の献立を記録すると、オンデバイスLLM（llamadart / GGUF）が次の献立を提案してくれるスマホアプリ。マンネリ回避を主目的とし、APIコストゼロ・オフライン動作を実現する。

**MVPスコープ:**
- 献立記録（テキスト入力）
- AI提案（マンネリ回避、ストリーミング表示）
- 履歴一覧（リスト表示）
- 初回起動時モデルダウンロード

---

## 2. 技術スタック

| 役割 | 採用技術 |
|---|---|
| フレームワーク | Flutter |
| 状態管理 | Riverpod (riverpod_annotation + riverpod_generator) |
| ローカルDB | Isar |
| オンデバイスLLM | llamadart (GGUF / llama.cpp) |
| ナビゲーション | GoRouter |
| HTTPクライアント | dio (モデルダウンロード用) |
| ファイルパス | path_provider |
| 初回起動フラグ | shared_preferences |

---

## 3. フォルダ構成

```
lib/
  features/
    meal_record/
      data/
        meal_record_model.dart       # Isarスキーマ
        meal_record_repository.dart
      providers/
        meal_record_provider.dart
      screens/
        meal_record_input_screen.dart
      widgets/
        meal_type_selector.dart
    suggestion/
      data/
        suggestion_model.dart        # Isarスキーマ
        suggestion_repository.dart
      providers/
        suggestion_provider.dart     # StreamNotifier (LLMストリーミング)
      screens/
        suggestion_screen.dart
      widgets/
        streaming_text_widget.dart
    history/
      providers/
        history_provider.dart
      screens/
        history_screen.dart
      widgets/
        history_list_tile.dart
  core/
    db/
      isar_service.dart              # DB初期化・シングルトン
    llm/
      llm_service.dart               # llamadartラッパー
      model_download_service.dart    # HuggingFaceからダウンロード
    router/
      app_router.dart                # GoRouter定義
  app.dart
  main.dart
```

---

## 4. データモデル（Isarスキーマ）

```dart
@collection
class MealRecord {
  Id id = Isar.autoIncrement;
  late DateTime date;
  late String mealType; // 'breakfast' | 'lunch' | 'dinner' | 'snack'
  late String dishName;
  List<String> ingredients = []; // MVP段階では入力UI省略、フィールドのみ
  late DateTime createdAt;
}

@collection
class Suggestion {
  Id id = Isar.autoIncrement;
  late DateTime targetDate;
  late String mealType;
  late String suggestedDish;
  String? feedback; // 'good' | 'bad' | null
  late DateTime createdAt;
}
```

提案理由（reason）はLLMのストリーミング出力をそのままUIに表示するため、DBには保存しない。

---

## 5. プロバイダー構成（Riverpod）

| プロバイダー | 種別 | 責務 |
|---|---|---|
| `isarProvider` | `FutureProvider` | DB初期化・シングルトン |
| `mealRecordRepoProvider` | `Provider` | MealRecord のCRUD |
| `recentMealsProvider` | `FutureProvider` | 直近7日分の献立取得（プロンプト構築用） |
| `historyProvider` | `AsyncNotifier` | 履歴一覧の取得・更新 |
| `llmServiceProvider` | `AsyncNotifier` | LlamaEngine のライフサイクル管理 |
| `modelDownloadProvider` | `AsyncNotifier` | ダウンロード進捗（0.0〜1.0） |
| `suggestionProvider` | `StreamNotifier` | LLMストリーミング応答 |

---

## 6. 画面構成とナビゲーション（GoRouter）

| ルート | 画面 | 内容 |
|---|---|---|
| `/model-setup` | モデルセットアップ | 初回起動時のみ。ダウンロード進捗バー表示 |
| `/` | ホーム | 今日の献立リスト + 「AI提案を受ける」ボタン |
| `/record/add` | 献立入力 | 食事タイプ選択 + 料理名入力 |
| `/suggestion` | AI提案 | ストリーミングテキスト + フィードバックボタン（👍👎） |
| `/history` | 履歴一覧 | 日付ごとの献立リスト（降順） |

**初回起動判定:** `shared_preferences` にフラグを保持。モデルダウンロード完了後に立てる。次回以降は `/` に直接遷移。

**ボトムナビゲーション:** ホーム・履歴 の2タブ（将来: 設定タブ追加）。モデルセットアップ画面はボトムナビなし。

---

## 7. LLM統合フロー

1. アプリ起動 → モデルファイルの存在チェック（`path_provider` + `shared_preferences`）
2. 未取得 → `/model-setup` へリダイレクト → `modelDownloadProvider` が HuggingFace からダウンロード（dioで進捗取得）
3. ダウンロード完了 → `llmServiceProvider` が `LlamaEngine.loadModel()` を呼ぶ（バックグラウンド）
4. ホーム画面で「AI提案」ボタン押下 → `recentMealsProvider` から直近7日の献立を取得してプロンプト構築
5. `suggestionProvider` が `suggestNextMeal()` を呼びストリーミング開始
6. UIは `StreamBuilder` でトークンを逐次表示

---

## 8. 技術的決定事項

| 項目 | 決定内容 |
|---|---|
| iOS デプロイターゲット | 16.4以上（llamadart要件） |
| モデル保存先 | `getApplicationDocumentsDirectory()` 配下 |
| ダウンロード対象モデル | Gemma 3 1B Q4_K_M / Qwen2.5 1.5B Q4_K_M（HuggingFace） |
| gpuLayers | デフォルト20（将来: 設定画面で変更可能） |
| contextSize | 2048（直近7〜10件の献立なら十分） |
| モデル切り替えUI | Phase 2で設定画面に追加 |

---

## 9. 主要パッケージ（pubspec.yaml）

```yaml
dependencies:
  flutter_riverpod: ^2.x
  riverpod_annotation: ^2.x
  isar: ^3.x
  isar_flutter_libs: ^3.x
  llamadart: latest
  go_router: ^14.x
  shared_preferences: ^2.x
  dio: ^5.x
  path_provider: ^2.x

dev_dependencies:
  build_runner: ^2.x
  isar_generator: ^3.x
  riverpod_generator: ^2.x
```

---

## 10. 将来拡張（Phase 2以降）

- 食材タグ入力UI
- 栄養バランス切り口（クラウドAPI）
- モデル切り替え設定画面（Gemma vs Qwen比較）
- 分析画面（頻出ランキング・グラフ）
- 写真添付
- 家族共有機能
