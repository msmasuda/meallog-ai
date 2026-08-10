import 'package:flutter_test/flutter_test.dart';
import 'package:meallog_ai/core/llm/model_download_service.dart';

void main() {
  test('kDefaultModelUrl is a non-empty HTTPS URL', () {
    expect(ModelDownloadService.kDefaultModelUrl, startsWith('https://'));
    expect(ModelDownloadService.kDefaultModelUrl, isNotEmpty);
    expect(ModelDownloadService.kDefaultModelUrl, contains('Qwen3.5-0.8B'));
    expect(ModelDownloadService.kDefaultModelUrl, contains('Q4_K_M'));
  });

  test('readiness key is specific to the current model', () {
    expect(
      ModelDownloadService.modelReadyPreferenceKey,
      contains('qwen3_5_0_8b_q4_k_m'),
    );
  });

  test('modelFilePath returns a path ending with .gguf under given dir', () {
    final path = ModelDownloadService.modelFilePath('/docs');
    expect(path, startsWith('/docs/'));
    expect(path, endsWith('.gguf'));
  });
}
