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
      ref.read(modelDownloadNotifierProvider.notifier).startDownload().then((_) {
        if (mounted) context.go('/');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(modelDownloadNotifierProvider);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('AIモデルを準備しています...', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 24),
              LinearProgressIndicator(value: progress > 0 ? progress : null),
              const SizedBox(height: 12),
              Text('${(progress * 100).toStringAsFixed(0)}%'),
            ],
          ),
        ),
      ),
    );
  }
}
