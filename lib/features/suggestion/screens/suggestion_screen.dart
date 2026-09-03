// lib/features/suggestion/screens/suggestion_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/suggestion_model.dart';
import '../providers/suggestion_provider.dart';
import '../providers/suggestion_repo_provider.dart';
import '../widgets/meal_illustration.dart';
import '../widgets/streaming_text_widget.dart';

class SuggestionScreen extends ConsumerWidget {
  const SuggestionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionAsync = ref.watch(mealSuggestionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('AI献立提案')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: suggestionAsync.when(
            data: (text) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '次の献立はこちら',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                MealIllustration(dishName: text),
                const SizedBox(height: 24),
                StreamingTextWidget(text: text),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filled(
                      icon: const Icon(Icons.thumb_up),
                      tooltip: 'これにする',
                      onPressed: () async {
                        final repo =
                            await ref.read(suggestionRepoProvider.future);
                        final suggestion = Suggestion()
                          ..targetDate = DateTime.now()
                          ..mealType = '夕食'
                          ..suggestedDish = text
                          ..createdAt = DateTime.now();
                        await repo.save(suggestion);
                        if (context.mounted) Navigator.of(context).pop();
                      },
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
            error: (e, _) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'エラー: $e',
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(mealSuggestionProvider),
                  child: const Text('再試行'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
