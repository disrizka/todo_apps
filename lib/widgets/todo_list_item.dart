import 'package:flutter/material.dart';
import '../models/todo_model.dart';
import 'status_badge.dart';

class TodoListItem extends StatelessWidget {
  final Todo todo;
  final VoidCallback onTap;

  const TodoListItem({super.key, required this.todo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          todo.todo ?? '(Tanpa judul)',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              StatusBadge(isCompleted: todo.completed ?? false),
              const SizedBox(width: 8),
              Text(
                'User #${todo.userId ?? '-'}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
