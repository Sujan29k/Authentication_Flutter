import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/secure_storage.dart';
import '../models/item.dart';

class TodoService {
  static String get _base => ApiConfig.itemsBaseUrl;

  static Future<String?> _getToken() async {
    return await SecureStorage.getToken();
  }

  static Map<String, String> _getHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<List<Item>> getTodos() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No token found');

      final response = await http.get(
        Uri.parse(_base),
        headers: _getHeaders(token),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Item.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load todos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Item> addTodo(String title) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No token found');

      final response = await http.post(
        Uri.parse(_base),
        headers: _getHeaders(token),
        body: jsonEncode({'title': title}),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Item.fromJson(data);
      } else {
        throw Exception('Failed to add todo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Item> updateTodo(
    String id, {
    String? title,
    bool? isDone,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No token found');

      final body = <String, dynamic>{};
      if (title != null) body['title'] = title;
      if (isDone != null) body['isDone'] = isDone;

      final response = await http.put(
        Uri.parse('$_base/$id'),
        headers: _getHeaders(token),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Item.fromJson(data);
      } else {
        throw Exception('Failed to update todo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<void> deleteTodo(String id) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No token found');

      final response = await http.delete(
        Uri.parse('$_base/$id'),
        headers: _getHeaders(token),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete todo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
