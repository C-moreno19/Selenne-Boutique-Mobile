import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrdersService {
  static const _ordersKeyPrefix =
      'vm_orders_'; // key per user: vm_orders_useremail

  static Future<SharedPreferences?> get _prefs async {
    try {
      return await SharedPreferences.getInstance();
    } on MissingPluginException {
      return null;
    }
  }

  static String _keyFor(String email) => '$_ordersKeyPrefix$email';

  // Get orders for a user (stored as JSON list)
  static Future<List<Map<String, dynamic>>> getOrdersForUser(
      String email) async {
    final p = await _prefs;
    if (p == null) return [];
    final raw = p.getString(_keyFor(email));
    if (raw == null) return [];
    final decoded = json.decode(raw) as List<dynamic>;
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  static Future<void> saveOrdersForUser(
      String email, List<Map<String, dynamic>> orders) async {
    final p = await _prefs;
    if (p == null) return;
    await p.setString(_keyFor(email), json.encode(orders));
  }

  static Future<void> addOrderForUser(
      String email, Map<String, dynamic> order) async {
    final current = await getOrdersForUser(email);
    current.insert(0, order); // newest first
    await saveOrdersForUser(email, current);
  }

  // Update an existing order by its 'order' id
  static Future<bool> updateOrderForUser(
      String email, String orderId, Map<String, dynamic> updatedOrder) async {
    final current = await getOrdersForUser(email);
    final idx = current.indexWhere((o) => o['order'] == orderId);
    if (idx == -1) return false;
    current[idx] = updatedOrder;
    await saveOrdersForUser(email, current);
    return true;
  }

  static Future<void> clearOrdersForUser(String email) async {
    final p = await _prefs;
    if (p == null) return;
    await p.remove(_keyFor(email));
  }
}
