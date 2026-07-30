// To parse this JSON data, do
//
//     final todoModel = todoModelFromJson(jsonString);

import 'dart:convert';

TodoModel todoModelFromJson(String str) => TodoModel.fromJson(json.decode(str));

String todoModelToJson(TodoModel data) => json.encode(data.toJson());

class TodoModel {
  final List<Todo>? todos;
  final int? total;
  final int? skip;
  final int? limit;

  TodoModel({this.todos, this.total, this.skip, this.limit});

  factory TodoModel.fromJson(Map<String, dynamic> json) => TodoModel(
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
