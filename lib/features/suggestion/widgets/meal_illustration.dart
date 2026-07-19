import 'package:flutter/material.dart';

class MealIllustration extends StatelessWidget {
  const MealIllustration({super.key, required this.dishName});

  final String dishName;

  @override
  Widget build(BuildContext context) {
    final category = _categoryFor(dishName);
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: '${category.label}のイメージ',
      image: true,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 360),
        height: 180,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              category.color.withValues(alpha: 0.22),
              colors.surfaceContainerHighest,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              right: 24,
              top: 18,
              child: Icon(
                Icons.auto_awesome,
                color: colors.primary.withValues(alpha: 0.35),
              ),
            ),
            CircleAvatar(
              radius: 58,
              backgroundColor: colors.surface.withValues(alpha: 0.9),
              child: Icon(category.icon, size: 72, color: category.color),
            ),
            Positioned(
              bottom: 12,
              child: Text(
                category.label,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _MealCategory _categoryFor(String value) {
    if (_containsAny(value, ['麺', 'ラーメン', 'うどん', 'そば', 'パスタ'])) {
      return const _MealCategory('麺料理', Icons.ramen_dining, Colors.deepOrange);
    }
    if (_containsAny(value, ['魚', '鮭', '鯖', 'サバ', '刺身', '寿司'])) {
      return const _MealCategory('魚料理', Icons.set_meal, Colors.blue);
    }
    if (_containsAny(value, ['カレー', 'シチュー', 'スープ', '汁', '鍋'])) {
      return const _MealCategory('煮込み料理', Icons.soup_kitchen, Colors.orange);
    }
    if (_containsAny(value, ['丼', 'ご飯', 'チャーハン', '寿司'])) {
      return const _MealCategory('ご飯もの', Icons.rice_bowl, Colors.brown);
    }
    if (_containsAny(value, ['サラダ', '野菜'])) {
      return const _MealCategory('野菜料理', Icons.eco, Colors.green);
    }
    return const _MealCategory('おすすめ料理', Icons.restaurant, Colors.pink);
  }

  bool _containsAny(String value, List<String> words) =>
      words.any(value.contains);
}

class _MealCategory {
  const _MealCategory(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}
