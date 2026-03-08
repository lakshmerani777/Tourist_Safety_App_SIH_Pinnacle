import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/api_config.dart';
import '../services/api_client.dart';
import '../services/session_storage_service.dart';

final sessionStorageServiceProvider = Provider<SessionStorageService>((ref) {
  return SessionStorageService();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final sessionStorage = ref.watch(sessionStorageServiceProvider);
  return ApiClient(
    baseUrl: kApiBaseUrl,
    sessionStorage: sessionStorage,
  );
});
