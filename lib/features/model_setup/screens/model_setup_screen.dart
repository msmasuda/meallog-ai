import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/llm/model_download_provider.dart';

class ModelSetupScreen extends ConsumerStatefulWidget {
  const ModelSetupScreen({super.key});

  @override
  ConsumerState<ModelSetupScreen> createState() => _ModelSetupScreenState();
}

class _ModelSetupScreenState extends ConsumerState<ModelSetupScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(modelDownloadNotifierProvider.notifier).startDownload();
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(modelDownloadNotifierProvider);
    final notifier = ref.read(modelDownloadNotifierProvider.notifier);

    // Navigate on completion
    ref.listen(modelDownloadNotifierProvider, (prev, next) {
      if (next == 1.0 && context.mounted) context.go('/');
    });

    if (progress == -1.0) {
      // Error state
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'ダウンロードに失敗しました\n${notifier.error ?? ""}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => notifier.startDownload(),
                  child: const Text('再試行'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('AIモデルを準備しています...', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 24),
              LinearProgressIndicator(value: progress > 0 && progress < 1.0 ? progress : null),
              const SizedBox(height: 12),
              Text('${(progress.clamp(0.0, 1.0) * 100).toStringAsFixed(0)}%'),
            ],
          ),
        ),
      ),
    );
  }
}
