# Claude Codeへの引き継ぎメモ

## プロジェクト名
- ストア表示名: **つぎのごはん**
- 開発用内部名称: **MealLog AI**(リポジトリ名/パッケージ名/Bundle ID等に使用。例: `meallog-ai`, `com.yourname.meallogai`)

## プロジェクト概要
毎日の献立を記録すると、AIが次の献立を提案してくれるスマホアプリ(個人開発)。

- クロスプラットフォーム: **Flutter**
- 詳細仕様: `meal_app_spec.md` を参照(コア機能・画面構成・データモデル・MVPスコープなど記載)

## 今回の依頼: A-2の実装(オンデバイスOpen LLM)

「5. AI提案の実装方針」のうち、**A-2: Open LLM(llama.cpp / GGUF、iOS・Android共通)** をまず動かしてみたい。

### 決定事項
- パッケージ: `llamadart`(GGUF+LiteRT-LM対応、Android/iOS/macOS/Linux/Windows/web対応、SwiftPM経由でXCFrameworks自動取得)
- 候補モデル: Gemma 3 1B(Q4_K_M) と Qwen2.5 1.5B(Q4_K_M)を日本語の応答品質・速度で比較検討中
- 用途: 直近の献立履歴からマンネリ回避の献立提案+理由の文章化(知識が必要な栄養バランス推定は対象外、将来クラウドAPI側で対応予定)

### 参考コード
`meal_suggestion_llm_service.dart` に最小構成のPoCサービスクラスを用意済み。
`MealSuggestionLlmService.loadModel()` でモデルロード、`suggestNextMeal()` でストリーミング応答を返す設計。

## Claude Codeでやってほしいこと

1. Flutterプロジェクトへの`llamadart`導入(pubspec.yaml設定、iOSデプロイターゲット16.4以上への対応確認)
2. Gemma 3 1B / Qwen2.5 1.5BのGGUF量子化モデルをHugging Faceから取得し、実機(またはシミュレータ/エミュレータ)で動作確認
3. `meal_suggestion_llm_service.dart`をベースに、実際の献立記録データ(まだ未実装ならモックでよい)と接続
4. 日本語応答の品質・生成速度を2モデルで比較し、どちらを採用するか判断
5. モデルファイルの配布方法(アプリ同梱 or 初回起動時ダウンロード)の実装方針を決めて実装

## 未確定・相談したい点(仕様書より)
- クラウド同期の必要性(複数端末・家族共有を想定するか)
- 栄養素の精度をどこまで求めるか
- マネタイズ方針

## これまでの検討の流れ(参考)
1. まずクラウドAPI(Gemini等)前提で仕様検討 → 商用利用時は無料枠が使えない点が判明
2. Apple Foundation Models framework(iOS限定のオンデバイスAI)を検討
3. Open LLM(llama.cpp/GGUF)であればiOS/Android両方でオンデバイス動作できることが判明 → 今回はこちらを併記・優先して試すことに
