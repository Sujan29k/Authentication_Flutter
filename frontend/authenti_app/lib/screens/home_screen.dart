import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/todo.dart';
import '../services/todo_service.dart';
import '../services/api_service.dart';
import '../widgets/todo_tile.dart';
import 'todo_edit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Todo> _todos = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkTokenAndLoadTodos();
  }

  Future<void> _checkTokenAndLoadTodos() async {
    // Debug: Check if token is stored
    await ApiService.debugTokenStatus();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final todos = await TodoService.getTodos();
      setState(() {
        _todos = todos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addTodo() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const TodoEditScreen()),
    );

    if (result == true) {
      _loadTodos(); // Refresh the list
    }
  }

  Future<void> _editTodo(Todo todo) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => TodoEditScreen(todo: todo)),
    );

    if (result == true) {
      _loadTodos(); // Refresh the list
    }
  }

  Future<void> _toggleTodo(Todo todo, bool? isDone) async {
    try {
      await TodoService.updateTodo(todo.id, isDone: isDone ?? false);
      _loadTodos(); // Refresh the list
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating todo: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteTodo(Todo todo) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Todo'),
        content: Text('Are you sure you want to delete "${todo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await TodoService.deleteTodo(todo.id);
        _loadTodos(); // Refresh the list
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Todo deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting todo: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Todos'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () async {
              await ApiService.debugTokenStatus();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Check debug console for token info'),
                ),
              );
            },
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadTodos),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true && context.mounted) {
                await context.read<AuthProvider>().logout();
              }
            },
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading your todos...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading todos',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadTodos, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_todos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No todos yet!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Tap the + button to add your first todo',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Show completed and pending todos separately
    final pendingTodos = _todos.where((todo) => !todo.isDone).toList();
    final completedTodos = _todos.where((todo) => todo.isDone).toList();

    return RefreshIndicator(
      onRefresh: _loadTodos,
      child: ListView(
        children: [
          if (pendingTodos.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Pending Tasks',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            ...pendingTodos.map(
              (todo) => TodoTile(
                todo: todo,
                onToggle: (isDone) => _toggleTodo(todo, isDone),
                onEdit: () => _editTodo(todo),
                onDelete: () => _deleteTodo(todo),
              ),
            ),
          ],
          if (completedTodos.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Completed Tasks',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            ...completedTodos.map(
              (todo) => TodoTile(
                todo: todo,
                onToggle: (isDone) => _toggleTodo(todo, isDone),
                onEdit: () => _editTodo(todo),
                onDelete: () => _deleteTodo(todo),
              ),
            ),
          ],
          const SizedBox(height: 80), // Space for floating action button
        ],
      ),
    );
  }
}
