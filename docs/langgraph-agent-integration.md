# MealLog AI × LangGraphエージェント接続手順

## 構成

MealLog AIは端末内LLMを使用せず、LAN上のLangGraph APIへ直近7日間の献立を送信します。

```text
MealLog AI
  → .env の AGENT_API_BASE_URL（例: http://<agent-host>:8000）
    → FastAPI / LangGraph
      → Ollama
```

献立提案ごとに新規会話を作成し、SSEの`assistant.delta`をアプリ上で逐次表示します。`message.completed`を受信した時点で成功です。献立記録の写真は`/v1/vision/analyze`へ送信し、料理名、候補、推定食材を構造化JSONで受け取ります。

## エージェント側のMacの起動

エージェント側MacのLAN内IPが変わった場合は、以下の確認URLとMealLog AI側の`.env`を更新します。

APIを`127.0.0.1`で起動すると別端末から接続できません。LANの全インターフェースで待ち受けます。

```bash
uv run uvicorn src.api.app:app --host 0.0.0.0 --port 8000
```

別の端末から次を開き、APIが見えることを確認します。

```text
http://<agent-host>:8000/health
http://<agent-host>:8000/ready
```

macOSのファイアウォールが接続を拒否する場合は、Pythonまたは起動しているターミナルからの受信接続を許可します。

## MealLog AIの起動

プロジェクト直下の`.env`をアプリに同梱し、`flutter_dotenv`で起動時に自動読み込みします。通常の`flutter run`で利用でき、設定用の起動オプションは不要です。

初回のみ、設定例をコピーします。既に`.env`がある場合は上書きせず、そのファイルを編集します。

```bash
cp .env.example .env
```

手元の`.env`は以下の設定で用意済みです。

```dotenv
AGENT_API_BASE_URL=http://<agent-host>:8000
AGENT_API_ACCESS_TOKEN=
AGENT_VISION_MODEL=
```

通常どおり起動すると、`.env`の接続先が自動で使われます。

```bash
flutter run
```

接続したiPhoneを指定する場合は、`flutter devices`で端末IDを確認します。

```bash
flutter devices
flutter run -d <device-id>
```

ビルド時も`flutter build ios`だけで`.env`が同梱されます。新規取得した環境やCIでは、ビルド・テスト前に`.env.example`から`.env`を作成してください。`.env`がない場合はエラーになります。

画像解析モデルを明示する場合は、`.env`の`AGENT_VISION_MODEL`にエージェント側で利用可能なモデル名（例: `qwen3.5:9b-mlx`）を設定します。空欄ならエージェント側の既定モデルを使用します。

IPやトークンなどを変更した後は、実行中のFlutterを停止して`flutter run`を再実行してください。Mac上の`.env`をアプリへ再同梱する必要があるため、ホットリロードやインストール済みアプリの開き直しだけではMac側の変更は反映されません。

従来の`--dart-define=KEY=value`や`--dart-define-from-file`も任意の上書き指定として利用できますが、通常は不要です。明示した値が同梱した`.env`より優先されるため、古いIPを指定した起動オプションが残っている場合は外してください。

`AGENT_API_BASE_URL`未指定時の既定値は`http://localhost:8000`です。実機で使う際は`localhost`ではなく、エージェントのMacのLAN内IPまたはホスト名を設定します。

`.env`と`.env.*`はGit管理対象外です。`.env.example`のみ共有し、実際の接続先・トークンは手元で管理します。

## 画像解析

MealLog AIは写真をmultipart/form-dataで次のAPIへ送信します。

```http
POST /v1/vision/analyze
```

送信項目：

- `image`: カメラまたはアルバムから選択した画像
- `prompt`: 料理名、料理候補、推定食材の抽出指示
- `response_schema`: MealLog AI用のJSON Schema
- `model`: `AGENT_VISION_MODEL`指定時のみ

プロンプトとJSON SchemaはFlutter側で管理し、バックエンドは汎用画像解析APIのまま利用します。画像解析中は画像がLAN上のエージェントへ送信されます。

## 認証

### 認証なしでLAN内試験する場合

LangGraph API側の`AUTH_MODE=disabled`を使用します。この方式は信頼できるLAN内の試験に限定し、インターネットへ公開しないでください。

### 一時的なアクセストークンを使う場合

`.env`の空欄を一時的なアクセストークンで置き換え、Flutterを再実行します。

```dotenv
AGENT_API_ACCESS_TOKEN=アクセストークン
```

`.env`自体がアプリに同梱されます。Git管理対象外にしても秘密を安全に保管できるわけではありません。サーバーの秘密鍵・パスワードや無関係な設定を入れないでください。固定トークンは動作確認用であり、配布版ではKeycloakのAuthorization Code + PKCEをFlutterに実装し、更新可能なアクセストークンを使用します。

## 現在の試作仕様

- GGUFモデルの初回ダウンロード画面は表示しません。
- OS純正LLMとGGUFは献立生成に使用しません。
- 献立ごとに新規会話を作成します。
- 献立履歴は従来通りIsarに保存します。
- エージェントへ送信するのは直近7日間の料理名と対象の食事種別です。
- 写真認識は端末内ML Kitではなく、エージェントの汎用画像解析APIを使用します。
- 画像解析APIの実疎通は`qwen3.5:9b-mlx`で確認済みです。

## 現時点の制限

- OIDCのログイン画面とPKCEは未実装です。
- HTTPのLAN内通信を許可しています。配布版ではHTTPS化が必要です。
- エージェント側に作成された会話の自動削除は行いません。
