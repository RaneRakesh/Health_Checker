import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService({String? baseUrl}) : baseUrl = baseUrl ?? defaultBaseUrl;

  /// Default port for backend API. Can be overridden via --dart-define=BACKEND_PORT=xxxx
  static const int port = int.fromEnvironment('BACKEND_PORT', defaultValue: 8001);

  /// Selects the appropriate backend URL based on platform.
  /// On Web/Desktop: localhost:8001
  /// On Android Emulator: 10.0.2.2:8001
  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:$port';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:$port';
    }
    return 'http://localhost:$port';
  }

  Future<http.Response> getProfile(String userId) async {
    final uri = Uri.parse('$baseUrl/profile/$userId');
    return await http.get(uri);
  }

  Future<http.Response> upsertProfile(Map<String, dynamic> profileJson) async {
    final uri = Uri.parse('$baseUrl/profile');
    return await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(profileJson),
    );
  }

  Future<http.Response> sendChat(String userId, String message, {String? mode}) async {
    final uri = Uri.parse('$baseUrl/chat');
    final Map<String, dynamic> body = {'user_id': userId, 'message': message};
    if (mode != null) {
      body['mode'] = mode;
    }
    return await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
  }
}
