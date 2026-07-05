import 'package:isar/isar.dart';
import '../../features/meal_record/data/meal_record_model.dart';
import '../../features/suggestion/data/suggestion_model.dart';

class IsarService {
  static Future<Isar> init(String directory) => Isar.open(
        [MealRecordSchema, SuggestionSchema],
        directory: directory,
        name: 'meallog',
      );
}
