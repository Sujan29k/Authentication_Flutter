import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/secure_storage.dart';

class AuthService {
  static String get _base => ApiConfig.authBaseUrl;

  static Future<Map?> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$_base/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      await SecureStorage.saveToken(body['token']);
      return body['user'];
    }
    return null;
  }

  static Future<bool> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      return res.statusCode == 201;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<void> logout() async {
    await SecureStorage.deleteToken();
  }
}
