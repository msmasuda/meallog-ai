import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../meal_record/providers/meal_record_provider.dart';
import '../widgets/history_list_tile.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyNotifierProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('献立履歴')),
      body: historyAsync.when(
        data: (records) => records.isEmpty
            ? const Center(child: Text('まだ献立が記録されていません'))
            : ListView.separated(
                itemCount: records.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) => HistoryListTile(record: records[i]),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: $e')),
      ),
    );
  }
}
