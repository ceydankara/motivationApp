// lib/models/user.dart

class User {
  final String id;
  final String username;
  final String password;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.createdAt,
  });

  // JSON'dan User nesnesi oluşturmak için fabrika metodu
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // User'ı JSON'a çevirmek için metod
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Şifre kontrolü için metod
  bool checkPassword(String inputPassword) {
    return password == inputPassword;
  }
}
