import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../shared_prefs_provider.dart';
import '../llm/native_llm_bridge.dart';
import 'app_shell.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/history/screens/history_screen.dart';
import '../../features/meal_record/screens/meal_record_input_screen.dart';
import '../../features/model_setup/screens/model_setup_screen.dart';
import '../../features/suggestion/screens/suggestion_screen.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
Future<GoRouter> appRouter(AppRouterRef ref) async {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final prefs = await ref.read(sharedPrefsProvider.future);
      final modelReady = prefs.getBool('model_ready') ?? false;
      final systemModelSupported = await NativeLlmBridge().isSupported();
      if (!systemModelSupported &&
          !modelReady &&
          state.uri.path != '/model-setup') {
        return '/model-setup';
      }
      if (systemModelSupported && state.uri.path == '/model-setup') {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/model-setup',
        builder: (context, state) => const ModelSetupScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          GoRoute(
              path: '/history',
              builder: (context, state) => const HistoryScreen()),
          GoRoute(
              path: '/record/add',
              builder: (context, state) => const MealRecordInputScreen()),
          GoRoute(
              path: '/suggestion',
              builder: (context, state) => const SuggestionScreen()),
        ],
      ),
    ],
  );
}
