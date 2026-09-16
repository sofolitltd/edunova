import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AppNotification {
  final int id;
  final String title;
  final String body;
  final String target;
  final int targetId;
  final String linkType;
  final int linkId;
  final String sentAt;
  final bool readByMe;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.target,
    required this.targetId,
    required this.linkType,
    required this.linkId,
    required this.sentAt,
    required this.readByMe,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      target: json['target'] ?? '',
      targetId: json['target_id'] ?? 0,
      linkType: json['link_type'] ?? '',
      linkId: json['link_id'] ?? 0,
      sentAt: json['sent_at'] ?? '',
      readByMe: json['read_by_me'] ?? false,
    );
  }
}

class NotificationHistoryService {
  static String get _baseUrl {
    if (kIsWeb) return 'http://localhost:8080/api';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8080/api';
      default:
        return 'http://localhost:8080/api';
    }
  }

  Future<List<AppNotification>> getNotifications(String token, {int page = 1}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/notifications?page=$page&limit=20'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = (data['notifications'] ?? []) as List;
      return list.map((n) => AppNotification.fromJson(n)).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  Future<void> markAsRead(String token, int notificationId) async {
    await http.put(
      Uri.parse('$_baseUrl/notifications/$notificationId/read'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<void> markAllAsRead(String token) async {
    await http.put(
      Uri.parse('$_baseUrl/notifications/read-all'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }
}
