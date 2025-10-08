import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/secure_storage.dart';
import '../config/api_config.dart';

class ApiService {
  static String get baseUrl => ApiConfig.baseUrl + '/api';

  static Future<Map<String, String>> _authHeaders() async {
    final token = await SecureStorage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> get(String path) async {
    final headers = await _authHeaders();
    return http.get(Uri.parse('$baseUrl$path'), headers: headers);
  }

  static Future<http.Response> post(String path, Map body) async {
    final headers = await _authHeaders();
    return http.post(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> put(String path, Map body) async {
    final headers = await _authHeaders();
    return http.put(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> delete(String path) async {
    final headers = await _authHeaders();
    return http.delete(Uri.parse('$baseUrl$path'), headers: headers);
  }

  // Debug method to check token storage
  static Future<void> debugTokenStatus() async {
    final token = await SecureStorage.getToken();
    print('=== TOKEN DEBUG ===');
    print('Token exists: ${token != null}');
    if (token != null) {
      print('Token length: ${token.length}');
      print('Token preview: ${token.substring(0, 20)}...');
    } else {
      print('No token found in storage');
    }
    print('==================');
  }
}
