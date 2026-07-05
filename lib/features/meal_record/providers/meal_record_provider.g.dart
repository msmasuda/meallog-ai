// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_record_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mealRecordRepoHash() => r'f40c5576b57a7f4ae4b0ef70a66c5b9c1d6d7686';

/// See also [mealRecordRepo].
@ProviderFor(mealRecordRepo)
final mealRecordRepoProvider = FutureProvider<MealRecordRepository>.internal(
  mealRecordRepo,
  name: r'mealRecordRepoProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$mealRecordRepoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MealRecordRepoRef = FutureProviderRef<MealRecordRepository>;
String _$recentMealsHash() => r'80c52773431217ef13daefc8e8f2b278037eb008';

/// See also [recentMeals].
@ProviderFor(recentMeals)
final recentMealsProvider = AutoDisposeFutureProvider<List<String>>.internal(
  recentMeals,
  name: r'recentMealsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$recentMealsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RecentMealsRef = AutoDisposeFutureProviderRef<List<String>>;
String _$historyNotifierHash() => r'2c9d237328549b45389c66fef799eef858cdefc0';

/// See also [HistoryNotifier].
@ProviderFor(HistoryNotifier)
final historyNotifierProvider = AutoDisposeAsyncNotifierProvider<
    HistoryNotifier, List<MealRecord>>.internal(
  HistoryNotifier.new,
  name: r'historyNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$historyNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$HistoryNotifier = AutoDisposeAsyncNotifier<List<MealRecord>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
