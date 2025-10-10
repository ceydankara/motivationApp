// lib/models/todo_item.dart

class TodoItem {
  final String id;
  final String text;
  final bool isCompleted;
  final DateTime createdAt;

  TodoItem({
    required this.id,
    required this.text,
    this.isCompleted = false,
    required this.createdAt,
  });

  TodoItem copyWith({
    String? id,
    String? text,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return TodoItem(
      id: id ?? this.id,
      text: text ?? this.text,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // JSON'dan TodoItem nesnesi oluşturmak için fabrika metodu
  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'] as String,
      text: json['text'] as String,
      isCompleted: json['isCompleted'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // TodoItem'ı JSON'a çevirmek için metod
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
