import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meallog_ai/features/suggestion/providers/suggestion_provider.dart';
import 'package:meallog_ai/features/suggestion/screens/suggestion_screen.dart';

void main() {
  late List<StreamController<String>> requests;

  setUp(() {
    requests = [];
  });

  tearDown(() async {
    for (final request in requests) {
      await request.close();
    }
  });

  Future<void> showScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mealSuggestionProvider.overrideWith((ref) {
            final request = StreamController<String>();
            requests.add(request);
            return request.stream;
          }),
        ],
        child: const MaterialApp(home: SuggestionScreen()),
      ),
    );
  }

  void expectLoading() {
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('考え中...'), findsOneWidget);
    expect(find.byTooltip('別の提案'), findsNothing);
    expect(find.byTooltip('これにする'), findsNothing);
    expect(find.text('再試行'), findsNothing);
  }

  testWidgets('shows loading until the first suggestion arrives',
      (tester) async {
    await showScreen(tester);
    expectLoading();

    requests.single.add('麻婆豆腐');
    await tester.pump();

    expect(find.text('麻婆豆腐'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byTooltip('別の提案'), findsOneWidget);
  });

  testWidgets(
      'shows loading during refresh and then streams the new suggestion',
      (tester) async {
    await showScreen(tester);
    requests.single.add('麻婆豆腐');
    await tester.pump();

    await tester.tap(find.byTooltip('別の提案'));
    await tester.pump();

    expect(requests, hasLength(2));
    expectLoading();
    expect(find.text('麻婆豆腐'), findsNothing);

    // A slow response must keep the loading state visible.
    await tester.pump(const Duration(seconds: 5));
    expectLoading();
    expect(requests, hasLength(2));

    requests.last.add('カレー');
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('カレー'), findsOneWidget);

    requests.last.add('カレーライス');
    await tester.pump();
    expect(find.text('カレーライス'), findsOneWidget);
    expect(find.byTooltip('別の提案'), findsOneWidget);
  });

  testWidgets('shows refresh errors and loading again while retrying',
      (tester) async {
    await showScreen(tester);
    requests.single.add('麻婆豆腐');
    await tester.pump();

    await tester.tap(find.byTooltip('別の提案'));
    await tester.pump();
    expectLoading();

    requests.last.addError(Exception('接続できません'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.textContaining('接続できません'), findsOneWidget);
    expect(find.text('再試行'), findsOneWidget);

    await tester.tap(find.text('再試行'));
    await tester.pump();
    expect(requests, hasLength(3));
    expectLoading();
    expect(find.textContaining('接続できません'), findsNothing);

    requests.last.add('焼き魚');
    await tester.pump();
    expect(find.text('焼き魚'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
