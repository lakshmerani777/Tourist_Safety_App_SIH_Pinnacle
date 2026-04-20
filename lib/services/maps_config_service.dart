import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import 'session_storage_service.dart';

/// Fetches the Google Maps API key from the backend and applies it on the
/// platform (iOS: via method channel; Android: key comes from manifest at build).
class MapsConfigService {
  MapsConfigService({String? baseUrl, SessionStorageService? sessionStorage})
      : _baseUrl = baseUrl ?? kApiBaseUrl,
        _sessionStorage = sessionStorage;

  final String _baseUrl;
  final SessionStorageService? _sessionStorage;
  static String? _cachedKey;

  static const _channel = MethodChannel('tourist_safety_app/maps_config');
  static const _sessionHeader = 'X-Session-Id';

  /// Fetches the Maps API key from the backend and caches it.
  /// Returns the key, or null if the request fails or key is empty.
  Future<String?> fetchMapsApiKey() async {
    if (_cachedKey != null) return _cachedKey;
    try {
      final uri = Uri.parse('$_baseUrl/api/config/maps-key/');
      final headers = <String, String>{};
      if (_sessionStorage != null) {
        final sessionId = await _sessionStorage.getSessionId();
        if (sessionId != null && sessionId.isNotEmpty) {
          headers[_sessionHeader] = sessionId;
        }
      }
      final response = await http.get(uri, headers: headers).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Maps config request timeout'),
      );
      if (response.statusCode != 200) return null;
      final body = _parseJson(response.body);
      final key = body?['mapsApiKey'] as String?;
      if (key != null && key.isNotEmpty) {
        _cachedKey = key;
        return key;
      }
    } catch (_) {
      // Ignore: app can still work; map may fail on iOS if key was never set
    }
    return null;
  }

  /// Fetches the key from the backend and applies it on the native side.
  /// On iOS this calls GMSServices.provideAPIKey via method channel.
  /// On Android the key is read from the manifest at build time; this is a no-op.
  Future<void> fetchAndApplyMapsApiKey() async {
    final key = await fetchMapsApiKey();
    if (key == null || key.isEmpty) return;
    await applyMapsApiKeyOnPlatform(key);
  }

  /// Sends the Maps API key to the native side. Only needed on iOS (Android uses manifest).
  Future<void> applyMapsApiKeyOnPlatform(String key) async {
    if (!Platform.isIOS) return;
    try {
      await _channel.invokeMethod<void>('setMapsApiKey', {'apiKey': key});
    } on MissingPluginException {
      // Runner may not have registered the channel yet
    } on PlatformException {
      // Ignore
    }
  }

  static Map<String, dynamic>? _parseJson(String raw) {
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }
}
