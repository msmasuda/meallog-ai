import 'package:dio/dio.dart';

class ModelDownloadService {
  static const kDefaultModelUrl =
      'https://huggingface.co/bartowski/gemma-3-1b-it-GGUF/resolve/main/gemma-3-1b-it-Q4_K_M.gguf';

  static const _modelFileName = 'gemma-3-1b-it-Q4_K_M.gguf';

  static String modelFilePath(String docsDir) => '$docsDir/$_modelFileName';

  static Future<void> download({
    required String url,
    required String savePath,
    required void Function(double progress) onProgress,
    Dio? dio,
  }) async {
    final client = dio ?? Dio();
    await client.download(
      url,
      savePath,
      onReceiveProgress: (received, total) {
        if (total > 0) onProgress(received / total);
      },
    );
  }
}
