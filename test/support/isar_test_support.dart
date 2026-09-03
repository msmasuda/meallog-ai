import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:meallog_ai/core/db/isar_service.dart';

/// Loads the host binary already installed by `flutter pub get`.
/// Flutter unit tests do not bundle native plugins like the device app does.
Future<void> initializeTestIsar() async {
  // Isolate.resolvePackageUri is unavailable in Flutter's test runtime.
  // Resolve the root from pub's package configuration instead of assuming
  // a machine-specific cache path or a particular package version.
  final configFile = File('.dart_tool/package_config.json').absolute;
  final config =
      jsonDecode(await configFile.readAsString()) as Map<String, dynamic>;
  final packages = (config['packages'] as List).cast<Map<String, dynamic>>();
  final matches = packages.where((p) => p['name'] == 'isar_flutter_libs');
  if (matches.isEmpty) {
    throw StateError(
      'isar_flutter_libsが見つかりません。flutter pub getを実行してください。',
    );
  }
  final packageRoot = Directory.fromUri(
    configFile.uri.resolve(matches.single['rootUri'] as String),
  ).uri;

  final abi = Abi.current();
  final relativePath = switch (abi) {
    Abi.macosArm64 || Abi.macosX64 => 'macos/libisar.dylib',
    Abi.linuxX64 => 'linux/libisar.so',
    Abi.windowsX64 => 'windows/isar.dll',
    _ => throw UnsupportedError('DBテスト用のIsarバイナリが未対応の環境です: $abi'),
  };
  final library = File.fromUri(packageRoot.resolve(relativePath));
  if (!await library.exists()) {
    throw StateError('DBテスト用のIsarバイナリが見つかりません: ${library.path}');
  }

  // Do not download or suppress load/version errors. Missing or incompatible
  // binaries must fail the suite, just like a database or assertion failure.
  await Isar.initializeIsarCore(
    libraries: {abi: library.path},
    download: false,
  );
}

/// Opens a real, isolated database and cleans it up even when a test fails.
Future<Isar> openTestIsar() async {
  final directory = await Directory.systemTemp.createTemp('meallog_isar_test_');
  Isar? isar;
  addTearDown(() async {
    try {
      if (isar?.isOpen ?? false) {
        await isar!.close(deleteFromDisk: true);
      }
    } finally {
      await directory.delete(recursive: true);
    }
  });

  isar = await IsarService.init(directory.path);
  return isar;
}
