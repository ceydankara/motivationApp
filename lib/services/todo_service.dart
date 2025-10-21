// lib/services/todo_service.dart

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/todo_item.dart';

class TodoService {
  final List<TodoItem> _todos = [];
  static const String _prefsKey = 'todos';

  List<TodoItem> get todos => List.unmodifiable(_todos);

  List<TodoItem> get completedTodos =>
      _todos.where((todo) => todo.isCompleted).toList();

  List<TodoItem> get pendingTodos =>
      _todos.where((todo) => !todo.isCompleted).toList();

  void addTodo(String text) {
    if (text.trim().isEmpty) return;

    final newTodo = TodoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.trim(),
      createdAt: DateTime.now(),
    );

    _todos.add(newTodo);
  }

  void toggleTodo(String id) {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index] = _todos[index].copyWith(
        isCompleted: !_todos[index].isCompleted,
      );
    }
  }

  void deleteTodo(String id) {
    _todos.removeWhere((todo) => todo.id == id);
  }

  void clearCompleted() {
    _todos.removeWhere((todo) => todo.isCompleted);
  }

  Future<void> loadTodos() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) {
      return;
    }

    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      final List<TodoItem> loaded = decoded
          .whereType<Map<String, dynamic>>()
          .map((Map<String, dynamic> m) => TodoItem.fromJson(m))
          .toList();
      _todos
        ..clear()
        ..addAll(loaded);
    } catch (_) {
      // If parsing fails, keep current in-memory list intact
    }
  }

  Future<void> saveTodos() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String raw = jsonEncode(_todos.map((t) => t.toJson()).toList());
    await prefs.setString(_prefsKey, raw);
  }

  int get completedCount => completedTodos.length;
  int get pendingCount => pendingTodos.length;
  int get totalCount => _todos.length;
}
