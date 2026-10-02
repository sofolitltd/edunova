import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/services/api_client.dart';
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

/// Categories shown as filter chips in the notification list. There is no
/// backend field for this, so `urgent` is inferred from keywords and the
/// rest are derived from `linkType`.
extension AppNotificationCategory on AppNotification {
  String get category {
    final text = '$title $body'.toLowerCase();
    const urgentKeywords = ['urgent', 'জরুরি', 'গুরুত্বপূর্ণ'];
    if (urgentKeywords.any(text.contains)) return 'urgent';
    switch (linkType) {
      case 'exam':
        return 'exam';
      case 'course':
      case 'lesson':
        return 'class';
      case 'calendar':
        return 'vacation';
      default:
        return 'other';
    }
  }

  IconData get icon {
    switch (linkType) {
      case 'exam':
        return Icons.quiz_rounded;
      case 'course':
        return Icons.school_rounded;
      case 'article':
        return Icons.article_rounded;
      case 'lesson':
        return Icons.menu_book_rounded;
      case 'calendar':
        return Icons.calendar_today_rounded;
      case 'doubt':
        return Icons.help_outline_rounded;
      case 'enrollment':
        return Icons.how_to_reg_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color get iconColor {
    switch (linkType) {
      case 'exam':
        return Colors.orange;
      case 'course':
        return AppColors.primary;
      case 'article':
        return Colors.teal;
      case 'lesson':
        return Colors.blue;
      case 'calendar':
        return Colors.purple;
      case 'doubt':
        return Colors.red;
      case 'enrollment':
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }
}

class NotificationHistoryService {
  Future<List<AppNotification>> getNotifications(String token, {int page = 1}) async {
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/notifications?page=$page&limit=20'),
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
      Uri.parse('${ApiClient.baseUrl}/notifications/$notificationId/read'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<void> markAllAsRead(String token) async {
    await http.put(
      Uri.parse('${ApiClient.baseUrl}/notifications/read-all'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }
}
