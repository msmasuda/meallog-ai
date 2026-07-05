import 'package:flutter_test/flutter_test.dart';
import 'package:meallog_ai/core/llm/model_download_service.dart';

void main() {
  test('kDefaultModelUrl is a non-empty HTTPS URL', () {
    expect(ModelDownloadService.kDefaultModelUrl, startsWith('https://'));
    expect(ModelDownloadService.kDefaultModelUrl, isNotEmpty);
  });

  test('modelFilePath returns a path ending with .gguf under given dir', () {
    final path = ModelDownloadService.modelFilePath('/docs');
    expect(path, startsWith('/docs/'));
    expect(path, endsWith('.gguf'));
  });
}
