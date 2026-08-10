# つぎのごはん（MealLog AI）

毎日の食事を記録し、直近の履歴と重複しない次の献立をAIが提案するFlutterアプリです。

食事履歴と推論処理は端末内で扱い、クラウドAPIやAPIキーを必要としません。

## 主な機能

- 朝食・昼食・夕食・間食の記録
- 日付別の献立履歴表示
- 直近の献立を考慮した次の献立提案
- 生成中の提案テキストをストリーミング表示
- 提案された料理に応じたカテゴリ別イラスト表示
- 提案の採用・再提案

## AIモデル

利用可能な場合はOSが提供する端末内モデルを優先し、非対応端末ではアプリが管理するGGUFモデルへフォールバックします。

| プラットフォーム | 優先モデル | フォールバック |
|---|---|---|
| iOS | Apple Foundation Models | llamadart + Qwen3.5 GGUF |
| Android | Gemini Nano（ML Kit Prompt API） | llamadart + Qwen3.5 GGUF |

### iOS

- Foundation ModelsはiOS 26以降かつApple Intelligence対応実機で利用します。
- Apple Intelligenceが無効、モデル準備中、非対応端末の場合はGGUFモデルを利用します。
- シミュレーターでは通常、GGUFモデルへフォールバックします。

### Android

- Gemini NanoはAndroidのAICoreを通じて利用します。
- 対応端末では必要に応じてシステムモデルを準備します。
- Gemini Nanoを利用できない端末ではGGUFモデルを利用します。
- ML Kit Prompt APIの要件に合わせ、最小SDKはAPI 26です。

### GGUFフォールバック

GGUFフォールバックの全対象端末で、評価用にQwen3.5-0.8B Q4_K_M（約580MB）を初回起動時にダウンロードします。モデルはアプリのドキュメントディレクトリへ保存され、その後の推論はオフラインで動作します。Qwen3.5ではGGUFに埋め込まれたチャットテンプレートを利用し、献立提案では思考モードを無効にして料理名だけを生成します。

## 開発環境

- Flutter（Dart 3.4以降）
- iOS 16.4以降
- Android API 26以降
- Xcode 26以降（Foundation Modelsをビルドする場合）

依存関係を取得します。

```bash
flutter pub get
```

RiverpodプロバイダーやIsarモデルを変更した場合は、生成コードを更新します。

```bash
dart run build_runner build --delete-conflicting-outputs
```

## 実行

```bash
flutter run
```

OS純正モデルの動作確認には、各モデルに対応した実機を使用してください。

## テストと静的解析

```bash
flutter analyze
flutter test
```

単一テストを実行する例：

```bash
flutter test test/features/suggestion/suggestion_provider_test.dart
flutter test --name "accumulates tokens"
```

## プロジェクト構成

```text
lib/
├── core/
│   ├── db/          # Isar初期化
│   ├── llm/         # 純正モデル連携、GGUFモデル、ダウンロード
│   └── router/      # 画面遷移とモデル準備ゲート
└── features/
    ├── home/        # ホーム
    ├── meal_record/ # 献立記録
    ├── history/     # 履歴
    ├── suggestion/  # AI提案とカテゴリイラスト
    └── model_setup/ # GGUFモデルの初回準備
```

状態管理にはRiverpod、ローカルデータベースにはIsarを使用しています。iOSとAndroidの純正モデルはMethodChannel経由で共通のDartサービスから呼び出します。
