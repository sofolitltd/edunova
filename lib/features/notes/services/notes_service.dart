import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Note {
  final int id;
  final String title;
  final String content;
  final String classLevel;
  final String subject;
  final String chapter;
  final String type;
  final String language;
  final bool isPublished;
  final int usageCount;
  final String createdAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.classLevel,
    required this.subject,
    required this.chapter,
    required this.type,
    required this.language,
    required this.isPublished,
    required this.usageCount,
    required this.createdAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      classLevel: json['class_level'] ?? '',
      subject: json['subject'] ?? '',
      chapter: json['chapter'] ?? '',
      type: json['type'] ?? 'notes',
      language: json['language'] ?? 'bn',
      isPublished: json['is_published'] ?? false,
      usageCount: json['usage_count'] ?? 0,
      createdAt: json['created_at'] ?? '',
    );
  }
}

class NotesService {
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
  NotesService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _headers({String? token}) {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (token != null) h['Authorization'] = 'Bearer $token';
    return h;
  }

  Future<List<Note>> getNotes({
    String? token,
    String? classLevel,
    String? subject,
    String? type,
  }) async {
    final params = <String, String>{};
    if (classLevel != null) params['class_level'] = classLevel;
    if (subject != null) params['subject'] = subject;
    if (type != null) params['type'] = type;

    final uri = Uri.parse('$_baseUrl/notes').replace(queryParameters: params.isNotEmpty ? params : null);
    final response = await _client.get(uri, headers: _headers(token: token));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      final notes = data is List ? data : (data['notes'] as List? ?? []);
      return notes.map<Note>((n) => Note.fromJson(n)).toList();
    }
    return [];
  }

  Future<Note?> getNoteById(int id, {String? token}) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/notes/$id'),
      headers: _headers(token: token),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return Note.fromJson(data);
    }
    return null;
  }
}
