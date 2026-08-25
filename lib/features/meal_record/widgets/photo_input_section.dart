// lib/features/meal_record/widgets/photo_input_section.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../data/food_label_mapper.dart';
import '../providers/meal_image_provider.dart';

class PhotoInputSection extends ConsumerWidget {
  const PhotoInputSection({
    super.key,
    required this.onDishSelected,
    this.onIngredientsDetected,
  });

  final ValueChanged<String> onDishSelected;
  final ValueChanged<List<String>>? onIngredientsDetected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mealImageNotifierProvider);
    final notifier = ref.read(mealImageNotifierProvider.notifier);

        // 画像がまだ選択されていない場合
        if (state.imagePath == null) {
          return Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              child: Column(
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    size: 36,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '写真から料理をAI自動判定',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '完全端末内で安全に解析されます',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () async {
                          await notifier.pickAndAnalyze(source: ImageSource.camera);
                          _handleResult(ref);
                        },
                        icon: const Icon(Icons.photo_camera, size: 18),
                        label: const Text('カメラ'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () async {
                          await notifier.pickAndAnalyze(source: ImageSource.gallery);
                          _handleResult(ref);
                        },
                        icon: const Icon(Icons.photo_library, size: 18),
                        label: const Text('アルバム'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        // 画像が選択されている場合
        final file = File(state.imagePath!);
        return Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // サムネイル
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: file.existsSync()
                          ? Image.file(
                              file,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.image, color: Colors.grey),
                            ),
                    ),
                    const SizedBox(width: 12),
                    // 解析状況ステータス
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (state.isLoading) ...[
                            const Row(
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'AIが画像を解析中...',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '端末内で判定しています',
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ] else if (state.result != null) ...[
                            if (!state.result!.isFoodOrDrink) ...[
                              // 非食品判定時のメッセージ
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 16,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      state.result!.nonFoodDescription != null
                                          ? '食事・飲み物ではないようです (${state.result!.nonFoodDescription})'
                                          : '食事・飲み物が検出されませんでした',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.error,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '料理名を手動で入力してください',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ] else ...[
                              // 食事・ドリンク判定時の表示
                              Row(
                                children: [
                                  Icon(
                                    state.result!.category == FoodCategory.drink
                                        ? Icons.local_cafe_outlined
                                        : Icons.check_circle,
                                    size: 16,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'AI判定: ${state.result!.primaryDishName}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (state.result!.ingredients.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '主な食材: ${state.result!.ingredients.take(4).join("、")}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ] else if (state.errorMessage != null) ...[
                            Text(
                              state.errorMessage!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // 削除ボタン
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      tooltip: '写真を削除',
                      onPressed: () => notifier.clear(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
  }

  void _handleResult(WidgetRef ref) {
    final state = ref.read(mealImageNotifierProvider);
    if (state.result != null && state.result!.isFoodOrDrink && state.result!.primaryDishName.isNotEmpty) {
      onDishSelected(state.result!.primaryDishName);
      if (state.result!.ingredients.isNotEmpty && onIngredientsDetected != null) {
        onIngredientsDetected!(state.result!.ingredients);
      }
    }
  }
}
