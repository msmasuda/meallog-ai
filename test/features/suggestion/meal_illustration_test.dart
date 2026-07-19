import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meallog_ai/features/suggestion/widgets/meal_illustration.dart';

void main() {
  testWidgets('料理名に対応するカテゴリイメージを表示する', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: MealIllustration(dishName: '鮭の塩焼き')),
      ),
    );

    expect(find.text('魚料理'), findsOneWidget);
    expect(find.byIcon(Icons.set_meal), findsOneWidget);
  });
}
