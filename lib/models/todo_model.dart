// To parse this JSON data, do
//
//     final todoResponse = todoResponseFromJson(jsonString);

import 'dart:convert';

TodoResponse todoResponseFromJson(String str) =>
    TodoResponse.fromJson(json.decode(str));

String todoResponseToJson(TodoResponse data) => json.encode(data.toJson());

class TodoResponse {
  final List<Todo>? todos;
  final int? total;
  final int? skip;
  final int? limit;

  TodoResponse({this.todos, this.total, this.skip, this.limit});

  factory TodoResponse.fromJson(Map<String, dynamic> json) => TodoResponse(
    todos: json["todos"] == null
        ? []
        : List<Todo>.from(json["todos"]!.map((x) => Todo.fromJson(x))),
    total: json["total"],
    skip: json["skip"],
    limit: json["limit"],
  );

  Map<String, dynamic> toJson() => {
    "todos": todos == null
        ? []
        : List<dynamic>.from(todos!.map((x) => x.toJson())),
    "total": total,
    "skip": skip,
    "limit": limit,
  };
}

class Todo {
  final int? id;
  final String? todo;
  final bool? completed;
  final int? userId;

  Todo({this.id, this.todo, this.completed, this.userId});

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
    id: json["id"],
    todo: json["todo"],
    completed: json["completed"],
    userId: json["userId"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "todo": todo,
    "completed": completed,
    "userId": userId,
  };
}
