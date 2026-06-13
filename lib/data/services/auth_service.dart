import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _usersKey = 'users';
  static const _currentUserKey = 'currentUser';

  static Future<({bool success, String? error})> register(
      String name, String email, String password, {
      String? gender, String? phone, String? birthDate}) async {
    final prefs = await SharedPreferences.getInstance();
    final users = _loadUsers(prefs);

    if (users.any((u) => u['email'] == email)) {
      return (success: false, error: '이미 사용 중인 이메일입니다');
    }

    users.add({
      'name': name, 'email': email, 'password': password,
      'gender': ?gender,
      'phone': ?phone,
      'birthDate': ?birthDate,
    });
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

  static Future<({bool success, String? error})> changePassword(
      String currentPassword, String newPassword) async {
    final current = await getCurrentUser();
    if (current == null) return (success: false, error: '로그인 정보가 없습니다');

    final prefs = await SharedPreferences.getInstance();
    final users = _loadUsers(prefs);
    final idx = users.indexWhere(
        (u) => u['email'] == current['email'] && u['password'] == currentPassword);

    if (idx == -1) return (success: false, error: '현재 비밀번호가 틀렸습니다');

    users[idx]['password'] = newPassword;
    await prefs.setString(_usersKey, jsonEncode(users));
    return (success: true, error: null);
  }

  static Future<Map<String, dynamic>?> getUserDetails() async {
    final current = await getCurrentUser();
    if (current == null) return null;
    final prefs = await SharedPreferences.getInstance();
    final users = _loadUsers(prefs);
    try {
      return users.firstWhere((u) => u['email'] == current['email']);
    } catch (_) {
      return null;
    }
  }

  static Future<({bool success, String? error})> updateProfile({
    String? name, String? gender, String? phone, String? birthDate, String? profileImage,
  }) async {
    final current = await getCurrentUser();
    if (current == null) return (success: false, error: '로그인 정보가 없습니다');

    final prefs = await SharedPreferences.getInstance();
    final users = _loadUsers(prefs);
    final idx = users.indexWhere((u) => u['email'] == current['email']);
    if (idx == -1) return (success: false, error: '사용자를 찾을 수 없습니다');

    if (name != null) users[idx]['name'] = name;
    if (gender != null) users[idx]['gender'] = gender;
    if (phone != null) users[idx]['phone'] = phone;
    if (birthDate != null) users[idx]['birthDate'] = birthDate;
    if (profileImage != null) users[idx]['profileImage'] = profileImage;

    await prefs.setString(_usersKey, jsonEncode(users));
    await prefs.setString(_currentUserKey, jsonEncode({'name': users[idx]['name'], 'email': current['email']}));
    return (success: true, error: null);
  }

  /// 여행 취향 설정 (각 항목 복수 선택 가능)
  static Future<({bool success, String? error})> updatePreferences({
    required List<String> travelStyles,
    required List<String> budgets,
    required List<String> companions,
    required List<String> regions,
    required List<String> intensities,
  }) async {
    final current = await getCurrentUser();
    if (current == null) return (success: false, error: '로그인 정보가 없습니다');

    final prefs = await SharedPreferences.getInstance();
    final users = _loadUsers(prefs);
    final idx = users.indexWhere((u) => u['email'] == current['email']);
    if (idx == -1) return (success: false, error: '사용자를 찾을 수 없습니다');

    users[idx]['travelStyles'] = travelStyles;
    users[idx]['budgets'] = budgets;
    users[idx]['companions'] = companions;
    users[idx]['regions'] = regions;
    users[idx]['intensities'] = intensities;

    await prefs.setString(_usersKey, jsonEncode(users));
    return (success: true, error: null);
  }

  /// 최초 로그인 시 프로필/취향 설정 완료 여부
  static Future<bool> isOnboardingCompleted() async {
    final user = await getUserDetails();
    return user?['onboardingCompleted'] as bool? ?? false;
  }

  static Future<void> completeOnboarding() async {
    final current = await getCurrentUser();
    if (current == null) return;

    final prefs = await SharedPreferences.getInstance();
    final users = _loadUsers(prefs);
    final idx = users.indexWhere((u) => u['email'] == current['email']);
    if (idx == -1) return;

    users[idx]['onboardingCompleted'] = true;
    await prefs.setString(_usersKey, jsonEncode(users));
  }

  static Future<({bool success, String? error})> deleteAccount(String password) async {
    final current = await getCurrentUser();
    if (current == null) return (success: false, error: '로그인 정보가 없습니다');

    final prefs = await SharedPreferences.getInstance();
    final users = _loadUsers(prefs);
    final idx = users.indexWhere(
        (u) => u['email'] == current['email'] && u['password'] == password);
    if (idx == -1) return (success: false, error: '비밀번호가 틀렸습니다');

    users.removeAt(idx);
    await prefs.setString(_usersKey, jsonEncode(users));
    await prefs.remove(_currentUserKey);
    return (success: true, error: null);
  }

  static List<Map<String, dynamic>> _loadUsers(SharedPreferences prefs) {
    final json = prefs.getString(_usersKey);
    if (json == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(json));
  }
}
