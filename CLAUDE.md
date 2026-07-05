# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

**MealLog AI** (store name: つぎのごはん) — a Flutter app that records daily meals and uses an **on-device LLM** (llamadart / GGUF) to suggest the next meal. Goal: avoid meal repetition with zero API cost and full offline operation. UI text is in Japanese.

## Commands

```bash
flutter pub get                                    # install deps
dart run build_runner build --delete-conflicting-outputs   # regenerate *.g.dart (REQUIRED after touching providers/models)
dart run build_runner watch --delete-conflicting-outputs   # continuous codegen during dev
flutter analyze                                    # lint (flutter_lints, *.g.dart excluded)
flutter test                                       # all tests
flutter test test/features/suggestion/suggestion_provider_test.dart   # single file
flutter test --name "accumulates tokens"           # single test by name
flutter run                                        # run on connected device/simulator
```

## Code generation

This project relies heavily on generated code — every `*.g.dart` file is generated and gitignored-adjacent but committed. **After editing any `@riverpod`/`@Riverpod` provider or any `@collection` Isar model, you must rerun `build_runner`** or the app won't compile.

Note the pinned `riverpod_generator: ^2.3.11` (not the latest 2.4.x): newer versions require analyzer ^6.5+, which conflicts with `isar_generator 3.x` (needs analyzer <6.0.0). Don't bump it without resolving that constraint — see the comment in `pubspec.yaml`.

## Architecture

**Layering:** `core/` holds cross-cutting services (DB, LLM, router, prefs); `features/<name>/` each contain `data/` (Isar model + repository), `providers/` (Riverpod), `screens/`, `widgets/`. State management is Riverpod throughout; DI is done via provider overrides in tests.

**Provider → Service split:** services (`LlmService`, `IsarService`, `ModelDownloadService`, repositories) are plain classes holding logic and are unit-testable in isolation. Riverpod providers wrap them, resolve async dependencies (file paths, DB handles), and manage lifecycle. `isar`, `llmServiceNotifier`, and `appRouter` are `keepAlive: true` singletons.

**First-launch model gate:** the app cannot function until the ~1GB GGUF model is downloaded. `appRouter`'s `redirect` reads the `model_ready` bool from SharedPreferences and forces `/model-setup` until it's true. `ModelSetupScreen` drives `ModelDownloadNotifier.startDownload()`, which downloads from HuggingFace (`ModelDownloadService.kDefaultModelUrl`, Qwen2.5-1.5B-Instruct Q4_K_M) to the app documents dir, then sets `model_ready`. Only after that does `llmServiceNotifier` load the model into memory.

**Suggestion streaming:** `LlmService.suggestNextMeal` returns a token `Stream<String>`. `mealSuggestionProvider` (a `Stream` provider) accumulates tokens into a growing cumulative string (buffer.toString() on each token) so the UI shows text building up live. Watch the accumulation semantics: each emit is the full text so far, not a delta.

**LLM prompt:** `LlmService.buildPrompt` builds a **ChatML-formatted** prompt (`<|im_start|>...<|im_end|>`) required by Qwen2.5-Instruct. The model runs CPU-only (`gpuLayers: 0`) for simulator compatibility. If you change models, the prompt format likely must change too.

**Error signaling via sentinels:** `ModelDownloadNotifier` uses a `double` state where `-1.0` means error (with details in `.error`), `0.0..1.0` is download progress. `LlmServiceNotifier` exposes a `retry()` to recover from a failed model load. Keep these conventions when editing the setup/download flow.

## Data model

Two Isar collections registered in `IsarService.init`: `MealRecord` (date-indexed, `mealType`/`dishName`/`ingredients`) and `Suggestion` (targetDate-indexed, `suggestedDish`, nullable `feedback`). Adding a collection means adding its `Schema` to that `Isar.open` list.

## Testing conventions

- `mocktail` for mocks; inject via `ProviderContainer(overrides: [...])` and `provider.overrideWith(...)`.
- For stream/notifier providers, `provider.future` yields only the **first** emission — use `container.listen(..., fireImmediately: true)` and collect emissions to assert on the final accumulated value.
- Services are tested directly without Riverpod where possible.

## Design reference

Full design spec (Japanese): `docs/superpowers/specs/2026-07-05-meallog-ai-design.md`. Implementation plan: `docs/superpowers/plans/2026-07-05-meallog-ai.md`.
