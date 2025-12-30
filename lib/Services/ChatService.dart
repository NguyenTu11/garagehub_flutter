import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Utils.dart';

class ChatMessage {
  final String? id;
  final String conversationId;
  final String senderId;
  final String senderRole;
  final String message;
  final bool isRead;
  final DateTime? createdAt;

  ChatMessage({
    this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderRole,
    required this.message,
    this.isRead = false,
    this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['_id'] ?? json['id'],
      conversationId: json['conversationId'] ?? '',
      senderId: json['senderId'] is String
          ? json['senderId']
          : json['senderId']?['_id'] ?? '',
      senderRole: json['senderRole'] ?? 'user',
      message: json['message'] ?? '',
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'conversationId': conversationId, 'message': message};
  }
}

class ChatService {
  Future<List<ChatMessage>> getMessages(String conversationId) async {
    try {
      final response = await http.get(
        Uri.parse('${Utils.baseUrl}/chat/messages/$conversationId'),
        headers: {'Authorization': 'Bearer ${Utils.token}'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['messages'] != null) {
          return (data['messages'] as List)
              .map((e) => ChatMessage.fromJson(e))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting messages: $e');
      return [];
    }
  }

  Future<ChatMessage?> sendMessage(
    String conversationId,
    String message,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${Utils.baseUrl}/chat/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Utils.token}',
        },
        body: json.encode({
          'conversationId': conversationId,
          'message': message,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['message'] != null) {
          return ChatMessage.fromJson(data['message']);
        }
      }
      return null;
    } catch (e) {
      print('Error sending message: $e');
      return null;
    }
  }

  Future<void> markAsRead(String conversationId) async {
    try {
      await http.put(
        Uri.parse('${Utils.baseUrl}/chat/messages/$conversationId/read'),
        headers: {'Authorization': 'Bearer ${Utils.token}'},
      );
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await http.get(
        Uri.parse('${Utils.baseUrl}/chat/unread-count'),
        headers: {'Authorization': 'Bearer ${Utils.token}'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['count'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }
}
