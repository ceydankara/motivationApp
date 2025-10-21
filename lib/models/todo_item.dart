// lib/models/todo_item.dart

class TodoItem {
  final String id;
  final String text;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? reminderTime;
  final bool hasReminder;

  TodoItem({
    required this.id,
    required this.text,
    this.isCompleted = false,
    required this.createdAt,
    this.reminderTime,
    this.hasReminder = false,
  });

  TodoItem copyWith({
    String? id,
    String? text,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? reminderTime,
    bool? hasReminder,
  }) {
    return TodoItem(
      id: id ?? this.id,
      text: text ?? this.text,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      reminderTime: reminderTime ?? this.reminderTime,
      hasReminder: hasReminder ?? this.hasReminder,
    );
  }

  // JSON'dan TodoItem nesnesi oluşturmak için fabrika metodu
  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'] as String,
      text: json['text'] as String,
      isCompleted: json['isCompleted'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      reminderTime: json['reminderTime'] != null
          ? DateTime.parse(json['reminderTime'] as String)
          : null,
      hasReminder: json['hasReminder'] as bool? ?? false,
    );
  }

  // TodoItem'ı JSON'a çevirmek için metod
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'reminderTime': reminderTime?.toIso8601String(),
      'hasReminder': hasReminder,
    };
  }
}
