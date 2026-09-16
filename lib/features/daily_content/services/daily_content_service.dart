import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class DailyContentItem {
  final int id;
  final String contentType;
  final String classLevel;
  final String title;
  final String body;
  final String answer;
  final String language;
  final bool isPublished;
  final String createdAt;

  DailyContentItem({
    required this.id,
    required this.contentType,
    required this.classLevel,
    required this.title,
    required this.body,
    required this.answer,
    required this.language,
    required this.isPublished,
    required this.createdAt,
  });

  factory DailyContentItem.fromJson(Map<String, dynamic> json) {
    return DailyContentItem(
      id: json['id'] ?? 0,
      contentType: json['content_type'] ?? '',
      classLevel: json['class_level'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      answer: json['answer'] ?? '',
      language: json['language'] ?? 'bn',
      isPublished: json['is_published'] ?? false,
      createdAt: json['created_at'] ?? '',
    );
  }
}

class DailyContentService {
  static String get _baseUrl {
    if (kIsWeb) return 'http://localhost:8080/api';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8080/api';
      default:
        return 'http://localhost:8080/api';
    }
  }

  final http.Client _client;
  DailyContentService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _headers({String? token}) {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (token != null) h['Authorization'] = 'Bearer $token';
    return h;
  }

  Future<List<DailyContentItem>> getDailyContent({String? token, String? contentType}) async {
    final params = <String, String>{};
    if (contentType != null) params['content_type'] = contentType;

    final uri = Uri.parse('$_baseUrl/daily-content').replace(
      queryParameters: params.isNotEmpty ? params : null,
    );
    final response = await _client.get(uri, headers: _headers(token: token));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      final items = data is List ? data : (data['content'] as List? ?? []);
      return items.map<DailyContentItem>((i) => DailyContentItem.fromJson(i)).toList();
    }
    return [];
  }

  Future<int> getStreak({String? token}) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/daily-content/streak'),
      headers: _headers(token: token),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return data['streak'] ?? 0;
    }
    return 0;
  }

  Future<void> markContentViewed(int contentId, {String? token}) async {
    await _client.post(
      Uri.parse('$_baseUrl/daily-content/$contentId/view'),
      headers: _headers(token: token),
    );
  }
}
