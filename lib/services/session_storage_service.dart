import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _sessionIdKey = 'auth_session_id';

/// Persists and retrieves the auth session ID in secure storage.
class SessionStorageService {
  SessionStorageService() : _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  final FlutterSecureStorage _storage;

  Future<void> saveSessionId(String sessionId) async {
    await _storage.write(key: _sessionIdKey, value: sessionId);
  }

  Future<String?> getSessionId() async {
    return _storage.read(key: _sessionIdKey);
  }

  Future<void> clearSessionId() async {
    await _storage.delete(key: _sessionIdKey);
  }
}
