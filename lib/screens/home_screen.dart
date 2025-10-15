// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../models/quote.dart';
import '../models/todo_item.dart';
import '../services/quote_service.dart';
import '../services/todo_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final QuoteService _quoteService = QuoteService();
  final TodoService _todoService = TodoService();
  late Quote _currentQuote;
  final TextEditingController _todoController = TextEditingController();
  String? _username;

  @override
  void initState() {
    super.initState();
    _currentQuote = _quoteService.getRandomQuote(); // İlk sözü yükle
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('username');
    if (name == null || name.trim().isEmpty) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/auth');
      return;
    }
    if (!mounted) return;
    setState(() => _username = name);
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/auth');
  }

  void _getNewQuote() {
    setState(() {
      _currentQuote = _quoteService.getRandomQuote();
    });
  }

  void _addTodo() {
    if (_todoController.text.trim().isNotEmpty) {
      setState(() {
        _todoService.addTodo(_todoController.text);
        _todoController.clear();
      });
    }
  }

  void _toggleTodo(String id) {
    setState(() {
      _todoService.toggleTodo(id);
    });
  }

  void _deleteTodo(String id) {
    setState(() {
      _todoService.deleteTodo(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _username == null ? "Günlük Motivasyon" : "Hoş geldin $_username",
        ),
        backgroundColor: const Color.fromARGB(255, 169, 209, 208),
        foregroundColor: const Color.fromARGB(255, 254, 237, 219),
        elevation: 1,
        actions: [
          IconButton(
            onPressed: _logout,
            tooltip: 'Çıkış',
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Motivasyon Sözleri Kutusu (Küçük)
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "💭 Günlük Motivasyon",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: _getNewQuote,
                          icon: const Icon(Icons.refresh),
                          tooltip: "Yeni Söz",
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _currentQuote.text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "- ${_currentQuote.author}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 39, 134, 133),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // To-Do Listesi
            Expanded(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "📝 Yapılacaklar",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${_todoService.completedCount}/${_todoService.totalCount}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // To-Do Ekleme Alanı
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _todoController,
                              decoration: const InputDecoration(
                                hintText: "Yeni görev ekle...",
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              onSubmitted: (_) => _addTodo(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _addTodo,
                            child: const Icon(Icons.add),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // To-Do Listesi
                      Expanded(
                        child: _todoService.todos.isEmpty
                            ? const Center(
                                child: Text(
                                  "Henüz görev eklenmemiş.\nYukarıdan yeni görev ekleyebilirsiniz!",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _todoService.todos.length,
                                itemBuilder: (context, index) {
                                  final todo = _todoService.todos[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      leading: Checkbox(
                                        value: todo.isCompleted,
                                        onChanged: (_) => _toggleTodo(todo.id),
                                      ),
                                      title: Text(
                                        todo.text,
                                        style: TextStyle(
                                          decoration: todo.isCompleted
                                              ? TextDecoration.lineThrough
                                              : null,
                                          color: todo.isCompleted
                                              ? Colors.grey
                                              : null,
                                        ),
                                      ),
                                      trailing: IconButton(
                                        onPressed: () => _deleteTodo(todo.id),
                                        icon: const Icon(Icons.delete),
                                        color: const Color.fromARGB(
                                          255,
                                          105,
                                          3,
                                          3,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
