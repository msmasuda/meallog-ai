import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meallog_ai/core/agent/agent_api_provider.dart';
import 'package:meallog_ai/core/config/app_environment.dart';

const _urlOverride = bool.hasEnvironment('AGENT_API_BASE_URL')
    ? String.fromEnvironment('AGENT_API_BASE_URL')
    : null;
const _tokenOverride = bool.hasEnvironment('AGENT_API_ACCESS_TOKEN')
    ? String.fromEnvironment('AGENT_API_ACCESS_TOKEN')
    : null;
const _modelOverride = bool.hasEnvironment('AGENT_VISION_MODEL')
    ? String.fromEnvironment('AGENT_VISION_MODEL')
    : null;

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    dotenv.clean();
    rootBundle.evict('.env');
  });

  tearDown(() {
    dotenv.clean();
    rootBundle.evict('.env');
    binding.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  });

  void serveEnv(String content) {
    binding.defaultBinaryMessenger.setMockMessageHandler('flutter/assets',
        (message) async {
      final path = utf8.decode(message!.buffer.asUint8List(
        message.offsetInBytes,
        message.lengthInBytes,
      ));
      expect(path, '.env');
      return ByteData.sublistView(Uint8List.fromList(utf8.encode(content)));
    });
  }

  test('startup loads .env asset settings without configuration flags',
      () async {
    serveEnv('''
AGENT_API_BASE_URL=http://agent.test:8000
AGENT_API_ACCESS_TOKEN=test-token
AGENT_VISION_MODEL=test-vision-model
''');

    await loadAppEnvironment();

    expect(agentApiBaseUrl, _urlOverride ?? 'http://agent.test:8000');
    expect(agentApiAccessToken, _tokenOverride ?? 'test-token');
    expect(agentVisionModel, _modelOverride ?? 'test-vision-model');
  });

  test('quoted settings are trimmed and optional values can be empty',
      () async {
    serveEnv('''
# Local development
AGENT_API_BASE_URL=" http://agent.test:9000 "
AGENT_API_ACCESS_TOKEN=
AGENT_VISION_MODEL=
''');

    await loadAppEnvironment();

    expect(agentApiBaseUrl, _urlOverride ?? 'http://agent.test:9000');
    expect(agentApiAccessToken, _tokenOverride ?? '');
    expect(agentVisionModel, _modelOverride ?? '');
  });

  test('missing settings use documented defaults', () async {
    serveEnv('# No agent settings\nOTHER_SETTING=value\n');

    await loadAppEnvironment();

    expect(agentApiBaseUrl, _urlOverride ?? 'http://localhost:8000');
    expect(agentApiAccessToken, _tokenOverride ?? '');
    expect(agentVisionModel, _modelOverride ?? '');
  });

  test('reloading settings does not retain the old endpoint', () async {
    serveEnv('AGENT_API_BASE_URL=http://first.test:8000\n');
    await loadAppEnvironment();
    expect(agentApiBaseUrl, _urlOverride ?? 'http://first.test:8000');

    rootBundle.evict('.env');
    serveEnv('AGENT_API_BASE_URL=http://second.test:8000\n');
    await loadAppEnvironment();
    expect(agentApiBaseUrl, _urlOverride ?? 'http://second.test:8000');
  });

  test('missing .env fails startup instead of silently ignoring it', () async {
    binding.defaultBinaryMessenger.setMockMessageHandler(
      'flutter/assets',
      (_) async => null,
    );

    await expectLater(loadAppEnvironment(), throwsA(isA<FileNotFoundError>()));
    expect(dotenv.isInitialized, isFalse);
  });
}
