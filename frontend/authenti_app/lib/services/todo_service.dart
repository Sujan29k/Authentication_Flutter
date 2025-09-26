import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/secure_storage.dart';
import '../models/todo.dart';

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

  static Future<List<Todo>> getTodos() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No token found');

      print('Fetching todos from: $_base'); // Debug log

      final response = await http.get(
        Uri.parse(_base),
        headers: _getHeaders(token),
      );

      print(
        'Get todos response: ${response.statusCode} - ${response.body}',
      ); // Debug log

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Todo.fromMap(item)).toList();
      } else {
        throw Exception('Failed to load todos: ${response.statusCode}');
      }
    } catch (e) {
      print('Get todos error: $e'); // Debug log
      throw Exception('Network error: $e');
    }
  }

  static Future<Todo> addTodo(String title) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No token found');

      print('Adding todo: $title to $_base'); // Debug log

      final response = await http.post(
        Uri.parse(_base),
        headers: _getHeaders(token),
        body: jsonEncode({'title': title}),
      );

      print(
        'Add todo response: ${response.statusCode} - ${response.body}',
      ); // Debug log

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Todo.fromMap(data);
      } else {
        throw Exception('Failed to add todo: ${response.statusCode}');
      }
    } catch (e) {
      print('Add todo error: $e'); // Debug log
      throw Exception('Network error: $e');
    }
  }

  static Future<Todo> updateTodo(
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

      print('Updating todo $id: $body'); // Debug log

      final response = await http.put(
        Uri.parse('$_base/$id'),
        headers: _getHeaders(token),
        body: jsonEncode(body),
      );

      print(
        'Update todo response: ${response.statusCode} - ${response.body}',
      ); // Debug log

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Todo.fromMap(data);
      } else {
        throw Exception('Failed to update todo: ${response.statusCode}');
      }
    } catch (e) {
      print('Update todo error: $e'); // Debug log
      throw Exception('Network error: $e');
    }
  }

  static Future<void> deleteTodo(String id) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No token found');

      print('Deleting todo: $id'); // Debug log

      final response = await http.delete(
        Uri.parse('$_base/$id'),
        headers: _getHeaders(token),
      );

      print(
        'Delete todo response: ${response.statusCode} - ${response.body}',
      ); // Debug log

      if (response.statusCode != 200) {
        throw Exception('Failed to delete todo: ${response.statusCode}');
      }
    } catch (e) {
      print('Delete todo error: $e'); // Debug log
      throw Exception('Network error: $e');
    }
  }
}
