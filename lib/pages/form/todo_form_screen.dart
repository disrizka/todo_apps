import 'package:flutter/material.dart';
import '../../models/todo_model.dart';
import '../../services/service.dart';

/// Halaman form untuk menambah tugas baru atau mengedit tugas yang
/// sudah ada. Satu widget dipakai untuk kedua mode (tambah & edit)
/// agar kode tidak duplikat (DRY).
class TodoFormScreen extends StatefulWidget {
  /// Jika null -> mode tambah tugas baru.
  /// Jika terisi -> mode edit tugas yang sudah ada.
  final TodoModel? existingTodo;

  const TodoFormScreen({super.key, this.existingTodo});

  bool get isEditMode => existingTodo != null;

  @override
  State<TodoFormScreen> createState() => _TodoFormScreenState();
}

class _TodoFormScreenState extends State<TodoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TodoApiService _apiService = TodoApiService();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  DateTime? _selectedDeadline;
  bool _isCompleted = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final todo = widget.existingTodo;
    _titleController = TextEditingController(text: todo?.title ?? '');
    _descriptionController = TextEditingController(text: todo?.description ?? '');
    _selectedDeadline = todo?.deadline;
    _isCompleted = todo?.isCompleted ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Menampilkan date picker untuk memilih tanggal deadline.
  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      setState(() => _selectedDeadline = picked);
    }
  }

  /// Memvalidasi form lalu menyimpan data (create atau update) ke API.
  Future<void> _saveTodo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final newTodo = TodoModel(
      id: widget.existingTodo?.id ?? DateTime.now().millisecondsSinceEpoch,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      deadline: _selectedDeadline,
      isCompleted: _isCompleted,
    );

    try {
      final TodoModel savedTodo = widget.isEditMode
          ? await _apiService.updateTodo(newTodo)
          : await _apiService.addTodo(newTodo);

      // DummyJSON tidak menyimpan field description & deadline,
      // sehingga digabungkan kembali dengan data lokal supaya
      // tetap tampil di aplikasi (simulasi penyimpanan lokal).
      final mergedTodo = savedTodo.copyWith(
        description: newTodo.description,
        deadline: newTodo.deadline,
      );

      if (mounted) {
        Navigator.pop(context, mergedTodo);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan tugas: $e')),
        );
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
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            _buildDeadlinePicker(),
            const SizedBox(height: 8),
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

  Widget _buildDeadlinePicker() {
    final label = _selectedDeadline != null
        ? '${_selectedDeadline!.day.toString().padLeft(2, '0')}/'
            '${_selectedDeadline!.month.toString().padLeft(2, '0')}/'
            '${_selectedDeadline!.year}'
        : 'Pilih tanggal deadline';

    return InkWell(
      onTap: _pickDeadline,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Tanggal Deadline',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(label),
      ),
    );
  }
}
