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
