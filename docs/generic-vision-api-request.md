# 汎用画像解析API 開発依頼書

## 目的

既存のLangGraph + FastAPIプロジェクトへ、汎用的な画像解析機能を追加する。

料理専用の実装にはせず、クライアントから画像、指示、任意のレスポンス形式を渡せる共通機能とする。既存の会話API、認証、永続化機能との後方互換性を維持する。

## API

以下のエンドポイントを追加する。

```http
POST /v1/vision/analyze
Content-Type: multipart/form-data
Authorization: Bearer <access_token>
```

入力項目：

- `image`
  - 必須
  - JPEG、PNG、WebPのいずれか1枚
- `prompt`
  - 必須
  - 画像に対して実行する指示
- `response_schema`
  - 任意
  - 結果に求めるJSON Schema
  - 指定がない場合は通常のテキスト応答
- `model`
  - 任意
  - 許可された画像対応モデルから選択
  - 未指定の場合はサーバー設定の既定モデルを使用

料理、書類、商品、植物、設備、スクリーンショットなど、特定用途に依存しない設計とする。

## 成功レスポンス

JSON Schema未指定時：

```json
{
  "content": "画像についての解析結果",
  "model": "使用したモデル名"
}
```

JSON Schema指定時：

```json
{
  "content": {
    "クライアントが指定したスキーマに準拠した結果": true
  },
  "model": "使用したモデル名"
}
```

## MealLog AIからの利用例

MealLog AIからは、例えば次の指示を送信する。

```text
この画像に写っている料理を日本語で推定してください。
最も可能性が高い料理名、ほかの料理候補、画像から確認できる推定食材を返してください。
確認できない食材を断定しないでください。
```

MealLog AIが指定するJSON Schemaの例：

```json
{
  "type": "object",
  "properties": {
    "dishName": {
      "type": "string"
    },
    "candidates": {
      "type": "array",
      "items": {
        "type": "string"
      }
    },
    "ingredients": {
      "type": "array",
      "items": {
        "type": "string"
      }
    }
  },
  "required": [
    "dishName",
    "candidates",
    "ingredients"
  ],
  "additionalProperties": false
}
```

料理用プロンプトとスキーマはクライアント側の責務とし、バックエンドへハードコードしない。

## モデル連携

- Ollamaの画像対応モデルを使用する
- 画像対応モデル名は環境変数で設定できるようにする
- モデルの存在と画像対応可否を起動時または実行前に検証する
- モデル未導入、Ollama停止、タイムアウトを安全なAPIエラーへ変換する
- JSON Schema指定時は、可能であればモデルのStructured Outputs機能を使用する
- モデル出力がスキーマに適合しない場合は成功扱いにせず、明示的なエラーを返す
- 無制限の自動再試行は行わない

環境変数の例：

```ini
VISION_MODEL=画像対応モデル名
VISION_TIMEOUT_SECONDS=120
VISION_MAX_IMAGE_BYTES=10485760
VISION_ALLOWED_MIME_TYPES=image/jpeg,image/png,image/webp
VISION_MAX_PROMPT_CHARS=5000
VISION_MAX_SCHEMA_BYTES=16384
```

## 実装構成

既存のLangGraph ReAct会話処理へ直接埋め込まず、独立した画像解析サービスとして実装する。

構成例：

```text
src/
├── api/
│   ├── app.py
│   ├── vision.py
│   └── schemas.py
└── services/
    └── vision_service.py
```

画像解析は原則として会話履歴、チェックポインタ、メモ、Web検索などのツールを使用しない。

将来的に会話へ画像添付を追加できるよう、画像解析サービス自体はAPI層から分離する。

## 認証と保護

- `/v1/vision/analyze`へ既存のBearer認証を適用する
- 既存のOIDC/JWT所有者境界を維持する
- 既存のIP単位・ユーザー単位レート制限を適用する
- 画像解析用に必要なら、通常メッセージより厳しい個別レート制限を設定できるようにする
- 既存の`X-Request-ID`を適用する
- エラー応答は既存APIの安全なエラー形式へ統一する
- 認証無効モードは従来どおりローカル検証用途に限定する

## 画像の安全な取り扱い

- Content-Typeだけを信用せず、画像データを実際にデコードして検証する
- 許可形式、ファイルサイズ、ピクセル数、縦横サイズを制限する
- 破損画像、空ファイル、画像以外のファイルを拒否する
- 一時ファイルを利用する場合は安全な一時領域へ保存し、成功・失敗を問わず必ず削除する
- 可能なら画像をメモリ上だけで処理する
- 画像、Base64データ、プロンプト、モデルの生出力をログへ記録しない
- EXIFなど不要なメタデータをモデルへ渡さない
- URLを指定してサーバー側から画像を取得する機能は、SSRF対策が必要になるため今回は実装しない

## JSON Schemaの制限

クライアントから任意のJSON Schemaを受け取る場合は、以下を制限する。

- スキーマ全体のバイト数
- ネストの深さ
- プロパティ数
- 配列要素数
- 文字列最大長
- 外部参照
- 再帰参照
- 未対応キーワード

外部参照やネットワーク参照は許可しない。複雑すぎるスキーマは`400`で拒否する。

## エラー定義

以下を区別できる安全なエラーコードを用意する。

- `invalid_image`
- `unsupported_image_type`
- `image_too_large`
- `invalid_prompt`
- `invalid_response_schema`
- `vision_model_unavailable`
- `vision_timeout`
- `schema_validation_failed`
- `rate_limit_exceeded`

内部例外、ファイルパス、モデルの生レスポンス、トークンなどをクライアントへ返さない。

## テスト

最低限、以下を自動テストする。

- JPEG、PNG、WebPの正常系
- JSON Schemaなしのテキスト応答
- JSON Schemaありの構造化応答
- 認証なし、無効トークン、他ユーザー境界
- 空ファイル
- 画像ではないファイル
- MIMEタイプ偽装
- ファイルサイズ超過
- 画像解像度・ピクセル数超過
- プロンプト長超過
- 不正または複雑すぎるJSON Schema
- Ollama停止
- モデル未導入
- タイムアウト
- スキーマ不一致
- レート制限
- ログに画像、プロンプト、認証情報が出ないこと
- 一時ファイルが成功時・失敗時ともに削除されること
- 既存の会話APIテストがすべて継続して合格すること

モデルそのものを呼ぶテストと、モデルをモックした決定的なAPIテストを分ける。

## ドキュメント

以下を更新する。

- OpenAPI
- API利用ガイド
- 環境変数一覧
- 画像対応モデルの導入方法
- curlによるテキスト応答例
- curlによるJSON Schema指定例
- 認証無効モードでのローカル確認方法
- 保存・ログ・削除に関するプライバシー方針

## 完了条件

- 汎用的な画像解析APIとして利用できる
- 料理固有のプロンプトやレスポンス項目がバックエンドへハードコードされていない
- MealLog AIから料理画像解析に利用できる
- 既存の認証、レート制限、ログ、リクエストIDと統合されている
- 画像と機密情報が永続保存・ログ出力されない
- 既存機能を含む全テストと静的解析が合格する
- 実機または実際のOllama画像対応モデルを使った疎通手順が文書化されている
