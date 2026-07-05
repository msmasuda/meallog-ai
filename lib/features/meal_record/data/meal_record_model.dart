import 'package:isar/isar.dart';

part 'meal_record_model.g.dart';

@collection
class MealRecord {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime date;

  late String mealType; // 'breakfast' | 'lunch' | 'dinner' | 'snack'
  late String dishName;
  List<String> ingredients = [];
  late DateTime createdAt;
}
