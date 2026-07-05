import 'package:dio/dio.dart';

class ModelDownloadService {
  static const kDefaultModelUrl =
      'https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF/resolve/main/qwen2.5-1.5b-instruct-q4_k_m.gguf';

  static const _modelFileName = 'qwen2.5-1.5b-instruct-q4_k_m.gguf';

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
