import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meallog_ai/features/meal_record/data/meal_image_service.dart';
import 'package:meallog_ai/features/meal_record/data/meal_record_model.dart';
import 'package:meallog_ai/features/meal_record/providers/meal_image_provider.dart';
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
    expect(find.text('写真から料理をAI自動判定'), findsOneWidget);
    expect(find.text('カメラ'), findsOneWidget);
    expect(find.text('アルバム'), findsOneWidget);
  });

  testWidgets('Selecting a candidate from MealImageState pre-fills dishName TextField', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          historyNotifierProvider.overrideWith(() => _FakeHistory([])),
          mealImageNotifierProvider.overrideWith(() => _FakeMealImageNotifier(
            const MealImageState(
              imagePath: 'dummy.jpg',
              result: MealRecognitionResult(
                primaryDishName: 'カレーライス',
                candidates: ['カレーライス', 'キーマカレー'],
                ingredients: ['カレールー', '玉ねぎ'],
              ),
            ),
          )),
        ],
        child: const MaterialApp(home: MealRecordInputScreen()),
      ),
    );

    expect(find.text('AI判定: カレーライス'), findsOneWidget);
    expect(find.text('キーマカレー'), findsOneWidget);

    // Tap candidate chip 'キーマカレー'
    await tester.tap(find.text('キーマカレー'));
    await tester.pump();

    // Verify text field contains 'キーマカレー'
    expect(find.widgetWithText(TextField, 'キーマカレー'), findsOneWidget);
  });
}

class _FakeMealImageNotifier extends MealImageNotifier {
  _FakeMealImageNotifier(this._initialState);
  final MealImageState _initialState;

  @override
  MealImageState build() => _initialState;
}

class _FakeHistory extends HistoryNotifier {
  _FakeHistory(this._records);
  final List<MealRecord> _records;
  @override
  Future<List<MealRecord>> build() async => _records;
}
