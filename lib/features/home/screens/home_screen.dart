import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../history/widgets/history_list_tile.dart';
import '../../meal_record/providers/meal_record_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyNotifierProvider);
    final today = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('つぎのごはん')),
      body: historyAsync.when(
        data: (records) {
          final todayRecords = records
              .where((r) =>
                  r.date.year == today.year &&
                  r.date.month == today.month &&
                  r.date.day == today.day)
              .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: FilledButton.icon(
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('AI提案を受ける'),
                  onPressed: () => context.push('/suggestion'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  '今日の献立',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: todayRecords.isEmpty
                    ? const Center(child: Text('今日の献立はまだ記録されていません'))
                    : ListView.separated(
                        itemCount: todayRecords.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) => HistoryListTile(record: todayRecords[i]),
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/record/add'),
        tooltip: '献立を記録',
        child: const Icon(Icons.add),
      ),
    );
  }
}
