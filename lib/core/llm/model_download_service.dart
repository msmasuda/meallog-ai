import 'package:dio/dio.dart';

class ModelDownloadService {
  static const modelReadyPreferenceKey = 'model_ready_qwen3_5_0_8b_q4_k_m';

  static const kDefaultModelUrl =
      'https://huggingface.co/bartowski/Qwen_Qwen3.5-0.8B-GGUF/resolve/main/Qwen_Qwen3.5-0.8B-Q4_K_M.gguf';

  static const _modelFileName = 'qwen3.5-0.8b-q4_k_m.gguf';

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
