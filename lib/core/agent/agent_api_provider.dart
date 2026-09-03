import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'agent_api_client.dart';
import 'vision_api_client.dart';

// Load local settings with flutter run --dart-define-from-file=.env.
// Physical devices must use the agent host's LAN address, not localhost.
const agentApiBaseUrl = String.fromEnvironment(
  'AGENT_API_BASE_URL',
  defaultValue: 'http://localhost:8000',
);

const agentApiAccessToken = String.fromEnvironment('AGENT_API_ACCESS_TOKEN');

const agentVisionModel = String.fromEnvironment('AGENT_VISION_MODEL');

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
