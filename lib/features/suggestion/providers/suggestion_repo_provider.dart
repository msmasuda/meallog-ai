import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/db/isar_provider.dart';
import '../data/suggestion_repository.dart';

part 'suggestion_repo_provider.g.dart';

@Riverpod(keepAlive: true)
Future<SuggestionRepository> suggestionRepo(SuggestionRepoRef ref) async {
  final isar = await ref.watch(isarProvider.future);
  return SuggestionRepository(isar);
}
