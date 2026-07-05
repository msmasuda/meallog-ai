// lib/features/suggestion/data/suggestion_repository.dart
import 'package:isar/isar.dart';
import 'suggestion_model.dart';

class SuggestionRepository {
  SuggestionRepository(this._isar);
  final Isar _isar;

  Future<void> save(Suggestion suggestion) =>
      _isar.writeTxn(() => _isar.suggestions.put(suggestion));

  Future<void> saveFeedback(Id id, String feedback) async {
    await _isar.writeTxn(() async {
      final s = await _isar.suggestions.get(id);
      if (s == null) return;
      s.feedback = feedback;
      await _isar.suggestions.put(s);
    });
  }
}
