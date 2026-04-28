import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _usersKey = 'vm_users';
  static const _currentUserKey = 'vm_current_user';

  static Future<SharedPreferences?> get _prefs async {
    try {
      return await SharedPreferences.getInstance();
    } on MissingPluginException {
      // Plugin not registered on this platform (e.g., web hot-reload after add).
      return null;
    }
  }

  // Users stored as map email -> userJson
  static Future<Map<String, dynamic>> _loadUsersMap() async {
    final p = await _prefs;
    if (p == null) return {};
    final raw = p.getString(_usersKey);
    if (raw == null) return {};
    return Map<String, dynamic>.from(json.decode(raw) as Map);
  }

  static Future<void> _saveUsersMap(Map<String, dynamic> map) async {
    final p = await _prefs;
    if (p == null) return;
    await p.setString(_usersKey, json.encode(map));
  }

  // Register a user: {name, email, phone, password}
  static Future<bool> registerUser(Map<String, dynamic> user) async {
    final users = await _loadUsersMap();
    final email = user['email'] as String;
    if (users.containsKey(email)) return false; // already exists
    users[email] = user;
    await _saveUsersMap(users);
    return true;
  }

  // Authenticate: returns user map or null
  static Future<Map<String, dynamic>?> authenticate(
      String email, String password) async {
    final users = await _loadUsersMap();
    final raw = users[email];
    if (raw == null) return null;
    final user = Map<String, dynamic>.from(raw);
    if (user['password'] == password) {
      await setCurrentUser(user);
      return user;
    }
    return null;
  }

  static Future<void> setCurrentUser(Map<String, dynamic>? user) async {
    final p = await _prefs;
    if (p == null) return;
    if (user == null) {
      await p.remove(_currentUserKey);
    } else {
      await p.setString(_currentUserKey, json.encode(user));
    }
  }

  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final p = await _prefs;
    if (p == null) return null;
    final raw = p.getString(_currentUserKey);
    if (raw == null) return null;
    return Map<String, dynamic>.from(json.decode(raw) as Map);
  }

  static Future<void> logout() async {
    final p = await _prefs;
    if (p == null) return;
    await p.remove(_currentUserKey);
  }
}
