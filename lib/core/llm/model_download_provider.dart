import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'model_download_service.dart';

part 'model_download_provider.g.dart';

@riverpod
class ModelDownloadNotifier extends _$ModelDownloadNotifier {
  @override
  double build() => 0.0;

  Future<void> startDownload() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final savePath = ModelDownloadService.modelFilePath(docsDir.path);
    await ModelDownloadService.download(
      url: ModelDownloadService.kDefaultModelUrl,
      savePath: savePath,
      onProgress: (p) => state = p,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('model_ready', true);
    state = 1.0;
  }
}
