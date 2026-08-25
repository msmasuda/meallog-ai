import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meallog_ai/features/meal_record/data/food_label_mapper.dart';
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

  testWidgets('MealImageState displays AI determination result and does not show candidate chips', (tester) async {
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
    expect(find.text('主な食材: カレールー、玉ねぎ'), findsOneWidget);
    expect(find.text('候補から選択:'), findsNothing);
    expect(find.text('キーマカレー'), findsNothing);
  });

  testWidgets('Non-food result shows warning message and does not set dishName', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          historyNotifierProvider.overrideWith(() => _FakeHistory([])),
          mealImageNotifierProvider.overrideWith(() => _FakeMealImageNotifier(
            const MealImageState(
              imagePath: 'cat.jpg',
              result: MealRecognitionResult(
                primaryDishName: '',
                isFoodOrDrink: false,
                category: FoodCategory.nonFood,
                nonFoodDescription: '猫',
              ),
            ),
          )),
        ],
        child: const MaterialApp(home: MealRecordInputScreen()),
      ),
    );

    expect(find.text('食事・飲み物ではないようです (猫)'), findsOneWidget);
    expect(find.text('料理名を手動で入力してください'), findsOneWidget);
    expect(find.widgetWithText(TextField, '猫'), findsNothing);
    expect(find.widgetWithText(TextField, 'Cat'), findsNothing);
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
