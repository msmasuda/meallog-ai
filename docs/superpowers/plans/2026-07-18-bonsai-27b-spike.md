# Bonsai 27B 実機検証(実験用ブランチ) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** On a throwaway experimental branch, swap the app's on-device LLM config to Bonsai 27B (1-bit GGUF) and verify the full download→load→suggest flow on an iPhone 17.

**Architecture:** Change two config constants (model URL/filename) and one `ModelParams` field (`gpuLayers`) so the existing download/load pipeline points at Bonsai 27B. Add a new `LlmService.suggestNextMealViaChat` method that uses llamadart's structured `engine.create()` chat API (which auto-applies the GGUF's embedded chat template) instead of the hand-written ChatML string, since Bonsai's exact template isn't publicly documented. Wire `mealSuggestionProvider` to call the new method. No new abstractions, no UI, no automated device tests — verification is a manual on-device walkthrough.

**Tech Stack:** Flutter, Riverpod (`riverpod_generator` — note: no codegen rerun needed here since no `@riverpod` function *signatures* change), llamadart 0.8.12, mocktail.

## Global Constraints

- This work happens on a new branch `experiment/bonsai-27b`, created from `develop`. It is NOT intended to be merged — do not open a PR against `develop` as part of this plan.
- Do not add a model-selector UI, feature flag, build flavor, or environment-variable gate. This is a throwaway spike (per spec `docs/superpowers/specs/2026-07-18-bonsai-27b-spike-design.md`).
- Model URL: `https://huggingface.co/prism-ml/Bonsai-27B-gguf/resolve/main/Bonsai-27B-Q1_0.gguf`
- Model filename: `bonsai-27b-q1_0.gguf`
- `ModelParams`: `gpuLayers: 99` (GPU offload), `contextSize: 512` and `batchSize: 128` unchanged.
- `suggestNextMealViaChat` must yield the same contract as the existing `suggestNextMeal`: a stream of raw per-token deltas (NOT pre-accumulated cumulative strings) — accumulation into a growing string already happens once, in `mealSuggestionProvider`, via `buffer.write(token)`. Do not accumulate twice.
- Do not touch `lib/features/model_setup/`, `lib/core/router/app_router.dart`, or the `model_ready` SharedPreferences flag — none of this plan changes that flow's shape, only the constants it reads.
- Multimodal projector files and speculative-decoding draft models (`Bonsai-27B-mmproj-*`, `Bonsai-27B-dspark-*`) are out of scope.

---

### Task 1: Create the experimental branch and point model config at Bonsai 27B

**Files:**
- Modify: `lib/core/llm/model_download_service.dart` (lines 4-7)
- Modify: `lib/core/llm/llm_service.dart` (lines 15-19, the `ModelParams` block only — the chat method comes in Task 2)

**Interfaces:**
- Produces: `ModelDownloadService.kDefaultModelUrl` and `ModelDownloadService.modelFilePath(docsDir)` now resolve to the Bonsai 27B GGUF file. `LlmService.loadModel` now requests GPU offload.

- [ ] **Step 1: Create the branch**

```bash
git checkout develop
git pull
git checkout -b experiment/bonsai-27b
```

- [ ] **Step 2: Point the download config at Bonsai 27B**

Edit `lib/core/llm/model_download_service.dart` so the top of the file reads:

```dart
import 'package:dio/dio.dart';

class ModelDownloadService {
  static const kDefaultModelUrl =
      'https://huggingface.co/prism-ml/Bonsai-27B-gguf/resolve/main/Bonsai-27B-Q1_0.gguf';

  static const _modelFileName = 'bonsai-27b-q1_0.gguf';

  static String modelFilePath(String docsDir) => '$docsDir/$_modelFileName';
```

(The rest of the file — the `download` method — is unchanged.)

- [ ] **Step 3: Run the existing model-download test**

Run: `flutter test test/core/llm/model_download_service_test.dart`
Expected: PASS (the test only checks `startsWith('https://')` / `endsWith('.gguf')`, so it's agnostic to the exact model — this just confirms nothing broke).

- [ ] **Step 4: Enable GPU offload for the 27B model**

Edit `lib/core/llm/llm_service.dart`, replacing the `modelParams` block inside `loadModel`:

```dart
  Future<void> loadModel(String modelPath) async {
    final engine = LlamaEngine(LlamaBackend());
    await engine.loadModel(
      modelPath,
      // Bonsai 27B (Q1_0, ~3.8GB weights) is impractically slow on CPU-only
      // inference — offload as many layers as possible to Metal.
      modelParams: const ModelParams(
        contextSize: 512,
        batchSize: 128,
        gpuLayers: 99,
      ),
    );
    _engine = engine;
  }
```

- [ ] **Step 5: Verify analyzer is clean and commit**

Run: `flutter analyze`
Expected: `No issues found!`

```bash
git add lib/core/llm/model_download_service.dart lib/core/llm/llm_service.dart
git commit -m "experiment: point model config at Bonsai 27B (Q1_0, GPU offload)"
```

---

### Task 2: Add `suggestNextMealViaChat` using llamadart's structured chat API

**Files:**
- Modify: `lib/core/llm/llm_service.dart` (add two new members after `buildPrompt`)
- Test: `test/core/llm/llm_service_test.dart` (add tests for the new static helper)

**Interfaces:**
- Consumes: `LlamaEngine.create(List<LlamaChatMessage> messages, {bool enableThinking})` → `Stream<LlamaCompletionChunk>` (llamadart 0.8.12, `package:llamadart/llamadart.dart`). `LlamaCompletionChunk.choices` is `List<LlamaCompletionChunkChoice>`; `LlamaCompletionChunkChoice.delta` is `LlamaCompletionChunkDelta`; `LlamaCompletionChunkDelta.content` is `String?`.
- Produces: `LlmService.suggestNextMealViaChat({required List<String> recentMeals, String mealType = '夕食'})` → `Stream<String>` (raw per-token deltas, same contract as `suggestNextMeal`). `LlmService.chatDeltaContent(Stream<LlamaCompletionChunk> chunks)` → `Stream<String>` (static, pure — extracts non-null/non-empty `delta.content` from each chunk).

- [ ] **Step 1: Write the failing tests**

Replace the full contents of `test/core/llm/llm_service_test.dart` with:

```dart
// test/core/llm/llm_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:llamadart/llamadart.dart';
import 'package:meallog_ai/core/llm/llm_service.dart';

void main() {
  test('buildPrompt contains all recent meals and meal type', () {
    final prompt = LlmService.buildPrompt(
      recentMeals: ['鶏の照り焼き', '豚汁', 'サバの味噌煮'],
      mealType: '夕食',
    );
    expect(prompt, contains('鶏の照り焼き'));
    expect(prompt, contains('豚汁'));
    expect(prompt, contains('サバの味噌煮'));
    expect(prompt, contains('夕食'));
    expect(prompt, contains('料理名だけを1行'));
  });

  test('buildPrompt uses 夕食 as default mealType', () {
    final prompt = LlmService.buildPrompt(recentMeals: ['そば']);
    expect(prompt, contains('夕食'));
  });

  test('chatDeltaContent yields each non-empty delta content in order', () async {
    final chunks = Stream<LlamaCompletionChunk>.fromIterable([
      _chunkWithContent('麻'),
      _chunkWithContent('婆'),
      _chunkWithContent('豆'),
      _chunkWithContent('腐'),
    ]);

    final results = await LlmService.chatDeltaContent(chunks).toList();

    expect(results, ['麻', '婆', '豆', '腐']);
  });

  test('chatDeltaContent skips chunks with null or empty delta content', () async {
    final chunks = Stream<LlamaCompletionChunk>.fromIterable([
      _chunkWithContent('麻'),
      _chunkWithContent(null),
      _chunkWithContent(''),
      _chunkWithContent('婆'),
    ]);

    final results = await LlmService.chatDeltaContent(chunks).toList();

    expect(results, ['麻', '婆']);
  });

  test('chatDeltaContent skips chunks with no choices', () async {
    final chunks = Stream<LlamaCompletionChunk>.fromIterable([
      LlamaCompletionChunk(
        id: 'test',
        object: 'chat.completion.chunk',
        created: 0,
        model: 'bonsai-27b-q1_0',
        choices: const [],
      ),
      _chunkWithContent('婆'),
    ]);

    final results = await LlmService.chatDeltaContent(chunks).toList();

    expect(results, ['婆']);
  });
}

LlamaCompletionChunk _chunkWithContent(String? content) {
  return LlamaCompletionChunk(
    id: 'test',
    object: 'chat.completion.chunk',
    created: 0,
    model: 'bonsai-27b-q1_0',
    choices: [
      LlamaCompletionChunkChoice(
        index: 0,
        delta: LlamaCompletionChunkDelta(content: content),
      ),
    ],
  );
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `flutter test test/core/llm/llm_service_test.dart`
Expected: FAIL — compile error, `The method 'chatDeltaContent' isn't defined for the type 'LlmService'` (the two `buildPrompt` tests would otherwise pass, but the file won't compile at all yet, so all four report as errors).

- [ ] **Step 3: Implement `chatDeltaContent` and `suggestNextMealViaChat`**

Edit `lib/core/llm/llm_service.dart`, adding these two members immediately after the closing brace of `buildPrompt` (before `dispose`):

```dart
  Stream<String> suggestNextMealViaChat({
    required List<String> recentMeals,
    String mealType = '夕食',
  }) {
    if (_engine == null) throw StateError('モデルが未ロードです');
    final historyText = recentMeals.isEmpty ? '（記録なし）' : recentMeals.join('、');
    final messages = [
      const LlamaChatMessage.fromText(
        role: LlamaChatRole.system,
        text: 'あなたは献立提案アシスタントです。料理名だけを1行で答えてください。',
      ),
      LlamaChatMessage.fromText(
        role: LlamaChatRole.user,
        text: '直近の献立: $historyText\n次の$mealTypeを1つ提案してください。',
      ),
    ];
    // Uses the model's own embedded chat template (via llamadart's
    // structured chat API) instead of a hand-written ChatML string, since
    // Bonsai 27B's exact template isn't publicly documented.
    return chatDeltaContent(_engine!.create(messages, enableThinking: false));
  }

  /// Extracts raw per-token deltas from a chat completion stream. Same
  /// "one delta per emit" contract as [suggestNextMeal] — callers (e.g.
  /// mealSuggestionProvider) are responsible for accumulating into a
  /// cumulative string. Do not accumulate here too, or the UI double-counts.
  static Stream<String> chatDeltaContent(
    Stream<LlamaCompletionChunk> chunks,
  ) async* {
    await for (final chunk in chunks) {
      if (chunk.choices.isEmpty) continue;
      final content = chunk.choices.first.delta.content;
      if (content == null || content.isEmpty) continue;
      yield content;
    }
  }
```

The full file should now read:

```dart
// lib/core/llm/llm_service.dart
import 'package:llamadart/llamadart.dart';

class LlmService {
  LlamaEngine? _engine;
  bool get isReady => _engine != null;

  Future<void> loadModel(String modelPath) async {
    final engine = LlamaEngine(LlamaBackend());
    await engine.loadModel(
      modelPath,
      // Bonsai 27B (Q1_0, ~3.8GB weights) is impractically slow on CPU-only
      // inference — offload as many layers as possible to Metal.
      modelParams: const ModelParams(
        contextSize: 512,
        batchSize: 128,
        gpuLayers: 99,
      ),
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
    final historyText = recentMeals.isEmpty ? '（記録なし）' : recentMeals.join('、');
    // ChatML format required by Qwen2.5-Instruct
    return '<|im_start|>system\nあなたは献立提案アシスタントです。料理名だけを1行で答えてください。<|im_end|>\n<|im_start|>user\n直近の献立: $historyText\n次の$mealTypeを1つ提案してください。<|im_end|>\n<|im_start|>assistant\n';
  }

  Stream<String> suggestNextMealViaChat({
    required List<String> recentMeals,
    String mealType = '夕食',
  }) {
    if (_engine == null) throw StateError('モデルが未ロードです');
    final historyText = recentMeals.isEmpty ? '（記録なし）' : recentMeals.join('、');
    final messages = [
      const LlamaChatMessage.fromText(
        role: LlamaChatRole.system,
        text: 'あなたは献立提案アシスタントです。料理名だけを1行で答えてください。',
      ),
      LlamaChatMessage.fromText(
        role: LlamaChatRole.user,
        text: '直近の献立: $historyText\n次の$mealTypeを1つ提案してください。',
      ),
    ];
    // Uses the model's own embedded chat template (via llamadart's
    // structured chat API) instead of a hand-written ChatML string, since
    // Bonsai 27B's exact template isn't publicly documented.
    return chatDeltaContent(_engine!.create(messages, enableThinking: false));
  }

  /// Extracts raw per-token deltas from a chat completion stream. Same
  /// "one delta per emit" contract as [suggestNextMeal] — callers (e.g.
  /// mealSuggestionProvider) are responsible for accumulating into a
  /// cumulative string. Do not accumulate here too, or the UI double-counts.
  static Stream<String> chatDeltaContent(
    Stream<LlamaCompletionChunk> chunks,
  ) async* {
    await for (final chunk in chunks) {
      if (chunk.choices.isEmpty) continue;
      final content = chunk.choices.first.delta.content;
      if (content == null || content.isEmpty) continue;
      yield content;
    }
  }

  Future<void> dispose() async {
    await _engine?.dispose();
    _engine = null;
  }
}
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `flutter test test/core/llm/llm_service_test.dart`
Expected: `00:0X +5: All tests passed!`

- [ ] **Step 5: Run the analyzer and commit**

Run: `flutter analyze`
Expected: `No issues found!`

```bash
git add lib/core/llm/llm_service.dart test/core/llm/llm_service_test.dart
git commit -m "experiment: add suggestNextMealViaChat using llamadart's structured chat API"
```

---

### Task 3: Wire `mealSuggestionProvider` to the new method

**Files:**
- Modify: `lib/features/suggestion/providers/suggestion_provider.dart` (one line)
- Modify: `test/features/suggestion/suggestion_provider_test.dart` (mock stub target)

**Interfaces:**
- Consumes: `LlmService.suggestNextMealViaChat` from Task 2.
- Produces: no change to `mealSuggestionProvider`'s public shape (`AutoDisposeStreamProvider<String>` — the `@riverpod` function signature is untouched, so **no `build_runner` rerun is needed**, only the function body changes).

- [ ] **Step 1: Update the test to stub the new method**

Edit `test/features/suggestion/suggestion_provider_test.dart`, changing the `when()` stub target from `suggestNextMeal` to `suggestNextMealViaChat`:

```dart
// test/features/suggestion/suggestion_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meallog_ai/core/llm/llm_provider.dart';
import 'package:meallog_ai/core/llm/llm_service.dart';
import 'package:meallog_ai/features/meal_record/providers/meal_record_provider.dart';
import 'package:meallog_ai/features/suggestion/providers/suggestion_provider.dart';

class MockLlmService extends Mock implements LlmService {}

void main() {
  test('mealSuggestionProvider accumulates tokens into growing string', () async {
    final mockLlm = MockLlmService();
    when(() => mockLlm.suggestNextMealViaChat(
          recentMeals: any(named: 'recentMeals'),
          mealType: any(named: 'mealType'),
        )).thenAnswer((_) => Stream.fromIterable(['麻', '婆', '豆', '腐']));

    final container = ProviderContainer(overrides: [
      llmServiceNotifierProvider.overrideWith(() => _FakeLlm(mockLlm)),
      recentMealsProvider.overrideWith((ref) async => ['鶏の照り焼き']),
    ]);
    addTearDown(container.dispose);

    // Collect all emitted values via listen (provider.future returns first emit, not last)
    final emitted = <String>[];
    container.listen<AsyncValue<String>>(
      mealSuggestionProvider,
      (_, next) => next.whenData(emitted.add),
      fireImmediately: true,
    );

    // Allow all synchronous microtasks from Stream.fromIterable to complete
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(emitted, isNotEmpty);
    expect(emitted.last, equals('麻婆豆腐'));
  });
}

class _FakeLlm extends LlmServiceNotifier {
  _FakeLlm(this._svc);
  final LlmService _svc;
  @override
  Future<LlmService> build() async => _svc;
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/suggestion/suggestion_provider_test.dart`
Expected: FAIL — `emitted` is empty (the provider still calls the now-unstubbed `suggestNextMeal`, which mocktail throws `MissingStubError` for, causing the stream to error instead of emit).

- [ ] **Step 3: Update the provider to call the new method**

Edit `lib/features/suggestion/providers/suggestion_provider.dart`:

```dart
// lib/features/suggestion/providers/suggestion_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/llm/llm_provider.dart';
import '../../meal_record/providers/meal_record_provider.dart';

part 'suggestion_provider.g.dart';

@riverpod
Stream<String> mealSuggestion(MealSuggestionRef ref) async* {
  final llmService = await ref.watch(llmServiceNotifierProvider.future);
  final recentMeals = await ref.watch(recentMealsProvider.future);
  final buffer = StringBuffer();
  await for (final token
      in llmService.suggestNextMealViaChat(recentMeals: recentMeals)) {
    buffer.write(token);
    yield buffer.toString();
  }
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/features/suggestion/suggestion_provider_test.dart`
Expected: `00:0X +1: All tests passed!`

- [ ] **Step 5: Run the full test suite, analyzer, and commit**

Run: `flutter test && flutter analyze`
Expected: all tests pass, `No issues found!`

```bash
git add lib/features/suggestion/providers/suggestion_provider.dart test/features/suggestion/suggestion_provider_test.dart
git commit -m "experiment: wire mealSuggestionProvider to suggestNextMealViaChat"
```

---

### Task 4: Manual on-device verification on iPhone 17

**Files:** none (no code changes — this task is a documented manual walkthrough, since hardware-dependent behavior can't be exercised by an automated test in this repo).

**Interfaces:**
- Consumes: the fully wired experimental branch from Tasks 1-3.
- Produces: a pass/fail record of whether Bonsai 27B loads and generates on iPhone 17, appended to the memory note `se2-context-creation-failure.md`-style project memory (or a new one) for future reference. This step is performed by the user, not the agent — physical device access is required (per the existing project memory: "実機検証はユーザーが担当（Claudeからは物理SE2を動かせない）", the same constraint applies to iPhone 17 here).

- [ ] **Step 1: Build and install on iPhone 17**

```bash
flutter run --release -d 00008150-001D6598217A401C
```

(UDID from prior project memory — confirm it's still the correct device before running; use `flutter devices` to list if unsure.)

Expected: app launches to the `/model-setup` screen (since `model_ready` is presumably still `true` from the previous 1.5B model on this device, you may need to clear the app/reinstall to force a fresh download, or manually delete the old model file and reset the `model_ready` SharedPreferences key so the download screen re-triggers for the new 3.8GB file).

- [ ] **Step 2: Observe the download**

Watch the progress bar on `/model-setup` complete for the ~3.8GB `Bonsai-27B-Q1_0.gguf` download. Note the time taken (informational, not a pass/fail gate).

Expected: download reaches 100% and the app navigates to `/` (home screen) automatically (per `ModelSetupScreen`'s `ref.listen` on `progress == 1.0`).

- [ ] **Step 3: Observe model load**

Check the `flutter run` console output for the transition into the home screen.

Expected: no `LlamaException: Failed to load model ... (Exception: Failed to create context)` in the console (this was the SE2 failure signature from prior investigation — on iPhone 17 with the 1.5B model this did NOT occur, so its absence here is the key signal that Bonsai 27B fits in memory).

- [ ] **Step 4: Trigger a suggestion and observe output**

From the home screen, trigger the meal-suggestion flow (whatever UI action calls `mealSuggestionProvider` — check `lib/features/home/` if unsure of the exact button/gesture).

Expected: streamed text appears in the UI, building up token-by-token, and settles on a Japanese dish name (mirroring the existing `料理名だけを1行で答えてください` system instruction).

- [ ] **Step 5: Record the result**

Note pass/fail and any observations (load time, generation speed, whether output looked like a real dish name vs. garbled/repeated text, any crashes or OOM) — report back in the conversation so it can be saved to project memory if noteworthy, following the pattern of the existing `se2-context-creation-failure` memory. Do not commit this as a code change; it's just an observation to relay.

- [ ] **Step 6: Decide next step, do not merge**

This branch (`experiment/bonsai-27b`) stays unmerged into `develop` regardless of outcome. If the spike succeeds and a permanent feature (e.g. model selector) is wanted, that requires a fresh brainstorming/spec cycle — this plan's scope ends here.
