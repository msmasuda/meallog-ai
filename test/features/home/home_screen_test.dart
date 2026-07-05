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
