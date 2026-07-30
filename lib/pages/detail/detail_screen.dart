import 'package:flutter/material.dart';
import '../../models/todo_model.dart';
import '../../services/service.dart';
import '../../widgets/status_badge.dart';
import '../form/todo_form_screen.dart';

/// Halaman detail: menampilkan informasi lengkap satu tugas
/// (judul, deskripsi, status, tanggal deadline), serta tombol
/// untuk mengedit atau menghapus tugas tersebut.
class DetailScreen extends StatefulWidget {
  final TodoModel todo;

  const DetailScreen({super.key, required this.todo});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final TodoApiService _apiService = TodoApiService();
  late TodoModel _todo;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _todo = widget.todo;
  }

  /// Membuka form edit dan memperbarui tampilan jika ada perubahan data.
  Future<void> _editTodo() async {
    final updated = await Navigator.push<TodoModel?>(
      context,
      MaterialPageRoute(builder: (_) => TodoFormScreen(existingTodo: _todo)),
    );

    if (updated != null) {
      setState(() => _todo = updated);
    }
  }

  /// Menampilkan dialog konfirmasi sebelum menghapus tugas.
  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Tugas'),
        content: Text('Yakin ingin menghapus "${_todo.title}"?'),
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
      await _apiService.deleteTodo(_todo.id);
      if (mounted) {
        Navigator.pop(context, 'deleted');
      }
    } catch (_) {
      setState(() => _isDeleting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghapus tugas.')),
        );
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
                    _todo.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  StatusBadge(isCompleted: _todo.isCompleted),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Deskripsi'),
                  Text(
                    _todo.description.isEmpty
                        ? '- Tidak ada deskripsi -'
                        : _todo.description,
                    style: const TextStyle(fontSize: 15, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Tanggal Deadline'),
                  Text(
                    _todo.deadline != null
                        ? _formatDate(_todo.deadline!)
                        : '- Belum ditentukan -',
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
