import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'app_shell.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/history/screens/history_screen.dart';
import '../../features/meal_record/screens/meal_record_input_screen.dart';
import '../../features/suggestion/screens/suggestion_screen.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
Future<GoRouter> appRouter(AppRouterRef ref) async {
  return GoRouter(
    initialLocation: '/',
    routes: [
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
