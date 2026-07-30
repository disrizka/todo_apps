import 'package:flutter/material.dart';
import 'package:todo_apps/models/todo_model.dart';
import 'package:todo_apps/pages/form/todo_form_screen.dart';
import 'package:todo_apps/services/service.dart';
import 'package:todo_apps/widgets/status_badge.dart';

class DetailScreen extends StatefulWidget {
  final Todo todo;

  const DetailScreen({super.key, required this.todo});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final TodoApiService _apiService = TodoApiService();
  late Todo _todo;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _todo = widget.todo;
  }

  Future<void> _editTodo() async {
    final updated = await Navigator.push<Todo?>(
      context,
      MaterialPageRoute(builder: (_) => TodoFormScreen(existingTodo: _todo)),
    );

    if (updated != null) {
      setState(() => _todo = updated);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Tugas'),
        content: Text('Yakin ingin menghapus "${_todo.todo ?? ''}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteTodo();
    }
  }

  Future<void> _deleteTodo() async {
    setState(() => _isDeleting = true);
    try {
      await _apiService.deleteTodo(_todo.id!);
      if (mounted) {
        Navigator.pop(context, 'deleted');
      }
    } catch (_) {
      setState(() => _isDeleting = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gagal menghapus tugas.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tugas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editTodo,
            tooltip: 'Edit',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _isDeleting ? null : _confirmDelete,
            tooltip: 'Hapus',
          ),
        ],
      ),
      body: _isDeleting
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _todo.todo ?? '(Tanpa judul)',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  StatusBadge(isCompleted: _todo.completed ?? false),
                  const SizedBox(height: 20),
                  _buildSectionTitle('ID Tugas'),
                  Text('#${_todo.id}', style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Dibuat oleh'),
                  Text(
                    'User ID ${_todo.userId ?? '-'}',
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}
