import 'dart:convert';

import 'package:http/http.dart' as http;

import 'session_storage_service.dart';

/// Response from successful registration.
class RegisterResponse {
  RegisterResponse({
    required this.sessionId,
    required this.fullName,
    required this.email,
  });

  final String sessionId;
  final String fullName;
  final String email;

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    return RegisterResponse(
      sessionId: json['session_id'] as String? ?? '',
      fullName: user['full_name'] as String? ?? '',
      email: user['email'] as String? ?? '',
    );
  }
}

/// Thrown when the server returns an error (e.g. 400 validation).
class ApiException implements Exception {
  ApiException(this.message, [this.statusCode]);
  final String message;
  final int? statusCode;
  @override
  String toString() => message;
}

/// HTTP client for the Django backend. Sends X-Session-Id when available.
class ApiClient {
  ApiClient({
    required this.baseUrl,
    required SessionStorageService sessionStorage,
  }) : _sessionStorage = sessionStorage;

  final String baseUrl;
  final SessionStorageService _sessionStorage;

  static const _sessionHeader = 'X-Session-Id';

  /// Returns headers for JSON requests, including session ID if stored.
  Future<Map<String, String>> _headers({bool includeSession = true}) async {
    final map = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (includeSession) {
      final sessionId = await _sessionStorage.getSessionId();
      if (sessionId != null && sessionId.isNotEmpty) {
        map[_sessionHeader] = sessionId;
      }
    }
    return map;
  }

  /// POST /api/auth/register/ with full_name, email, password.
  /// Returns [RegisterResponse] on success; throws [ApiException] on 4xx/5xx.
  Future<RegisterResponse> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/api/auth/register/');
    final body = jsonEncode({
      'full_name': fullName,
      'email': email,
      'password': password,
    });
    final response = await http.post(
      uri,
      headers: await _headers(includeSession: false),
      body: body,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return RegisterResponse.fromJson(data);
    }

    String message = 'Registration failed.';
    if (response.body.isNotEmpty) {
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['error'] != null) {
          message = data['error'] as String;
        }
      } catch (_) {}
    }
    throw ApiException(message, response.statusCode);
  }

  /// POST /api/auth/logout/ — invalidates the current session.
  Future<void> logout() async {
    final uri = Uri.parse('$baseUrl/api/auth/logout/');
    await http.post(uri, headers: await _headers());
    await _sessionStorage.clearSessionId();
  }

  /// GET /api/auth/me/ — returns the current user info.
  Future<Map<String, dynamic>> getProfile() async {
    final uri = Uri.parse('$baseUrl/api/auth/me/');
    final response = await http.get(uri, headers: await _headers());
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw ApiException('Failed to load profile.', response.statusCode);
  }

  /// POST /api/onboarding/ — saves tourist profile data to the backend.
  Future<void> submitOnboarding(Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl/api/onboarding/');
    final response = await http.post(
      uri,
      headers: await _headers(),
      body: jsonEncode(data),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Failed to save profile.';
      try {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['error'] != null) message = body['error'] as String;
      } catch (_) {}
      throw ApiException(message, response.statusCode);
    }
  }

  /// POST /api/sos/ — triggers an SOS alert.
  Future<void> triggerSOS({
    required double latitude,
    required double longitude,
    required String address,
    required String touristName,
    String nationality = '',
  }) async {
    final uri = Uri.parse('$baseUrl/api/sos/');
    final response = await http.post(
      uri,
      headers: await _headers(),
      body: jsonEncode({
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'tourist_name': touristName,
        'nationality': nationality,
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('SOS trigger failed.', response.statusCode);
    }
  }

  /// POST /api/auth/signin/ with email, password.
  /// Returns [RegisterResponse] (session_id + user) on success; throws [ApiException] on 4xx/5xx.
  Future<RegisterResponse> signIn({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/api/auth/signin/');
    final body = jsonEncode({
      'email': email,
      'password': password,
    });
    final response = await http.post(
      uri,
      headers: await _headers(includeSession: false),
      body: body,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return RegisterResponse.fromJson(data);
    }

    String message = 'Sign in failed.';
    if (response.body.isNotEmpty) {
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['error'] != null) {
          message = data['error'] as String;
        }
      } catch (_) {}
    }
    throw ApiException(message, response.statusCode);
  }
}
