import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'agent_api_client.dart';

const agentApiBaseUrl = String.fromEnvironment(
  'AGENT_API_BASE_URL',
  defaultValue: 'http://192.168.100.32:8000',
);

const agentApiAccessToken = String.fromEnvironment('AGENT_API_ACCESS_TOKEN');

final agentSuggestionClientProvider = Provider<AgentSuggestionClient>((ref) {
  return LangGraphAgentClient(
    baseUrl: agentApiBaseUrl,
    accessToken: agentApiAccessToken,
  );
});
