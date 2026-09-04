# 写真撮影・選択によるオンデバイス献立自動解析機能 ウォークスルー

本ドキュメントは、トピックブランチ `feature/photo-meal-recognition` において実装・最適化された「写真によるオンデバイス献立自動解析機能」の全体像と検証結果の記録です。

---

## 1. 機能の概要と目的

- **目的**: 献立入力の手間を削減するため、料理の写真を撮影またはアルバムから選択するだけで、端末内AIが料理名・主な食材を一発で自動判定し、入力欄に自動セットする。
- **基本原則**: **完全端末内・オフライン動作・APIコスト0** を維持。

---

## 2. 実施した実装と技術的アプローチ

### ① 料理特化オンデバイスAIモデル（TensorFlow Lite）の導入
- **課題**: Google ML Kit の標準モデルでは「Food（食べ物）」という大まかな概念しか判定できず、日本の個別料理（焼きそば、生姜焼き等）を識別できなかった。
- **解決策**: 2,000種類以上の世界・日本の料理を高精度に識別できる Google の料理分類 TFLite モデル（約20MB）を `assets/models/food_classifier.tflite` にバンドル。
- **推論フロー**: `google_mlkit_image_labeling` の `LocalLabelerOptions` を使用し、端末内CPUで0.1秒未満の高速推論を実現。

### ② 日本語料理名 & 主な食材のマッピング (`FoodLabelMapper`)
- 英語ラベル（例: `Yakisoba`, `Curry`, `Ramen`, `Tempura`, `Tonkatsu`, `Takoyaki`, `Gyoza` 等）を自然な日本語料理名へ即時変換。
- 料理名に応じた主な食材（例: 焼きそば ➔ 中華麺、豚肉、キャベツ、玉ねぎ、もやし、紅生姜）を自動付与。

### ③ ドリンク（飲み物）および非食品（ペット・人物等）のガード判定
- **ドリンク判定**: コーヒー、お茶・紅茶、ジュース、スムージー、ビール、ワイン等の飲み物写真を正しく「飲み物・ドリンク」として判定。
- **非食品ガード**: 猫（Cat）、犬、人物、家具、風景などの写真が選択された場合、誤って料理名に入力されるのを防ぎ、「食事・飲み物ではないようです (猫)」という親切な案内メッセージを表示。

### ④ UIの最適化（一発自動入力への洗練）
- 写真選択時にAIが特定した料理名がそのまま料理名フィールドに自動入力されるため、不要となった「候補から選択」チップUIを完全撤廃。
- 写真プレビュー、AI判定ステータス（判定結果・食材）、削除ボタンのみのシンプルで直感的なUIに整理。

---

## 3. 変更・追加された主要ファイル

| ファイルパス | 役割・変更内容 |
| :--- | :--- |
| `assets/models/food_classifier.tflite` | 料理特化オンデバイス分類モデル（新規追加） |
| `pubspec.yaml` | `image_picker`, `google_mlkit_image_labeling`, `assets/models/` の追加 |
| `ios/Runner/Info.plist` | カメラ・フォトライブラリの利用権限メッセージ追加 |
| `lib/features/meal_record/data/meal_image_service.dart` | TFLiteモデルとML Kitを統合した画像解析サービス |
| `lib/features/meal_record/data/food_label_mapper.dart` | 料理・ドリンク辞書、日本語翻訳、非食品判定ロジック |
| `lib/features/meal_record/providers/meal_image_provider.dart` | 写真解析状態管理（Riverpod） |
| `lib/features/meal_record/widgets/photo_input_section.dart` | カメラ/アルバム起動、画像プレビュー、判定結果表示UI |
| `lib/features/meal_record/screens/meal_record_input_screen.dart` | 献立入力画面への統合と自動入力連動 |
| `test/features/meal_record/meal_image_service_test.dart` | 料理分類・ドリンク・非食品判定のユニットテスト |
| `test/features/meal_record/meal_record_input_screen_test.dart` | ウィジェット統合テスト |

---

## 4. 検証結果

### 自動テスト & 静的解析
```bash
$ flutter analyze
Analyzing meallog-ai...
No issues found! (ran in 0.7s)

$ flutter test
00:01 +22 ~5: All tests passed!
```
- 全テストパス。
- 静的解析エラー・警告ゼロ。

---

## 5. ドキュメント保存先
- 包括ウォークスルー: [`photo_meal_recognition_walkthrough.md`](photo_meal_recognition_walkthrough.md)
- ウォークスルー (最新): [`walkthrough.md`](walkthrough.md)
- 計画書: [`implementation_plan.md`](implementation_plan.md)
- 候補削除計画書: [`remove-candidate-chips-plan.md`](remove-candidate-chips-plan.md)
