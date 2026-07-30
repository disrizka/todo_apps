import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:todo_apps/api/api.dart';
import 'package:todo_apps/models/todo_model.dart';
import 'package:todo_apps/services/local_todo.dart';

class TodoApiService {
  final http.Client _client;

  TodoApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Todo>> fetchTodos({int limit = 30}) async {
    final url = Uri.parse('${Endpoint.todosUrl}?limit=$limit');
    final response = await _client.get(url);

    if (response.statusCode == 200) {
      final todoResponse = TodoResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
      final apiTodos = todoResponse.todos ?? [];
      return LocalTodoStore.mergeWithLocal(apiTodos);
    }
    throw Exception(
      'Gagal mengambil data tugas (status: ${response.statusCode})',
    );
  }

  Future<Todo> addTodo(Todo todo) async {
    final url = Uri.parse('${Endpoint.todosUrl}/add');
    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(todo.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final apiTodo = Todo.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
      return LocalTodoStore.saveLocal(
        Todo(
          id: null,
          todo: apiTodo.todo,
          completed: apiTodo.completed,
          userId: apiTodo.userId,
        ),
      );
    }
    throw Exception('Gagal menambahkan tugas (status: ${response.statusCode})');
  }

  Future<Todo> updateTodo(Todo todo) async {
    if (await LocalTodoStore.isLocalOnly(todo.id)) {
      return LocalTodoStore.saveLocal(todo);
    }

    try {
      final url = Uri.parse('${Endpoint.todosUrl}/${todo.id}');
      final response = await _client.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(todo.toJson()),
      );

      if (response.statusCode == 200) {
        final apiTodo = Todo.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
        return LocalTodoStore.saveLocal(apiTodo);
      }
    } catch (_) {
    }


    return LocalTodoStore.saveLocal(todo);
  }

  Future<void> deleteTodo(int id) async {
    if (await LocalTodoStore.isLocalOnly(id)) {
      await LocalTodoStore.deleteLocal(id);
      return;
    }

    try {
      final url = Uri.parse('${Endpoint.todosUrl}/$id');
      final response = await _client.delete(url);

      if (response.statusCode == 200) {
        await LocalTodoStore.deleteLocal(id);
        return;
      }
    } catch (_) {
    }


    await LocalTodoStore.deleteLocal(id);
  }
}
