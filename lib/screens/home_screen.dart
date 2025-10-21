// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../models/quote.dart';
import '../services/quote_service.dart';
import '../services/todo_service.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // TodoService'in Singleton olarak varsayıldığı için, sadece bir kez oluşturulur.
  final QuoteService _quoteService = QuoteService();
  final TodoService _todoService = TodoService();
  final AuthService _authService = AuthService();

  late Quote _currentQuote;
  final TextEditingController _todoController = TextEditingController();
  String? _username;
  bool _isLoading = true; // Yükleme durumu ekledik.
  DateTime? _selectedReminderTime;

  @override
  void initState() {
    super.initState();
    _currentQuote = _quoteService.getRandomQuote();
    // Hem kullanıcıyı hem de Todo'ları aynı anda yüklemeye başla.
    _initializeData();
  }

  // Widget'ın kapatılmasından önce controller'ı temizle.
  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _loadUsername();
    // Kullanıcı yüklendikten sonra (veya yönlendirme yapılmadıysa) Todo'ları yükle.
    if (_username != null) {
      // TodoService'in içinde yükleme mantığı olduğunu varsayıyoruz.
      // Bu çağrı, TodoService'in Shared Preferences'tan veriyi çekmesini sağlar.
      await _todoService.loadTodos();
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUsername() async {
    final currentUser = await _authService.getCurrentUser();

    // Kullanıcı adı yoksa, giriş ekranına yönlendir.
    if (currentUser == null || currentUser.trim().isEmpty) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/auth');
      return;
    }

    if (!mounted) return;
    setState(() => _username = currentUser);
  }

  Future<void> _logout() async {
    await _authService.logout();

    // Çıkış yaparken Todo listesini temizlemeye gerek yok, sadece kullanıcı adını temizleriz.
    // Başka bir kullanıcı giriş yaparsa kendi listesini görecektir.

    if (!mounted) return;
    // Çıkış yapınca Auth ekranına yönlendir.
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
        _todoService.addTodo(
          _todoController.text,
          reminderTime: _selectedReminderTime,
        );
        _todoController.clear();
        _selectedReminderTime = null;
        _todoService.saveTodos(); // Değişiklikten sonra kaydet
      });
    }
  }

  Future<void> _selectReminderTime() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedReminderTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && mounted) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          _selectedReminderTime ?? DateTime.now(),
        ),
      );

      if (time != null && mounted) {
        setState(() {
          _selectedReminderTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _clearReminderTime() {
    setState(() {
      _selectedReminderTime = null;
    });
  }

  void _toggleTodo(String id) {
    setState(() {
      _todoService.toggleTodo(id);
      _todoService.saveTodos(); // Değişiklikten sonra kaydet
    });
  }

  void _deleteTodo(String id) {
    setState(() {
      _todoService.deleteTodo(id);
      _todoService.saveTodos(); // Değişiklikten sonra kaydet
    });
  }

  @override
  Widget build(BuildContext context) {
    // Veriler yüklenirken yükleme ekranı göster
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Yükleme bittiyse normal ekranı göster
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
                            // TodoService'in anlık durumu
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
                      Column(
                        children: [
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
                          const SizedBox(height: 8),

                          // Hatırlatıcı Zamanı Seçimi
                          Row(
                            children: [
                              IconButton(
                                onPressed: _selectReminderTime,
                                icon: Icon(
                                  Icons.access_time,
                                  color: _selectedReminderTime != null
                                      ? const Color.fromARGB(255, 39, 134, 133)
                                      : Colors.grey,
                                ),
                                tooltip: "Hatırlatıcı Ekle",
                              ),
                              Expanded(
                                child: _selectedReminderTime != null
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                            255,
                                            39,
                                            134,
                                            133,
                                          ).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: const Color.fromARGB(
                                              255,
                                              39,
                                              134,
                                              133,
                                            ).withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.schedule,
                                              size: 16,
                                              color: Color.fromARGB(
                                                255,
                                                39,
                                                134,
                                                133,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              "${_selectedReminderTime!.day}/${_selectedReminderTime!.month}/${_selectedReminderTime!.year} "
                                              "${_selectedReminderTime!.hour.toString().padLeft(2, '0')}:"
                                              "${_selectedReminderTime!.minute.toString().padLeft(2, '0')}",
                                              style: const TextStyle(
                                                color: Color.fromARGB(
                                                  255,
                                                  39,
                                                  134,
                                                  133,
                                                ),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const Spacer(),
                                            GestureDetector(
                                              onTap: _clearReminderTime,
                                              child: const Icon(
                                                Icons.close,
                                                size: 16,
                                                color: Color.fromARGB(
                                                  255,
                                                  39,
                                                  134,
                                                  133,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : const Text(
                                        "Hatırlatıcı eklemek için saat ikonuna tıklayın",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                              ),
                            ],
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
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
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
                                          if (todo.hasReminder &&
                                              todo.reminderTime != null)
                                            Container(
                                              margin: const EdgeInsets.only(
                                                top: 4,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: const Color.fromARGB(
                                                  255,
                                                  39,
                                                  134,
                                                  133,
                                                ).withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: const Color.fromARGB(
                                                    255,
                                                    39,
                                                    134,
                                                    133,
                                                  ).withValues(alpha: 0.3),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.schedule,
                                                    size: 12,
                                                    color: Color.fromARGB(
                                                      255,
                                                      39,
                                                      134,
                                                      133,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    "${todo.reminderTime!.day}/${todo.reminderTime!.month}/${todo.reminderTime!.year} "
                                                    "${todo.reminderTime!.hour.toString().padLeft(2, '0')}:"
                                                    "${todo.reminderTime!.minute.toString().padLeft(2, '0')}",
                                                    style: const TextStyle(
                                                      color: Color.fromARGB(
                                                        255,
                                                        39,
                                                        134,
                                                        133,
                                                      ),
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
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
