import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotificationsService {
  static const String _notificationsKey = 'notifications_list';

  /// Get all notifications (returns empty list if none exist)
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_notificationsKey);
    if (jsonStr == null || jsonStr.isEmpty) {
      return [];
    }
    try {
      final decoded = jsonDecode(jsonStr) as List<dynamic>;
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get unread notifications count
  static Future<int> getUnreadCount() async {
    final notifications = await getNotifications();
    return notifications.where((n) => n['read'] == false).length;
  }

  /// Add a new notification
  static Future<void> addNotification(String title, String message) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = await getNotifications();
    notifications.insert(0, {
      'title': title,
      'message': message,
      'read': false,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await prefs.setString(_notificationsKey, jsonEncode(notifications));
  }

  /// Mark notification as read by index
  static Future<void> markAsRead(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = await getNotifications();
    if (index >= 0 && index < notifications.length) {
      notifications[index]['read'] = true;
      await prefs.setString(_notificationsKey, jsonEncode(notifications));
    }
  }

  /// Clear all notifications
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notificationsKey);
  }
}
