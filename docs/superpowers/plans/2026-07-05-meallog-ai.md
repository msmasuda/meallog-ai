# MealLog AI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Flutter MVP app (iOS/Android) that records daily meals and proposes the next meal using an on-device LLM (llamadart/GGUF), with zero API cost and offline operation.

**Architecture:** Feature-first folder structure (`features/meal_record`, `features/suggestion`, `features/history`, `features/home`, `features/model_setup`) with a shared `core/` layer for DB (Isar), LLM (llamadart), and routing (GoRouter). All state managed via Riverpod v2 code generation. GGUF model file is downloaded once on first launch via dio and stored in the app documents directory.

**Tech Stack:** Flutter 3.x, Riverpod 2.x (riverpod_annotation + riverpod_generator), Isar 3.x, llamadart (latest), GoRouter 14.x, dio 5.x, path_provider 2.x, shared_preferences 2.x, mocktail 1.x (tests)

## Global Constraints

- iOS minimum deployment target: **16.4** (llamadart requirement — set in `ios/Podfile` first line)
- Riverpod: always use `@riverpod` annotation + code generation; never write raw `Provider()` calls
- Isar: every write must be inside `isar.writeTxn()`; reads can be outside
- Default LLM model: **Gemma 3 1B Q4_K_M** from HuggingFace — URL defined as `ModelDownloadService.kDefaultModelUrl`
- Dart SDK minimum: **3.4.0**; all files use null safety
- After any change to a `@collection` or `@riverpod` annotated file, run: `flutter pub run build_runner build --delete-conflicting-outputs`

---

## File Structure

| File | Responsibility |
|---|---|
| `lib/main.dart` | Entry point; wraps app in `ProviderScope` |
| `lib/app.dart` | `MaterialApp.router` with theme |
| `lib/core/db/isar_service.dart` | Opens Isar with both schemas; static `init()` |
| `lib/core/db/isar_provider.dart` | `isarProvider` (FutureProvider, keepAlive) |
| `lib/core/shared_prefs_provider.dart` | `sharedPrefsProvider` (FutureProvider, keepAlive) |
| `lib/core/llm/llm_service.dart` | Wraps `LlamaEngine`; exposes `suggestNextMeal()` + `buildPrompt()` |
| `lib/core/llm/llm_provider.dart` | `llmServiceNotifierProvider` (AsyncNotifier, keepAlive) |
| `lib/core/llm/model_download_service.dart` | `download()` with progress; `kDefaultModelUrl`; `modelFilePath()` |
| `lib/core/llm/model_download_provider.dart` | `modelDownloadNotifierProvider` (Notifier<double>) |
| `lib/core/router/app_router.dart` | GoRouter with redirect + `appRouterProvider` |
| `lib/core/router/app_shell.dart` | `AppShell` with BottomNavigationBar (Home / History) |
| `lib/features/meal_record/data/meal_record_model.dart` | Isar `@collection` MealRecord |
| `lib/features/meal_record/data/meal_record_repository.dart` | CRUD: add, getAll, getByDate, getRecent, delete |
| `lib/features/meal_record/providers/meal_record_provider.dart` | `mealRecordRepoProvider`, `recentMealsProvider`, `historyNotifierProvider` |
| `lib/features/meal_record/screens/meal_record_input_screen.dart` | Input form screen |
| `lib/features/meal_record/widgets/meal_type_selector.dart` | SegmentedButton for 朝食/昼食/夕食/間食 |
| `lib/features/suggestion/data/suggestion_model.dart` | Isar `@collection` Suggestion |
| `lib/features/suggestion/data/suggestion_repository.dart` | save, saveFeedback |
| `lib/features/suggestion/providers/suggestion_provider.dart` | `mealSuggestionProvider` (Stream<String>, accumulates tokens) |
| `lib/features/suggestion/screens/suggestion_screen.dart` | Streaming text display + 👍👎 feedback |
| `lib/features/suggestion/widgets/streaming_text_widget.dart` | Text widget for accumulated LLM output |
| `lib/features/history/providers/history_provider.dart` | (merged into `meal_record_provider.dart` — `historyNotifierProvider`) |
| `lib/features/history/screens/history_screen.dart` | Full history list (newest first) |
| `lib/features/history/widgets/history_list_tile.dart` | Single record tile with meal type label |
| `lib/features/home/screens/home_screen.dart` | Today's meals + FAB + AI suggestion button |
| `lib/features/model_setup/screens/model_setup_screen.dart` | Download progress bar; navigates to `/` on complete |
| `test/core/db/isar_service_test.dart` | DB opens with both schemas |
| `test/features/meal_record/meal_record_repository_test.dart` | CRUD unit tests |
| `test/features/meal_record/meal_record_input_screen_test.dart` | Widget smoke test |
| `test/features/history/history_screen_test.dart` | Widget smoke test |
| `test/core/llm/model_download_service_test.dart` | URL and path unit tests |
| `test/core/llm/llm_service_test.dart` | `buildPrompt` unit test |
| `test/features/suggestion/suggestion_provider_test.dart` | Token accumulation unit test |
| `test/features/home/home_screen_test.dart` | Widget smoke test |

---

### Task 1: Flutter project scaffold

**Files:**
- Create: `pubspec.yaml` (replace generated)
- Modify: `ios/Podfile`
- Create: `lib/main.dart`
- Create: `lib/app.dart`

**Interfaces:**
- Produces: Flutter project with all dependencies installed; `ProviderScope(child: App())` entry point

- [ ] **Step 1: Create Flutter project in existing directory**

```bash
cd /Users/mauda/Projects/meallog-ai
flutter create . --project-name meallog_ai --org com.yourname --platforms ios,android
```

Expected: Flutter creates `lib/`, `ios/`, `android/`, `pubspec.yaml`, etc. The existing `docs/` folder and `.git` are unaffected.

- [ ] **Step 2: Replace pubspec.yaml**

Open `pubspec.yaml` and replace the `dependencies:` and `dev_dependencies:` sections entirely:

```yaml
name: meallog_ai
description: つぎのごはん - AI献立提案アプリ
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.4.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.3.5
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1
  llamadart: any
  go_router: ^14.6.2
  shared_preferences: ^2.3.5
  dio: ^5.7.0
  path_provider: ^2.1.5

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.13
  isar_generator: ^3.1.0+1
  riverpod_generator: ^2.4.3
  mocktail: ^1.0.4
  flutter_lints: ^4.0.0

flutter:
  uses-material-design: true
```

> **Note:** `llamadart: any` uses whatever version is available. If `flutter pub get` cannot find the package, check the exact name at https://pub.dev — it may be `llama_cpp_dart` or similar. Update the import statements throughout this plan to match.

- [ ] **Step 3: Install dependencies**

```bash
flutter pub get
```

Expected: `Resolving dependencies...` completes without errors. A `pubspec.lock` is created.

- [ ] **Step 4: Set iOS deployment target to 16.4**

Open `ios/Podfile` and change the first uncommented line to:

```ruby
platform :ios, '16.4'
```

If `use_frameworks!` is present without a linkage flag, change it to:

```ruby
use_frameworks! :linkage => :static
```

- [ ] **Step 5: Write lib/main.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() {
  runApp(const ProviderScope(child: App()));
}
```

- [ ] **Step 6: Write lib/app.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routerAsync = ref.watch(appRouterProvider);
    return routerAsync.when(
      data: (router) => MaterialApp.router(
        title: 'つぎのごはん',
        routerConfig: router,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
          useMaterial3: true,
        ),
      ),
      loading: () => const MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator()))),
      error: (e, _) => MaterialApp(home: Scaffold(body: Center(child: Text('起動エラー: $e')))),
    );
  }
}
```

- [ ] **Step 7: Add stub for app_router.dart so app.dart compiles**

```dart
// lib/core/router/app_router.dart  (STUB — replaced in Task 5)
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
Future<GoRouter> appRouter(AppRouterRef ref) async {
  return GoRouter(routes: []);
}
```

Run build_runner:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 8: Verify no analysis errors**

```bash
flutter analyze lib/
```

Expected: No errors.

- [ ] **Step 9: Commit**

```bash
git add pubspec.yaml pubspec.lock ios/Podfile lib/ android/
git commit -m "chore: scaffold Flutter project with all dependencies"
```

---

### Task 2: Isar data models

**Files:**
- Create: `lib/features/meal_record/data/meal_record_model.dart`
- Create (generated): `lib/features/meal_record/data/meal_record_model.g.dart`
- Create: `lib/features/suggestion/data/suggestion_model.dart`
- Create (generated): `lib/features/suggestion/data/suggestion_model.g.dart`

**Interfaces:**
- Produces: `MealRecord` + `MealRecordSchema`; `Suggestion` + `SuggestionSchema` — consumed by `IsarService` and all repositories

- [ ] **Step 1: Write MealRecord model**

```dart
// lib/features/meal_record/data/meal_record_model.dart
import 'package:isar/isar.dart';

part 'meal_record_model.g.dart';

@collection
class MealRecord {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime date;

  late String mealType; // 'breakfast' | 'lunch' | 'dinner' | 'snack'
  late String dishName;
  List<String> ingredients = [];
  late DateTime createdAt;
}
```

- [ ] **Step 2: Write Suggestion model**

```dart
// lib/features/suggestion/data/suggestion_model.dart
import 'package:isar/isar.dart';

part 'suggestion_model.g.dart';

@collection
class Suggestion {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime targetDate;

  late String mealType;
  late String suggestedDish;
  String? feedback; // 'good' | 'bad' | null
  late DateTime createdAt;
}
```

- [ ] **Step 3: Run code generation**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Expected: `meal_record_model.g.dart` and `suggestion_model.g.dart` generated. Both contain `MealRecordSchema` / `SuggestionSchema`.

- [ ] **Step 4: Verify generated files exist**

```bash
ls lib/features/meal_record/data/meal_record_model.g.dart
ls lib/features/suggestion/data/suggestion_model.g.dart
```

Expected: both files exist.

- [ ] **Step 5: Commit**

```bash
git add lib/features/
git commit -m "feat: add Isar data models MealRecord and Suggestion"
```

---

### Task 3: Core providers (Isar + SharedPreferences)

**Files:**
- Create: `lib/core/db/isar_service.dart`
- Create: `lib/core/db/isar_provider.dart`
- Create (generated): `lib/core/db/isar_provider.g.dart`
- Create: `lib/core/shared_prefs_provider.dart`
- Create (generated): `lib/core/shared_prefs_provider.g.dart`
- Test: `test/core/db/isar_service_test.dart`

**Interfaces:**
- Produces:
  - `IsarService.init(String directory)` → `Future<Isar>`
  - `isarProvider` → `AsyncValue<Isar>` (keepAlive)
  - `sharedPrefsProvider` → `AsyncValue<SharedPreferences>` (keepAlive)

- [ ] **Step 1: Write failing test**

```dart
// test/core/db/isar_service_test.dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:meallog_ai/core/db/isar_service.dart';
import 'package:meallog_ai/features/meal_record/data/meal_record_model.dart';
import 'package:meallog_ai/features/suggestion/data/suggestion_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('IsarService.init opens database with both schemas', () async {
    final dir = await Directory.systemTemp.createTemp('isar_test_');
    final isar = await IsarService.init(dir.path);
    expect(isar.isOpen, isTrue);
    expect(isar.name, equals('meallog'));
    await isar.close(deleteFromDisk: true);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/core/db/isar_service_test.dart
```

Expected: FAIL — `IsarService` not found.

- [ ] **Step 3: Implement IsarService**

```dart
// lib/core/db/isar_service.dart
import 'package:isar/isar.dart';
import '../../features/meal_record/data/meal_record_model.dart';
import '../../features/suggestion/data/suggestion_model.dart';

class IsarService {
  static Future<Isar> init(String directory) => Isar.open(
        [MealRecordSchema, SuggestionSchema],
        directory: directory,
        name: 'meallog',
      );
}
```

- [ ] **Step 4: Implement isarProvider**

```dart
// lib/core/db/isar_provider.dart
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'isar_service.dart';

part 'isar_provider.g.dart';

@Riverpod(keepAlive: true)
Future<Isar> isar(IsarRef ref) async {
  final dir = await getApplicationDocumentsDirectory();
  return IsarService.init(dir.path);
}
```

- [ ] **Step 5: Implement sharedPrefsProvider**

```dart
// lib/core/shared_prefs_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'shared_prefs_provider.g.dart';

@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPrefs(SharedPrefsRef ref) =>
    SharedPreferences.getInstance();
```

- [ ] **Step 6: Run code generation**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 7: Run test to verify it passes**

```bash
flutter test test/core/db/isar_service_test.dart
```

Expected: PASS

- [ ] **Step 8: Commit**

```bash
git add lib/core/ test/core/
git commit -m "feat: add Isar service and core Riverpod providers"
```

---

### Task 4: MealRecord repository + providers

**Files:**
- Create: `lib/features/meal_record/data/meal_record_repository.dart`
- Create: `lib/features/meal_record/providers/meal_record_provider.dart`
- Create (generated): `lib/features/meal_record/providers/meal_record_provider.g.dart`
- Test: `test/features/meal_record/meal_record_repository_test.dart`

**Interfaces:**
- Produces:
  - `MealRecordRepository(Isar)` with: `add(MealRecord)`, `getAll()`, `getByDate(DateTime)`, `getRecent({int days})`, `delete(Id)` — all return `Future<…>`
  - `mealRecordRepoProvider` → `AsyncValue<MealRecordRepository>`
  - `recentMealsProvider` → `AsyncValue<List<String>>` (dish names, last 7 days)
  - `historyNotifierProvider` → `AsyncValue<List<MealRecord>>` (all records, newest first) with `add()` and `delete()` methods

- [ ] **Step 1: Write failing tests**

```dart
// test/features/meal_record/meal_record_repository_test.dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:meallog_ai/core/db/isar_service.dart';
import 'package:meallog_ai/features/meal_record/data/meal_record_model.dart';
import 'package:meallog_ai/features/meal_record/data/meal_record_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Isar isar;
  late MealRecordRepository repo;

  setUp(() async {
    final dir = await Directory.systemTemp.createTemp('isar_test_');
    isar = await IsarService.init(dir.path);
    repo = MealRecordRepository(isar);
  });

  tearDown(() => isar.close(deleteFromDisk: true));

  MealRecord _make({required String dish, DateTime? date}) => MealRecord()
    ..date = date ?? DateTime.now()
    ..mealType = 'dinner'
    ..dishName = dish
    ..createdAt = DateTime.now();

  test('add then getAll returns saved record', () async {
    await repo.add(_make(dish: '鶏の照り焼き'));
    final all = await repo.getAll();
    expect(all, hasLength(1));
    expect(all.first.dishName, equals('鶏の照り焼き'));
  });

  test('getByDate returns only records for that date', () async {
    await repo.add(_make(dish: 'カレー', date: DateTime(2026, 7, 5)));
    await repo.add(_make(dish: 'ラーメン', date: DateTime(2026, 7, 6)));
    final results = await repo.getByDate(DateTime(2026, 7, 5));
    expect(results, hasLength(1));
    expect(results.first.dishName, equals('カレー'));
  });

  test('getRecent excludes records older than N days', () async {
    await repo.add(_make(dish: '豚汁'));
    await repo.add(_make(dish: '古い料理', date: DateTime.now().subtract(const Duration(days: 30))));
    final results = await repo.getRecent(days: 7);
    expect(results.map((r) => r.dishName), contains('豚汁'));
    expect(results.map((r) => r.dishName), isNot(contains('古い料理')));
  });

  test('delete removes the record', () async {
    await repo.add(_make(dish: 'そば'));
    final saved = await repo.getAll();
    await repo.delete(saved.first.id);
    expect(await repo.getAll(), isEmpty);
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
flutter test test/features/meal_record/meal_record_repository_test.dart
```

Expected: FAIL — `MealRecordRepository` not found.

- [ ] **Step 3: Implement MealRecordRepository**

```dart
// lib/features/meal_record/data/meal_record_repository.dart
import 'package:isar/isar.dart';
import 'meal_record_model.dart';

class MealRecordRepository {
  MealRecordRepository(this._isar);
  final Isar _isar;

  Future<void> add(MealRecord record) =>
      _isar.writeTxn(() => _isar.mealRecords.put(record));

  Future<List<MealRecord>> getAll() =>
      _isar.mealRecords.where().sortByDateDesc().findAll();

  Future<List<MealRecord>> getByDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return _isar.mealRecords
        .filter()
        .dateBetween(start, end)
        .findAll();
  }

  Future<List<MealRecord>> getRecent({int days = 7}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _isar.mealRecords
        .filter()
        .dateGreaterThan(cutoff)
        .sortByDateDesc()
        .findAll();
  }

  Future<void> delete(Id id) =>
      _isar.writeTxn(() => _isar.mealRecords.delete(id));
}
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
flutter test test/features/meal_record/meal_record_repository_test.dart
```

Expected: PASS (4 tests)

- [ ] **Step 5: Implement providers**

```dart
// lib/features/meal_record/providers/meal_record_provider.dart
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/db/isar_provider.dart';
import '../data/meal_record_model.dart';
import '../data/meal_record_repository.dart';

part 'meal_record_provider.g.dart';

@Riverpod(keepAlive: true)
Future<MealRecordRepository> mealRecordRepo(MealRecordRepoRef ref) async {
  final isar = await ref.watch(isarProvider.future);
  return MealRecordRepository(isar);
}

@riverpod
Future<List<String>> recentMeals(RecentMealsRef ref) async {
  final repo = await ref.watch(mealRecordRepoProvider.future);
  final records = await repo.getRecent(days: 7);
  return records.map((r) => r.dishName).toList();
}

@riverpod
class HistoryNotifier extends _$HistoryNotifier {
  @override
  Future<List<MealRecord>> build() async {
    final repo = await ref.watch(mealRecordRepoProvider.future);
    return repo.getAll();
  }

  Future<void> add(MealRecord record) async {
    final repo = await ref.read(mealRecordRepoProvider.future);
    await repo.add(record);
    ref.invalidateSelf();
  }

  Future<void> delete(Id id) async {
    final repo = await ref.read(mealRecordRepoProvider.future);
    await repo.delete(id);
    ref.invalidateSelf();
  }
}
```

- [ ] **Step 6: Run code generation**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 7: Commit**

```bash
git add lib/features/meal_record/ test/features/meal_record/meal_record_repository_test.dart
git commit -m "feat: add MealRecord repository and Riverpod providers"
```

---

### Task 5: GoRouter + AppShell + stub screens

**Files:**
- Replace stub: `lib/core/router/app_router.dart`
- Create: `lib/core/router/app_shell.dart`
- Create (stubs, replaced later): `lib/features/home/screens/home_screen.dart`, `lib/features/model_setup/screens/model_setup_screen.dart`, `lib/features/history/screens/history_screen.dart`, `lib/features/meal_record/screens/meal_record_input_screen.dart`, `lib/features/suggestion/screens/suggestion_screen.dart`

**Interfaces:**
- Consumes: `sharedPrefsProvider`
- Produces:
  - `appRouterProvider` → `AsyncValue<GoRouter>` with routes: `/model-setup`, `/`, `/history`, `/record/add`, `/suggestion`
  - `AppShell` scaffold with BottomNavigationBar (Home / History)
  - Redirect: if `model_ready` flag is false, redirect any route to `/model-setup`

- [ ] **Step 1: Write stub screens**

```dart
// lib/features/home/screens/home_screen.dart
import 'package:flutter/material.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('ホーム (stub)')));
}
```

```dart
// lib/features/model_setup/screens/model_setup_screen.dart
import 'package:flutter/material.dart';
class ModelSetupScreen extends StatelessWidget {
  const ModelSetupScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('モデル準備中... (stub)')));
}
```

```dart
// lib/features/history/screens/history_screen.dart
import 'package:flutter/material.dart';
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('履歴 (stub)')));
}
```

```dart
// lib/features/meal_record/screens/meal_record_input_screen.dart
import 'package:flutter/material.dart';
class MealRecordInputScreen extends StatelessWidget {
  const MealRecordInputScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('献立入力 (stub)')));
}
```

```dart
// lib/features/suggestion/screens/suggestion_screen.dart
import 'package:flutter/material.dart';
class SuggestionScreen extends StatelessWidget {
  const SuggestionScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('AI提案 (stub)')));
}
```

- [ ] **Step 2: Implement AppShell**

```dart
// lib/core/router/app_shell.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final selectedIndex = location.startsWith('/history') ? 1 : 0;

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          if (index == 0) context.go('/');
          if (index == 1) context.go('/history');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: '履歴'),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Implement appRouterProvider (replace stub)**

```dart
// lib/core/router/app_router.dart
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_shell.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/history/screens/history_screen.dart';
import '../../features/meal_record/screens/meal_record_input_screen.dart';
import '../../features/model_setup/screens/model_setup_screen.dart';
import '../../features/suggestion/screens/suggestion_screen.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
Future<GoRouter> appRouter(AppRouterRef ref) async {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final prefs = await SharedPreferences.getInstance();
      final modelReady = prefs.getBool('model_ready') ?? false;
      if (!modelReady && state.fullPath != '/model-setup') {
        return '/model-setup';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/model-setup',
        builder: (context, state) => const ModelSetupScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          GoRoute(path: '/history', builder: (context, state) => const HistoryScreen()),
          GoRoute(path: '/record/add', builder: (context, state) => const MealRecordInputScreen()),
          GoRoute(path: '/suggestion', builder: (context, state) => const SuggestionScreen()),
        ],
      ),
    ],
  );
}
```

- [ ] **Step 4: Run code generation**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 5: Smoke test — app launches to model-setup stub**

```bash
flutter run
```

Manual check: app launches; because `model_ready` is not set, the `/model-setup` stub screen is shown. No BottomNav on that screen. Stop with Ctrl+C.

- [ ] **Step 6: Commit**

```bash
git add lib/core/router/ lib/features/home/ lib/features/model_setup/ lib/features/history/screens/ lib/features/meal_record/screens/ lib/features/suggestion/screens/
git commit -m "feat: add GoRouter with AppShell, redirect logic, and stub screens"
```

---

### Task 6: Meal record input screen

**Files:**
- Create: `lib/features/meal_record/widgets/meal_type_selector.dart`
- Replace stub: `lib/features/meal_record/screens/meal_record_input_screen.dart`
- Test: `test/features/meal_record/meal_record_input_screen_test.dart`

**Interfaces:**
- Consumes: `historyNotifierProvider.notifier.add(MealRecord)`
- Produces: form at `/record/add` that saves a `MealRecord` (with today's date) and pops back

- [ ] **Step 1: Write failing widget test**

```dart
// test/features/meal_record/meal_record_input_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meallog_ai/features/meal_record/data/meal_record_model.dart';
import 'package:meallog_ai/features/meal_record/providers/meal_record_provider.dart';
import 'package:meallog_ai/features/meal_record/screens/meal_record_input_screen.dart';

void main() {
  testWidgets('MealRecordInputScreen shows meal type selector, text field, and save button', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          historyNotifierProvider.overrideWith(() => _FakeHistory([])),
        ],
        child: const MaterialApp(home: MealRecordInputScreen()),
      ),
    );
    expect(find.text('夕食'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('保存'), findsOneWidget);
  });
}

class _FakeHistory extends HistoryNotifier {
  _FakeHistory(this._records);
  final List<MealRecord> _records;
  @override
  Future<List<MealRecord>> build() async => _records;
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/features/meal_record/meal_record_input_screen_test.dart
```

Expected: FAIL

- [ ] **Step 3: Implement MealTypeSelector widget**

```dart
// lib/features/meal_record/widgets/meal_type_selector.dart
import 'package:flutter/material.dart';

const _mealTypes = [
  ('breakfast', '朝食'),
  ('lunch', '昼食'),
  ('dinner', '夕食'),
  ('snack', '間食'),
];

class MealTypeSelector extends StatelessWidget {
  const MealTypeSelector({super.key, required this.selected, required this.onChanged});
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: _mealTypes
          .map((t) => ButtonSegment(value: t.$1, label: Text(t.$2)))
          .toList(),
      selected: {selected},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}
```

- [ ] **Step 4: Implement MealRecordInputScreen (replace stub)**

```dart
// lib/features/meal_record/screens/meal_record_input_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/meal_record_model.dart';
import '../providers/meal_record_provider.dart';
import '../widgets/meal_type_selector.dart';

class MealRecordInputScreen extends ConsumerStatefulWidget {
  const MealRecordInputScreen({super.key});

  @override
  ConsumerState<MealRecordInputScreen> createState() => _MealRecordInputScreenState();
}

class _MealRecordInputScreenState extends ConsumerState<MealRecordInputScreen> {
  final _controller = TextEditingController();
  String _mealType = 'dinner';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final dishName = _controller.text.trim();
    if (dishName.isEmpty) return;
    final record = MealRecord()
      ..date = DateTime.now()
      ..mealType = _mealType
      ..dishName = dishName
      ..createdAt = DateTime.now();
    await ref.read(historyNotifierProvider.notifier).add(record);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('献立を記録')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MealTypeSelector(
              selected: _mealType,
              onChanged: (v) => setState(() => _mealType = v),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: '料理名',
                hintText: '例: 鶏の照り焼き',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: const Text('保存')),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Run test to verify it passes**

```bash
flutter test test/features/meal_record/meal_record_input_screen_test.dart
```

Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add lib/features/meal_record/ test/features/meal_record/meal_record_input_screen_test.dart
git commit -m "feat: implement meal record input screen with meal type selector"
```

---

### Task 7: History screen

**Files:**
- Create: `lib/features/history/widgets/history_list_tile.dart`
- Replace stub: `lib/features/history/screens/history_screen.dart`
- Test: `test/features/history/history_screen_test.dart`

**Interfaces:**
- Consumes: `historyNotifierProvider` → `AsyncValue<List<MealRecord>>`
- Produces: Scrollable list at `/history`; `HistoryListTile` also used by `HomeScreen` (Task 11)

- [ ] **Step 1: Write failing widget test**

```dart
// test/features/history/history_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meallog_ai/features/history/screens/history_screen.dart';
import 'package:meallog_ai/features/meal_record/data/meal_record_model.dart';
import 'package:meallog_ai/features/meal_record/providers/meal_record_provider.dart';

void main() {
  testWidgets('HistoryScreen shows meal records', (tester) async {
    final record = MealRecord()
      ..date = DateTime(2026, 7, 5)
      ..mealType = 'dinner'
      ..dishName = '鶏の照り焼き'
      ..createdAt = DateTime.now();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          historyNotifierProvider.overrideWith(() => _FakeHistory([record])),
        ],
        child: const MaterialApp(home: HistoryScreen()),
      ),
    );
    await tester.pump();
    expect(find.text('鶏の照り焼き'), findsOneWidget);
  });

  testWidgets('HistoryScreen shows empty state message', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          historyNotifierProvider.overrideWith(() => _FakeHistory([])),
        ],
        child: const MaterialApp(home: HistoryScreen()),
      ),
    );
    await tester.pump();
    expect(find.text('まだ献立が記録されていません'), findsOneWidget);
  });
}

class _FakeHistory extends HistoryNotifier {
  _FakeHistory(this._records);
  final List<MealRecord> _records;
  @override
  Future<List<MealRecord>> build() async => _records;
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
flutter test test/features/history/history_screen_test.dart
```

Expected: FAIL

- [ ] **Step 3: Implement HistoryListTile**

```dart
// lib/features/history/widgets/history_list_tile.dart
import 'package:flutter/material.dart';
import '../../meal_record/data/meal_record_model.dart';

const _labels = {
  'breakfast': '朝食',
  'lunch': '昼食',
  'dinner': '夕食',
  'snack': '間食',
};

class HistoryListTile extends StatelessWidget {
  const HistoryListTile({super.key, required this.record});
  final MealRecord record;

  @override
  Widget build(BuildContext context) {
    final label = _labels[record.mealType] ?? record.mealType;
    return ListTile(
      leading: CircleAvatar(child: Text(label[0])),
      title: Text(record.dishName),
      subtitle: Text('$label · ${_fmt(record.date)}'),
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
}
```

- [ ] **Step 4: Implement HistoryScreen (replace stub)**

```dart
// lib/features/history/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../meal_record/providers/meal_record_provider.dart';
import '../widgets/history_list_tile.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyNotifierProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('献立履歴')),
      body: historyAsync.when(
        data: (records) => records.isEmpty
            ? const Center(child: Text('まだ献立が記録されていません'))
            : ListView.separated(
                itemCount: records.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) => HistoryListTile(record: records[i]),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: $e')),
      ),
    );
  }
}
```

- [ ] **Step 5: Run tests to verify they pass**

```bash
flutter test test/features/history/history_screen_test.dart
```

Expected: PASS (2 tests)

- [ ] **Step 6: Commit**

```bash
git add lib/features/history/ test/features/history/
git commit -m "feat: implement history screen and HistoryListTile widget"
```

---

### Task 8: Model download service + ModelSetupScreen

**Files:**
- Create: `lib/core/llm/model_download_service.dart`
- Create: `lib/core/llm/model_download_provider.dart`
- Create (generated): `lib/core/llm/model_download_provider.g.dart`
- Replace stub: `lib/features/model_setup/screens/model_setup_screen.dart`
- Test: `test/core/llm/model_download_service_test.dart`

**Interfaces:**
- Produces:
  - `ModelDownloadService.kDefaultModelUrl` → `String`
  - `ModelDownloadService.modelFilePath(String docsDir)` → `String`
  - `ModelDownloadService.download({required url, required savePath, required onProgress, Dio? dio})` → `Future<void>`
  - `modelDownloadNotifierProvider` → `double` (progress 0.0–1.0; 1.0 = complete)
  - `ModelSetupScreen` — LinearProgressIndicator; navigates to `/` and sets `model_ready = true` on completion

- [ ] **Step 1: Write failing tests**

```dart
// test/core/llm/model_download_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:meallog_ai/core/llm/model_download_service.dart';

void main() {
  test('kDefaultModelUrl is a non-empty HTTPS URL', () {
    expect(ModelDownloadService.kDefaultModelUrl, startsWith('https://'));
    expect(ModelDownloadService.kDefaultModelUrl, isNotEmpty);
  });

  test('modelFilePath returns a path ending with .gguf under given dir', () {
    final path = ModelDownloadService.modelFilePath('/docs');
    expect(path, startsWith('/docs/'));
    expect(path, endsWith('.gguf'));
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
flutter test test/core/llm/model_download_service_test.dart
```

Expected: FAIL

- [ ] **Step 3: Implement ModelDownloadService**

```dart
// lib/core/llm/model_download_service.dart
import 'package:dio/dio.dart';

class ModelDownloadService {
  static const kDefaultModelUrl =
      'https://huggingface.co/bartowski/gemma-3-1b-it-GGUF/resolve/main/gemma-3-1b-it-Q4_K_M.gguf';

  static const _modelFileName = 'gemma-3-1b-it-Q4_K_M.gguf';

  static String modelFilePath(String docsDir) => '$docsDir/$_modelFileName';

  static Future<void> download({
    required String url,
    required String savePath,
    required void Function(double progress) onProgress,
    Dio? dio,
  }) async {
    final client = dio ?? Dio();
    await client.download(
      url,
      savePath,
      onReceiveProgress: (received, total) {
        if (total > 0) onProgress(received / total);
      },
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
flutter test test/core/llm/model_download_service_test.dart
```

Expected: PASS (2 tests)

- [ ] **Step 5: Implement modelDownloadNotifierProvider**

```dart
// lib/core/llm/model_download_provider.dart
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'model_download_service.dart';

part 'model_download_provider.g.dart';

@riverpod
class ModelDownloadNotifier extends _$ModelDownloadNotifier {
  @override
  double build() => 0.0;

  Future<void> startDownload() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final savePath = ModelDownloadService.modelFilePath(docsDir.path);
    await ModelDownloadService.download(
      url: ModelDownloadService.kDefaultModelUrl,
      savePath: savePath,
      onProgress: (p) => state = p,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('model_ready', true);
    state = 1.0;
  }
}
```

Run code generation:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 6: Implement ModelSetupScreen (replace stub)**

```dart
// lib/features/model_setup/screens/model_setup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/llm/model_download_provider.dart';

class ModelSetupScreen extends ConsumerStatefulWidget {
  const ModelSetupScreen({super.key});

  @override
  ConsumerState<ModelSetupScreen> createState() => _ModelSetupScreenState();
}

class _ModelSetupScreenState extends ConsumerState<ModelSetupScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(modelDownloadNotifierProvider.notifier).startDownload().then((_) {
        if (mounted) context.go('/');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(modelDownloadNotifierProvider);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('AIモデルを準備しています...', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 24),
              LinearProgressIndicator(value: progress > 0 ? progress : null),
              const SizedBox(height: 12),
              Text('${(progress * 100).toStringAsFixed(0)}%'),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 7: Commit**

```bash
git add lib/core/llm/ lib/features/model_setup/ test/core/llm/model_download_service_test.dart
git commit -m "feat: add model download service and setup screen with progress bar"
```

---

### Task 9: LLM service + llmServiceNotifierProvider

**Files:**
- Create: `lib/core/llm/llm_service.dart`
- Create: `lib/core/llm/llm_provider.dart`
- Create (generated): `lib/core/llm/llm_provider.g.dart`
- Test: `test/core/llm/llm_service_test.dart`

**Interfaces:**
- Produces:
  - `LlmService.buildPrompt({required List<String> recentMeals, String mealType})` → `String` (static, testable without LlamaEngine)
  - `LlmService.loadModel(String modelPath)` → `Future<void>`
  - `LlmService.suggestNextMeal({required List<String> recentMeals, String mealType})` → `Stream<String>`
  - `llmServiceNotifierProvider` → `AsyncValue<LlmService>` (keepAlive; loads model on build)

- [ ] **Step 1: Write failing test**

```dart
// test/core/llm/llm_service_test.dart
import 'package:flutter_test/flutter_test.dart';
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
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
flutter test test/core/llm/llm_service_test.dart
```

Expected: FAIL

- [ ] **Step 3: Implement LlmService**

This integrates the PoC from `meal_suggestion_llm_service.dart`. Note: verify the exact llamadart API (`LlamaEngine` constructor and method signatures) against the package's README before running.

```dart
// lib/core/llm/llm_service.dart
import 'package:llamadart/llamadart.dart';

class LlmService {
  LlamaEngine? _engine;
  bool get isReady => _engine != null;

  Future<void> loadModel(String modelPath) async {
    final engine = LlamaEngine();
    await engine.loadModel(
      path: modelPath,
      contextSize: 2048,
      gpuLayers: 20,
    );
    _engine = engine;
  }

  Stream<String> suggestNextMeal({
    required List<String> recentMeals,
    String mealType = '夕食',
  }) {
    if (_engine == null) throw StateError('モデルが未ロードです');
    return _engine!.generate(buildPrompt(recentMeals: recentMeals, mealType: mealType));
  }

  static String buildPrompt({
    required List<String> recentMeals,
    String mealType = '夕食',
  }) {
    final historyText = recentMeals.join('、');
    return '''
あなたは献立提案アシスタントです。以下の直近の献立履歴を見て、
同じ食材や調理法が続かないように、次の${mealType}の献立を1つだけ提案してください。

# 直近の献立履歴
$historyText

# 出力形式
料理名だけを1行で答えてください。理由は不要です。
''';
  }

  Future<void> dispose() async {
    _engine = null;
  }
}
```

- [ ] **Step 4: Implement llmServiceNotifierProvider**

```dart
// lib/core/llm/llm_provider.dart
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'llm_service.dart';
import 'model_download_service.dart';

part 'llm_provider.g.dart';

@Riverpod(keepAlive: true)
class LlmServiceNotifier extends _$LlmServiceNotifier {
  @override
  Future<LlmService> build() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final modelPath = ModelDownloadService.modelFilePath(docsDir.path);
    final service = LlmService();
    await service.loadModel(modelPath);
    ref.onDispose(service.dispose);
    return service;
  }
}
```

Run code generation:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 5: Run tests to verify they pass**

```bash
flutter test test/core/llm/llm_service_test.dart
```

Expected: PASS (2 tests)

- [ ] **Step 6: Commit**

```bash
git add lib/core/llm/ test/core/llm/llm_service_test.dart
git commit -m "feat: add LLM service wrapping llamadart and llmServiceNotifierProvider"
```

---

### Task 10: Suggestion provider + SuggestionScreen

**Files:**
- Create: `lib/features/suggestion/data/suggestion_repository.dart`
- Create: `lib/features/suggestion/providers/suggestion_provider.dart`
- Create (generated): `lib/features/suggestion/providers/suggestion_provider.g.dart`
- Create: `lib/features/suggestion/widgets/streaming_text_widget.dart`
- Replace stub: `lib/features/suggestion/screens/suggestion_screen.dart`
- Test: `test/features/suggestion/suggestion_provider_test.dart`

**Interfaces:**
- Consumes: `llmServiceNotifierProvider`, `recentMealsProvider`, `isarProvider`
- Produces:
  - `mealSuggestionProvider` → `AsyncValue<String>` — each emission is the accumulated text so far; stream completes with full response
  - `SuggestionRepository.save(Suggestion)` → `Future<void>`
  - `SuggestionScreen` — displays accumulated text, 👍 saves + pops, 👎 invalidates provider to re-generate

- [ ] **Step 1: Write failing test**

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
    when(() => mockLlm.suggestNextMeal(
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

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/features/suggestion/suggestion_provider_test.dart
```

Expected: FAIL

- [ ] **Step 3: Implement SuggestionRepository**

```dart
// lib/features/suggestion/data/suggestion_repository.dart
import 'package:isar/isar.dart';
import 'suggestion_model.dart';

class SuggestionRepository {
  SuggestionRepository(this._isar);
  final Isar _isar;

  Future<void> save(Suggestion suggestion) =>
      _isar.writeTxn(() => _isar.suggestions.put(suggestion));

  Future<void> saveFeedback(Id id, String feedback) async {
    await _isar.writeTxn(() async {
      final s = await _isar.suggestions.get(id);
      if (s == null) return;
      s.feedback = feedback;
      await _isar.suggestions.put(s);
    });
  }
}
```

- [ ] **Step 4: Implement mealSuggestionProvider**

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
  await for (final token in llmService.suggestNextMeal(recentMeals: recentMeals)) {
    buffer.write(token);
    yield buffer.toString();
  }
}
```

Run code generation:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 5: Run test to verify it passes**

```bash
flutter test test/features/suggestion/suggestion_provider_test.dart
```

Expected: PASS

- [ ] **Step 6: Implement StreamingTextWidget**

```dart
// lib/features/suggestion/widgets/streaming_text_widget.dart
import 'package:flutter/material.dart';

class StreamingTextWidget extends StatelessWidget {
  const StreamingTextWidget({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.headlineMedium,
      textAlign: TextAlign.center,
    );
  }
}
```

- [ ] **Step 7: Implement SuggestionScreen (replace stub)**

```dart
// lib/features/suggestion/screens/suggestion_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/suggestion_provider.dart';
import '../widgets/streaming_text_widget.dart';

class SuggestionScreen extends ConsumerWidget {
  const SuggestionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionAsync = ref.watch(mealSuggestionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('AI献立提案')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: suggestionAsync.when(
            data: (text) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '次の献立はこちら',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                StreamingTextWidget(text: text),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filled(
                      icon: const Icon(Icons.thumb_up),
                      tooltip: 'これにする',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 16),
                    IconButton.filled(
                      icon: const Icon(Icons.thumb_down),
                      tooltip: '別の提案',
                      onPressed: () => ref.invalidate(mealSuggestionProvider),
                    ),
                  ],
                ),
              ],
            ),
            loading: () => const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('考え中...'),
              ],
            ),
            error: (e, _) => Text(
              'エラー: $e',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 8: Commit**

```bash
git add lib/features/suggestion/ test/features/suggestion/
git commit -m "feat: add suggestion provider with token accumulation and streaming screen"
```

---

### Task 11: HomeScreen (MVP integration)

**Files:**
- Replace stub: `lib/features/home/screens/home_screen.dart`
- Test: `test/features/home/home_screen_test.dart`

**Interfaces:**
- Consumes: `historyNotifierProvider`, GoRouter (`/record/add`, `/suggestion`)
- Produces: Final integrated home screen — today's meals list + FAB to add record + "AI提案を受ける" button

- [ ] **Step 1: Write failing widget test**

```dart
// test/features/home/home_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:meallog_ai/features/home/screens/home_screen.dart';
import 'package:meallog_ai/features/meal_record/data/meal_record_model.dart';
import 'package:meallog_ai/features/meal_record/providers/meal_record_provider.dart';

void main() {
  testWidgets('HomeScreen shows AI suggestion button and today records', (tester) async {
    final today = DateTime.now();
    final record = MealRecord()
      ..date = today
      ..mealType = 'dinner'
      ..dishName = '鶏の照り焼き'
      ..createdAt = today;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          historyNotifierProvider.overrideWith(() => _FakeHistory([record])),
        ],
        child: MaterialApp.router(
          routerConfig: GoRouter(routes: [
            GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
            GoRoute(path: '/record/add', builder: (_, __) => const SizedBox()),
            GoRoute(path: '/suggestion', builder: (_, __) => const SizedBox()),
          ]),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('AI提案を受ける'), findsOneWidget);
    expect(find.text('鶏の照り焼き'), findsOneWidget);
  });

  testWidgets('HomeScreen shows empty state when no records today', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          historyNotifierProvider.overrideWith(() => _FakeHistory([])),
        ],
        child: MaterialApp.router(
          routerConfig: GoRouter(routes: [
            GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
            GoRoute(path: '/record/add', builder: (_, __) => const SizedBox()),
            GoRoute(path: '/suggestion', builder: (_, __) => const SizedBox()),
          ]),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('今日の献立はまだ記録されていません'), findsOneWidget);
  });
}

class _FakeHistory extends HistoryNotifier {
  _FakeHistory(this._records);
  final List<MealRecord> _records;
  @override
  Future<List<MealRecord>> build() async => _records;
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
flutter test test/features/home/home_screen_test.dart
```

Expected: FAIL

- [ ] **Step 3: Implement HomeScreen (replace stub)**

```dart
// lib/features/home/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../history/widgets/history_list_tile.dart';
import '../../meal_record/providers/meal_record_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyNotifierProvider);
    final today = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('つぎのごはん')),
      body: historyAsync.when(
        data: (records) {
          final todayRecords = records
              .where((r) =>
                  r.date.year == today.year &&
                  r.date.month == today.month &&
                  r.date.day == today.day)
              .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: FilledButton.icon(
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('AI提案を受ける'),
                  onPressed: () => context.push('/suggestion'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  '今日の献立',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: todayRecords.isEmpty
                    ? const Center(child: Text('今日の献立はまだ記録されていません'))
                    : ListView.separated(
                        itemCount: todayRecords.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) => HistoryListTile(record: todayRecords[i]),
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/record/add'),
        tooltip: '献立を記録',
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
flutter test test/features/home/home_screen_test.dart
```

Expected: PASS (2 tests)

- [ ] **Step 5: Run full test suite**

```bash
flutter test
```

Expected: All tests pass.

- [ ] **Step 6: End-to-end smoke test on simulator/device**

```bash
flutter run
```

Manual verification checklist:
1. First launch → `/model-setup` screen with animated progress bar
2. After download completes → automatically navigates to `/` home screen
3. Home: BottomNav shows ホーム / 履歴 tabs
4. Tap FAB → `/record/add`; select 夕食, type "鶏の照り焼き", tap 保存 → back to home; record appears in today's list
5. Tap "AI提案を受ける" → `/suggestion`; spinner shows, then text streams in character by character
6. Tap 👎 → re-generates suggestion
7. Tap History tab → shows all recorded meals in list

- [ ] **Step 7: Final commit**

```bash
git add lib/features/home/ test/features/home/
git commit -m "feat: implement home screen — MVP complete"
```

---

## Self-Review Checklist

| Spec requirement | Task |
|---|---|
| Flutter + llamadart setup | Task 1 |
| iOS deployment target 16.4 | Task 1 |
| Isar data models (MealRecord, Suggestion) | Task 2 |
| isarProvider + sharedPrefsProvider | Task 3 |
| MealRecord CRUD | Task 4 |
| GoRouter + BottomNav + redirect | Task 5 |
| Meal record input (text, meal type) | Task 6 |
| History list screen | Task 7 |
| First-launch model download with progress | Task 8 |
| LLM service (wraps llamadart PoC) | Task 9 |
| AI suggestion with streaming display | Task 10 |
| Home screen integration | Task 11 |
| Riverpod code generation throughout | All tasks |
| TDD (test → fail → implement → pass) | All tasks |
