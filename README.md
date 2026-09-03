# つぎのごはん（MealLog AI）

毎日の食事を記録し、直近の履歴と重複しない次の献立をAIが提案するFlutterアプリです。

食事履歴は端末内に保存し、献立提案と写真解析には外部のLangGraphエージェントを使用します。献立提案時には直近の料理名と食事種別、写真解析時には選択した画像をエージェントへ送信します。

## 主な機能

- 朝食・昼食・夕食・間食の記録
- 写真から料理名・候補・食材を解析して入力を補助
- 日付別の献立履歴表示
- 直近の献立を考慮した次の献立提案
- 生成中の提案テキストをストリーミング表示
- 提案された料理に応じたカテゴリ別イラスト表示
- 提案の採用・再提案

## AIエージェント

献立提案には会話ストリーミングAPI、写真解析には汎用画像解析API（`/v1/vision/analyze`）を使用します。モデルは基本的にエージェント側で選択し、写真解析のみ`AGENT_VISION_MODEL`で指定できます。

現在の動作経路では端末内LLMを使用せず、GGUFモデルの初回ダウンロードも不要です。AI機能にはエージェントへのネットワーク接続が必要です。

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

初回のみ、プロジェクト直下に手元用の設定ファイルを作成します。既に`.env`がある場合はコピーせず、そのファイルを編集してください。

```bash
cp .env.example .env
```

`.env`の`AGENT_API_BASE_URL`をエージェントの接続先に変更します。実機で使う場合は`localhost`ではなく、エージェントを動かすMacのLAN内IPアドレスまたはホスト名を指定してください。

- `AGENT_API_BASE_URL`: 献立提案・画像解析共通のAPI接続先
- `AGENT_API_ACCESS_TOKEN`: 認証が必要な場合の一時的なアクセストークン。認証なしの試験環境では空欄
- `AGENT_VISION_MODEL`: 画像解析モデル。空欄ならエージェント側の既定モデル

通常どおり起動します。アプリ起動時に`.env`を自動読み込みするため、設定用のオプションは不要です。

```bash
flutter run
```

複数端末がある場合のみ`-d <device-id>`で対象を指定します。ビルド時も設定オプションは不要です。

```bash
flutter build ios
```

`.env`はFlutterのアセットとしてアプリに同梱され、`flutter_dotenv`で起動時に読み込みます。IP変更などでMac側の`.env`を編集した後は、実行中のFlutterを停止して`flutter run`を再実行してください。ホットリロードやインストール済みアプリの開き直しだけでは、Mac側の変更は反映されません。

従来の`--dart-define`や`--dart-define-from-file`も任意の上書き指定として利用できますが、通常は不要です。明示的に指定した値は同梱した`.env`より優先されるため、古い起動設定が残っている場合は外してください。どちらにも`AGENT_API_BASE_URL`がない場合は、同じMacでの開発用に`http://localhost:8000`を使用します。

`.env`と`.env.*`はGit管理対象外、`.env.example`のみ共有対象です。ただし`.env`自体がアプリに同梱されるため、秘密を安全に保管する仕組みではありません。サーバーの秘密鍵・パスワードや無関係な設定を入れず、配布版へ固定トークンを埋め込まないでください。

## テストと静的解析

新しく取得した環境やCIでも、実行前に`.env.example`から`.env`を作成してください。テスト・ビルド時に必要なアセットとして登録しているため、`.env`がない場合はエラーになります。

```bash
flutter analyze
flutter test
```

単一テストを実行する例：

```bash
flutter test test/features/suggestion/suggestion_provider_test.dart
flutter test --name "accumulates tokens"
```

### DBテスト

DB関連のテストはモックではなく、一時ディレクトリに実際のIsar DBを作成して検証します。実行後はDBを閉じ、一時データを削除します。実機の献立データは変更しません。

共通の初期化処理`test/support/isar_test_support.dart`が、`flutter pub get`で取得した`isar_flutter_libs`内のホスト用バイナリを読み込みます。Mac用ライブラリをプロジェクト直下へ手動コピーしたり、テスト中に追加ダウンロードしたりする必要はありません。

```bash
flutter test test/core/db/isar_service_test.dart test/features/meal_record/meal_record_repository_test.dart
```

読み込み対象はmacOS（Apple Silicon / Intel）、Linux x64、Windows x64です。未対応の環境、ライブラリ不足、DB初期化失敗、検証結果の不一致は、スキップせずテスト失敗として扱います。ライブラリが見つからない場合は、まず`flutter pub get`が正常に完了しているか確認してください。

## プロジェクト構成

```text
lib/
├── core/
│   ├── db/          # Isar初期化
│   ├── agent/       # 外部エージェント接続、献立提案、画像解析
│   ├── llm/         # 旧端末内LLM実装（現在のAI動作経路では未使用）
│   └── router/      # 画面遷移
└── features/
    ├── home/        # ホーム
    ├── meal_record/ # 献立記録
    ├── history/     # 履歴
    ├── suggestion/  # AI提案とカテゴリイラスト
    └── model_setup/ # 旧GGUFモデル準備画面（現在は使用しない）
```

状態管理にはRiverpod、ローカルデータベースにはIsar、外部エージェントとのHTTP通信にはDioを使用しています。
