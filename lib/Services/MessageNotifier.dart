import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Utils.dart';

class MessageNotifier {
  static final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);

  static void updateCount(int count) {
    unreadCount.value = count;
  }

  static Future<void> refresh() async {
    try {
      if (Utils.token.isEmpty || Utils.userId.isEmpty) return;

      final url = '${Utils.baseUrl}/chat/unread-count';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer ${Utils.token}'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          unreadCount.value = data['unreadCount'] ?? 0;
        }
      }
    } catch (e) {
      debugPrint('Error fetching unread count: $e');
    }
  }

  static void markAsRead() {
    unreadCount.value = 0;
  }

  static void incrementCount() {
    unreadCount.value += 1;
  }
}
