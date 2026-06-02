import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _usersKey = 'users';
  static const _currentUserKey = 'currentUser';

  static Future<({bool success, String? error})> register(
      String name, String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final users = _loadUsers(prefs);

    if (users.any((u) => u['email'] == email)) {
      return (success: false, error: '이미 사용 중인 이메일입니다');
    }

    users.add({'name': name, 'email': email, 'password': password});
    await prefs.setString(_usersKey, jsonEncode(users));
    await prefs.setString(_currentUserKey, jsonEncode({'name': name, 'email': email}));
    return (success: true, error: null);
  }

  static Future<({bool success, String? error})> login(
      String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final users = _loadUsers(prefs);

    final matches = users.where(
        (u) => u['email'] == email && u['password'] == password);
    if (matches.isEmpty) {
      return (success: false, error: '이메일 또는 비밀번호가 틀렸습니다');
    }

    final user = matches.first;
    await prefs.setString(
        _currentUserKey, jsonEncode({'name': user['name'], 'email': email}));
    return (success: true, error: null);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  static Future<Map<String, String>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_currentUserKey);
    if (json == null) return null;
    final map = jsonDecode(json) as Map<String, dynamic>;
    return {'name': map['name'] as String, 'email': map['email'] as String};
  }

  static Future<bool> isLoggedIn() async {
    return (await getCurrentUser()) != null;
  }

  static List<Map<String, dynamic>> _loadUsers(SharedPreferences prefs) {
    final json = prefs.getString(_usersKey);
    if (json == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(json));
  }
}
