// lib/services/auth_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String _usersKey = 'users';
  static const String _currentUserKey = 'current_user';

  // Kullanıcı kaydı
  Future<bool> register(String username, String password) async {
    if (username.trim().isEmpty || password.trim().isEmpty) {
      return false;
    }

    final users = await _getUsers();

    // Kullanıcı adı zaten var mı kontrol et
    if (users.any(
      (user) => user.username.toLowerCase() == username.toLowerCase(),
    )) {
      return false;
    }

    // Yeni kullanıcı oluştur
    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      username: username.trim(),
      password: password.trim(),
      createdAt: DateTime.now(),
    );

    users.add(newUser);
    await _saveUsers(users);
    return true;
  }

  // Kullanıcı girişi
  Future<bool> login(String username, String password) async {
    if (username.trim().isEmpty || password.trim().isEmpty) {
      return false;
    }

    final users = await _getUsers();
    final user = users.firstWhere(
      (u) => u.username.toLowerCase() == username.toLowerCase(),
      orElse: () =>
          User(id: '', username: '', password: '', createdAt: DateTime.now()),
    );

    if (user.id.isEmpty || !user.checkPassword(password)) {
      return false;
    }

    // Giriş yapan kullanıcıyı kaydet
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, user.username);
    return true;
  }

  // Çıkış yapma
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  // Mevcut kullanıcıyı kontrol et
  Future<String?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey);
  }

  // Tüm kullanıcıları getir
  Future<List<User>> _getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? usersJson = prefs.getString(_usersKey);

    if (usersJson == null || usersJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> usersList = jsonDecode(usersJson) as List<dynamic>;
      return usersList
          .whereType<Map<String, dynamic>>()
          .map((json) => User.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Kullanıcıları kaydet
  Future<void> _saveUsers(List<User> users) async {
    final prefs = await SharedPreferences.getInstance();
    final String usersJson = jsonEncode(
      users.map((user) => user.toJson()).toList(),
    );
    await prefs.setString(_usersKey, usersJson);
  }
}
