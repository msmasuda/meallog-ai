import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'model_download_service.dart';

part 'model_download_provider.g.dart';

@riverpod
class ModelDownloadNotifier extends _$ModelDownloadNotifier {
  String? _error;
  String? get error => _error;

  @override
  double build() => 0.0;

  Future<void> startDownload() async {
    if (state > 0 && state < 1.0) return; // guard against double-invocation
    _error = null;
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final savePath = ModelDownloadService.modelFilePath(docsDir.path);
      final file = File(savePath);
      if (await file.exists()) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(
          ModelDownloadService.modelReadyPreferenceKey,
          true,
        );
        state = 1.0;
        return;
      }
      await ModelDownloadService.download(
        url: ModelDownloadService.kDefaultModelUrl,
        savePath: savePath,
        onProgress: (p) {
          if (p < 1.0) state = p;
        },
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(
        ModelDownloadService.modelReadyPreferenceKey,
        true,
      );
      state = 1.0;
    } catch (e) {
      _error = e.toString();
      state = -1.0; // sentinel value indicating error
    }
  }
}
