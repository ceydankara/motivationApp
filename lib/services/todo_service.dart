// lib/services/todo_service.dart

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/todo_item.dart';
import 'notification_service.dart';

class TodoService {
  final List<TodoItem> _todos = [];
  static const String _prefsKey = 'todos';

  List<TodoItem> get todos => List.unmodifiable(_todos);

  List<TodoItem> get completedTodos =>
      _todos.where((todo) => todo.isCompleted).toList();

  List<TodoItem> get pendingTodos =>
      _todos.where((todo) => !todo.isCompleted).toList();

  void addTodo(String text, {DateTime? reminderTime}) {
    if (text.trim().isEmpty) return;

    final todoId = DateTime.now().millisecondsSinceEpoch.toString();
    final notificationId =
        DateTime.now().millisecondsSinceEpoch % 2147483647; // 32-bit int limit
    final newTodo = TodoItem(
      id: todoId,
      text: text.trim(),
      createdAt: DateTime.now(),
      reminderTime: reminderTime,
      hasReminder: reminderTime != null,
    );

    _todos.add(newTodo);

    // Hatırlatıcı zamanı varsa bildirim zamanla
    if (reminderTime != null) {
      _scheduleReminderNotification(notificationId, text.trim(), reminderTime);
    }
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
    // Silmeden önce bildirimi iptal et
    final todo = _todos.firstWhere(
      (todo) => todo.id == id,
      orElse: () => TodoItem(id: '', text: '', createdAt: DateTime.now()),
    );

    if (todo.id.isNotEmpty && todo.hasReminder) {
      final notificationId = int.parse(id) % 2147483647; // 32-bit int limit
      NotificationService.cancelReminder(notificationId);
    }

    _todos.removeWhere((todo) => todo.id == id);
  }

  void clearCompleted() {
    _todos.removeWhere((todo) => todo.isCompleted);
  }

  void updateTodoReminder(String id, DateTime? reminderTime) {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index] = _todos[index].copyWith(
        reminderTime: reminderTime,
        hasReminder: reminderTime != null,
      );

      // Bildirim güncelle
      final notificationId = int.parse(id) % 2147483647; // 32-bit int limit
      if (reminderTime != null) {
        _scheduleReminderNotification(
          notificationId,
          _todos[index].text,
          reminderTime,
        );
      } else {
        NotificationService.cancelReminder(notificationId);
      }
    }
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

  // Hatırlatıcı bildirimi zamanla
  Future<void> _scheduleReminderNotification(
    int id,
    String text,
    DateTime reminderTime,
  ) async {
    await NotificationService.scheduleReminder(
      id: id,
      title: 'Görev Hatırlatıcısı',
      body: text,
      scheduledTime: reminderTime,
    );
  }
}
