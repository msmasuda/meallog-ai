// lib/core/llm/llm_provider.dart
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'llm_service.dart';
import 'model_download_service.dart';

part 'llm_provider.g.dart';

@Riverpod(keepAlive: true)
class LlmServiceNotifier extends _$LlmServiceNotifier {
  @override
  Future<LlmService> build() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final modelPath = ModelDownloadService.modelFilePath(docsDir.path);
    final service = LlmService();
    await service.loadModel(modelPath);
    ref.onDispose(service.dispose);
    return service;
  }
}
