import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_apps/models/todo_model.dart';

class LocalTodoStore {
  LocalTodoStore._();

  static const String _keyOverrides = 'local_todo_overrides';
  static const String _keyDeleted = 'local_todo_deleted_ids';
  static const String _keyLocalOnly = 'local_todo_local_only_ids'; 

  static Future<Map<int, Todo>> _getOverrides() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyOverrides);
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map(
      (key, value) => MapEntry(
        int.parse(key),
        Todo.fromJson(value as Map<String, dynamic>),
      ),
    );
  }

  static Future<void> _saveOverrides(Map<int, Todo> overrides) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      overrides.map((key, value) => MapEntry(key.toString(), value.toJson())),
    );
    await prefs.setString(_keyOverrides, encoded);
  }

  static Future<Set<int>> _getDeletedIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyDeleted) ?? [];
    return list.map(int.parse).toSet();
  }

  static Future<void> _saveDeletedIds(Set<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _keyDeleted,
      ids.map((e) => e.toString()).toList(),
    );
  }


  static Future<Set<int>> _getLocalOnlyIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyLocalOnly) ?? [];
    return list.map(int.parse).toSet();
  }

  static Future<void> _saveLocalOnlyIds(Set<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _keyLocalOnly,
      ids.map((e) => e.toString()).toList(),
    );
  }

  static Future<bool> isLocalOnly(int? id) async {
    if (id == null) return true;
    if (id > 100000) return true;

    final localOnly = await _getLocalOnlyIds();
    return localOnly.contains(id);
  }


  static Future<List<Todo>> mergeWithLocal(List<Todo> apiTodos) async {
    final overrides = await _getOverrides();
    final deletedIds = await _getDeletedIds();

    final result = <Todo>[];
    final seenIds = <int>{};

    for (final todo in apiTodos) {
      final id = todo.id;
      if (id != null && deletedIds.contains(id)) continue;
      if (id != null && overrides.containsKey(id)) {
        result.add(overrides[id]!);
      } else {
        result.add(todo);
      }
      if (id != null) seenIds.add(id);
    }


    for (final entry in overrides.entries) {
      if (!seenIds.contains(entry.key)) {
        result.insert(0, entry.value);
      }
    }

    return result;
  }

  static Future<Todo> saveLocal(Todo todo) async {
    final overrides = await _getOverrides();
    final isNewLocalTodo = todo.id == null;
    final id = todo.id ?? DateTime.now().millisecondsSinceEpoch;

    final saved = Todo(
      id: id,
      todo: todo.todo,
      completed: todo.completed,
      userId: todo.userId,
    );
    overrides[id] = saved;
    await _saveOverrides(overrides);


    if (isNewLocalTodo) {
      final localOnly = await _getLocalOnlyIds();
      localOnly.add(id);
      await _saveLocalOnlyIds(localOnly);
    }

    return saved;
  }

  static Future<void> deleteLocal(int id) async {
    final overrides = await _getOverrides();
    overrides.remove(id);
    await _saveOverrides(overrides);

    final deletedIds = await _getDeletedIds();
    deletedIds.add(id);
    await _saveDeletedIds(deletedIds);

    final localOnly = await _getLocalOnlyIds();
    localOnly.remove(id);
    await _saveLocalOnlyIds(localOnly);
  }
}
