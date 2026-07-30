import 'package:flutter/material.dart';
import 'package:todo_apps/models/todo_model.dart';
import 'package:todo_apps/services/pref_handler.dart';
import 'package:todo_apps/services/service.dart';

class TodoFormScreen extends StatefulWidget {
  final Todo? existingTodo;

  const TodoFormScreen({super.key, this.existingTodo});

  bool get isEditMode => existingTodo != null;

  @override
  State<TodoFormScreen> createState() => _TodoFormScreenState();
}

class _TodoFormScreenState extends State<TodoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TodoApiService _apiService = TodoApiService();

  late final TextEditingController _titleController;
  bool _isCompleted = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final todo = widget.existingTodo;
    _titleController = TextEditingController(text: todo?.todo ?? '');
    _isCompleted = todo?.completed ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _saveTodo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final loggedInId = await PreferenceHandler.getId() ?? 1;

    final newTodo = Todo(
      id: widget.existingTodo?.id,
      todo: _titleController.text.trim(),
      completed: _isCompleted,
      userId: widget.existingTodo?.userId ?? loggedInId,
    );

    try {
      final Todo savedTodo = widget.isEditMode
          ? await _apiService.updateTodo(newTodo)
          : await _apiService.addTodo(newTodo);

      if (mounted) {
        Navigator.pop(context, savedTodo);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan tugas: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditMode ? 'Edit Tugas' : 'Tambah Tugas'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul Tugas',
                border: OutlineInputBorder(),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Judul wajib diisi'
                  : null,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Sudah Selesai'),
              value: _isCompleted,
              onChanged: (value) => setState(() => _isCompleted = value),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveTodo,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Simpan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
