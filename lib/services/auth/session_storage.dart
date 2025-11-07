import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SessionStorage {
  static const _kCurrentUser = 'auth_current_user';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<void> setCurrentUser(Map<String, dynamic> user) async {
    final prefs = await _prefs;
    await prefs.setString(_kCurrentUser, jsonEncode(user));
  }

  Future<Map<String, dynamic>?> currentUser() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_kCurrentUser);
    if (raw == null) return null;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return m;
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    final prefs = await _prefs;
    await prefs.remove(_kCurrentUser);
  }
}
