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
}
