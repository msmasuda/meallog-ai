import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'agent_api_client.dart';
import 'vision_api_client.dart';

// main() loads the bundled .env before creating any providers. Explicit
// dart-defines remain optional overrides for existing build configurations.
String get agentApiBaseUrl => _setting(
      'AGENT_API_BASE_URL',
      const bool.hasEnvironment('AGENT_API_BASE_URL')
          ? const String.fromEnvironment('AGENT_API_BASE_URL')
          : null,
      fallback: 'http://localhost:8000',
    );

String get agentApiAccessToken => _setting(
      'AGENT_API_ACCESS_TOKEN',
      const bool.hasEnvironment('AGENT_API_ACCESS_TOKEN')
          ? const String.fromEnvironment('AGENT_API_ACCESS_TOKEN')
          : null,
    );

String get agentVisionModel => _setting(
      'AGENT_VISION_MODEL',
      const bool.hasEnvironment('AGENT_VISION_MODEL')
          ? const String.fromEnvironment('AGENT_VISION_MODEL')
          : null,
    );

String _setting(String key, String? override, {String fallback = ''}) {
  final value = override ?? (dotenv.isInitialized ? dotenv.env[key] : null);
  return value?.trim() ?? fallback;
}

final agentSuggestionClientProvider = Provider<AgentSuggestionClient>((ref) {
  return LangGraphAgentClient(
    baseUrl: agentApiBaseUrl,
    accessToken: agentApiAccessToken,
  );
});

final agentVisionClientProvider = Provider<VisionApiClient>((ref) {
  return LangGraphVisionApiClient(
    baseUrl: agentApiBaseUrl,
    accessToken: agentApiAccessToken,
  );
});
