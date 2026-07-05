import 'package:isar/isar.dart';

part 'suggestion_model.g.dart';

@collection
class Suggestion {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime targetDate;

  late String mealType;
  late String suggestedDish;
  String? feedback; // 'good' | 'bad' | null
  late DateTime createdAt;
}
