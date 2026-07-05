// lib/core/router/app_router.dart  (STUB — replaced in Task 5)
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
Future<GoRouter> appRouter(AppRouterRef ref) async {
  return GoRouter(routes: []);
}
