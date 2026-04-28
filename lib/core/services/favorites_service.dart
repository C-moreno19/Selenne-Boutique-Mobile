import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const _key = 'favorites_v1';

  static Future<SharedPreferences> _prefs() async =>
      await SharedPreferences.getInstance();

  // Store product as JSON string in a List<String>
  static Future<List<Map<String, dynamic>>> getFavorites() async {
    final p = await _prefs();
    final list = p.getStringList(_key) ?? [];
    return list
        .map((s) => Map<String, dynamic>.from(json.decode(s) as Map))
        .toList();
  }

  static String _identifier(Map<String, dynamic> product) {
    // Use image url + name if available, otherwise name only
    final image = product['image'] ?? '';
    final name = product['name'] ?? '';
    return '${image}_$name';
  }

  static Future<bool> isFavorite(Map<String, dynamic> product) async {
    final prefs = await _prefs();
    final list = prefs.getStringList(_key) ?? [];
    final id = _identifier(product);
    for (final s in list) {
      try {
        final m = json.decode(s) as Map<String, dynamic>;
        if (_identifier(m) == id) return true;
      } catch (_) {}
    }
    return false;
  }

  static Future<void> addFavorite(Map<String, dynamic> product) async {
    final prefs = await _prefs();
    final list = prefs.getStringList(_key) ?? [];
    final id = _identifier(product);
    // avoid duplicates
    for (final s in list) {
      try {
        final m = json.decode(s) as Map<String, dynamic>;
        if (_identifier(m) == id) return;
      } catch (_) {}
    }
    list.add(json.encode(product));
    await prefs.setStringList(_key, list);
  }

  static Future<void> removeFavorite(Map<String, dynamic> product) async {
    final prefs = await _prefs();
    final list = prefs.getStringList(_key) ?? [];
    final id = _identifier(product);
    final newList = <String>[];
    for (final s in list) {
      try {
        final m = json.decode(s) as Map<String, dynamic>;
        if (_identifier(m) != id) newList.add(s);
      } catch (_) {
        // keep malformed
        newList.add(s);
      }
    }
    await prefs.setStringList(_key, newList);
  }

  static Future<void> clearAll() async {
    final prefs = await _prefs();
    await prefs.remove(_key);
  }
}
