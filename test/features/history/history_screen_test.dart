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
