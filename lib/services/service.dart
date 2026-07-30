import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:todo_apps/api/api.dart';
import 'package:todo_apps/models/todo_model.dart';

class TodoApiService {
  final http.Client _client;

  TodoApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<TodoModel>> fetchTodos({int limit = 30}) async {
    final url = Uri.parse('${Endpoint.baseUrl}?limit=$limit');
    final response = await _client.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> todosJson = data['todos'] as List<dynamic>;
      return todosJson
          .map((json) => TodoModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    throw Exception(
      'Gagal mengambil data tugas (status: ${response.statusCode})',
    );
  }

  Future<TodoModel> addTodo(TodoModel todo) async {
    final url = Uri.parse('${Endpoint.baseUrl}/add');
    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(todo.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return TodoModel.fromJson(json);
    }
    throw Exception('Gagal menambahkan tugas (status: ${response.statusCode})');
  }

  Future<TodoModel> updateTodo(TodoModel todo) async {
    final url = Uri.parse('${Endpoint.baseUrl}/${todo.id}');
    final response = await _client.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(todo.toJson()),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return TodoModel.fromJson(json);
    }
    throw Exception('Gagal memperbarui tugas (status: ${response.statusCode})');
  }

  Future<void> deleteTodo(int id) async {
    final url = Uri.parse('${Endpoint.baseUrl}/$id');
    final response = await _client.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus tugas (status: ${response.statusCode})');
    }
  }
}
