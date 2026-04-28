import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CartService {
  static const _key = 'cart_v1';

  static Future<SharedPreferences> _prefs() async =>
      await SharedPreferences.getInstance();

  static Future<List<Map<String, dynamic>>> getCartItems() async {
    final p = await _prefs();
    final list = p.getStringList(_key) ?? [];
    return list
        .map((s) => Map<String, dynamic>.from(json.decode(s) as Map))
        .toList();
  }

  static String _identifier(Map<String, dynamic> item) {
    final image = item['image'] ?? '';
    final name = item['name'] ?? '';
    final size = item['size'] ?? '';
    final color = item['color'] ?? '';
    return '${image}_${name}_${size}_${color}';
  }

  static Future<void> addToCart(Map<String, dynamic> item) async {
    final prefs = await _prefs();
    final list = prefs.getStringList(_key) ?? [];
    final id = _identifier(item);
    // If exists, increase quantity
    for (var i = 0; i < list.length; i++) {
      try {
        final m = Map<String, dynamic>.from(json.decode(list[i]) as Map);
        if (_identifier(m) == id) {
          m['quantity'] = (m['quantity'] as int) + (item['quantity'] as int);
          list[i] = json.encode(m);
          await prefs.setStringList(_key, list);
          return;
        }
      } catch (_) {}
    }
    // otherwise add
    list.add(json.encode(item));
    await prefs.setStringList(_key, list);
  }

  static Future<void> removeFromCart(Map<String, dynamic> item) async {
    final prefs = await _prefs();
    final list = prefs.getStringList(_key) ?? [];
    final id = _identifier(item);
    final newList = <String>[];
    for (final s in list) {
      try {
        final m = Map<String, dynamic>.from(json.decode(s) as Map);
        if (_identifier(m) != id) newList.add(s);
      } catch (_) {
        newList.add(s);
      }
    }
    await prefs.setStringList(_key, newList);
  }

  static Future<void> updateQuantity(
      Map<String, dynamic> item, int quantity) async {
    final prefs = await _prefs();
    final list = prefs.getStringList(_key) ?? [];
    final id = _identifier(item);
    for (var i = 0; i < list.length; i++) {
      try {
        final m = Map<String, dynamic>.from(json.decode(list[i]) as Map);
        if (_identifier(m) == id) {
          m['quantity'] = quantity;
          list[i] = json.encode(m);
          await prefs.setStringList(_key, list);
          return;
        }
      } catch (_) {}
    }
  }

  static Future<void> clearCart() async {
    final prefs = await _prefs();
    await prefs.remove(_key);
  }
}
