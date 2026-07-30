import 'package:flutter/material.dart';
import 'package:todo_apps/models/todo_model.dart';
import 'package:todo_apps/pages/detail/detail_screen.dart';
import 'package:todo_apps/pages/form/todo_form_screen.dart';
import 'package:todo_apps/services/service.dart';
import 'package:todo_apps/widgets/custom_search_bar.dart';
import 'package:todo_apps/widgets/todo_list_item.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TodoApiService _apiService = TodoApiService();
  final TextEditingController _searchController = TextEditingController();

  List<Todo> _allTodos = [];
  List<Todo> _filteredTodos = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTodos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final todos = await _apiService.fetchTodos();
      setState(() {
        _allTodos = todos;
        _filteredTodos = todos;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _errorMessage = 'Gagal memuat data. Silakan coba lagi.';
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    final keyword = query.toLowerCase().trim();
    setState(() {
      _filteredTodos = keyword.isEmpty
          ? _allTodos
          : _allTodos
                .where(
                  (todo) => (todo.todo ?? '').toLowerCase().contains(keyword),
                )
                .toList();
    });
  }

  Future<void> _openDetail(Todo todo) async {
    final result = await Navigator.push<Object?>(
      context,
      MaterialPageRoute(builder: (_) => DetailScreen(todo: todo)),
    );

    if (result != null) {
      _loadTodos();
    }
  }

  Future<void> _openAddForm() async {
    final result = await Navigator.push<Todo?>(
      context,
      MaterialPageRoute(builder: (_) => const TodoFormScreen()),
    );

    if (result != null) {
      setState(() {
        _allTodos.insert(0, result);
        _filteredTodos = _allTodos;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomSearchBar(
            controller: _searchController,
            onChanged: _onSearchChanged,
          ),
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddForm,
        tooltip: 'Tambah Tugas',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_filteredTodos.isEmpty) {
      return Center(
        child: Text(
          'Belum ada tugas. Tambahkan tugas baru!',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTodos,
      child: ListView.builder(
        itemCount: _filteredTodos.length,
        itemBuilder: (context, index) {
          final todo = _filteredTodos[index];
          return TodoListItem(todo: todo, onTap: () => _openDetail(todo));
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 12),
          Text(_errorMessage!, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _loadTodos, child: const Text('Coba Lagi')),
        ],
      ),
    );
  }
}