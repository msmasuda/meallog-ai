import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/db/isar_provider.dart';
import '../data/meal_record_model.dart';
import '../data/meal_record_repository.dart';

part 'meal_record_provider.g.dart';

@Riverpod(keepAlive: true)
Future<MealRecordRepository> mealRecordRepo(MealRecordRepoRef ref) async {
  final isar = await ref.watch(isarProvider.future);
  return MealRecordRepository(isar);
}

@riverpod
Future<List<String>> recentMeals(RecentMealsRef ref) async {
  final repo = await ref.watch(mealRecordRepoProvider.future);
  final records = await repo.getRecent(days: 7);
  return records.map((r) => r.dishName).toList();
}

@riverpod
class HistoryNotifier extends _$HistoryNotifier {
  @override
  Future<List<MealRecord>> build() async {
    final repo = await ref.watch(mealRecordRepoProvider.future);
    return repo.getAll();
  }

  Future<void> add(MealRecord record) async {
    final repo = await ref.read(mealRecordRepoProvider.future);
    await repo.add(record);
    ref.invalidateSelf();
  }

  Future<void> delete(Id id) async {
    final repo = await ref.read(mealRecordRepoProvider.future);
    await repo.delete(id);
    ref.invalidateSelf();
  }
}
