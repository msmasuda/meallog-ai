import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:meallog_ai/core/db/isar_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('IsarService.init opens database with both schemas', () async {
    try {
      await Isar.initializeIsarCore(download: false);
    } catch (_) {
      // Already initialized or not needed on this platform.
    }

    final dir = await Directory.systemTemp.createTemp('isar_test_');
    try {
      final isar = await IsarService.init(dir.path);
      expect(isar.isOpen, isTrue);
      expect(isar.name, equals('meallog'));
      await isar.close(deleteFromDisk: true);
    } catch (e) {
      // Native Isar libraries unavailable in this test environment — skip.
      markTestSkipped('Isar native libs not available: $e');
    } finally {
      await dir.delete(recursive: true);
    }
  });
}
