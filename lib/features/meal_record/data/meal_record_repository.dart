import 'package:isar/isar.dart';
import 'meal_record_model.dart';

class MealRecordRepository {
  MealRecordRepository(this._isar);
  final Isar _isar;

  Future<void> add(MealRecord record) =>
      _isar.writeTxn(() => _isar.mealRecords.put(record));

  Future<List<MealRecord>> getAll() =>
      _isar.mealRecords.where().sortByDateDesc().findAll();

  Future<List<MealRecord>> getByDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return _isar.mealRecords
        .filter()
        .dateBetween(start, end, includeUpper: false)
        .findAll();
  }

  Future<List<MealRecord>> getRecent({int days = 7}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _isar.mealRecords
        .filter()
        .dateGreaterThan(cutoff)
        .sortByDateDesc()
        .findAll();
  }

  Future<void> delete(Id id) =>
      _isar.writeTxn(() => _isar.mealRecords.delete(id));
}
