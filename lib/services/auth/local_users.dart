import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalUsers {
  static const _kUsers = 'auth_users';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<List<Map<String, dynamic>>> all() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_kUsers);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List;
    return list.cast<Map>().map((e) => e.cast<String, dynamic>()).toList();
  }

  Future<void> _save(List<Map<String, dynamic>> users) async {
    final prefs = await _prefs;
    await prefs.setString(_kUsers, jsonEncode(users));
  }

  Future<bool> exists(String username) async {
    final users = await all();
    return users.any((u) => (u['username'] as String).toLowerCase() == username.toLowerCase());
  }

  Future<void> add(Map<String, dynamic> user) async {
    final users = await all();
    users.add(user);
    await _save(users);
  }

  Future<Map<String, dynamic>?> find(String username) async {
    final users = await all();
    try {
      return users.firstWhere((u) => (u['username'] as String).toLowerCase() == username.toLowerCase());
    } catch (_) {
      return null;
    }
  }
}

