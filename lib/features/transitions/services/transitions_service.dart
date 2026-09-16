import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class StudentTransition {
  final int id;
  final int userId;
  final String userName;
  final int fromClass;
  final int toClass;
  final double gpa;
  final String resultNotes;
  final String submittedAt;

  StudentTransition({
    required this.id,
    required this.userId,
    required this.userName,
    required this.fromClass,
    required this.toClass,
    required this.gpa,
    required this.resultNotes,
    required this.submittedAt,
  });

  factory StudentTransition.fromJson(Map<String, dynamic> json) {
    return StudentTransition(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      userName: json['user_name'] ?? '',
      fromClass: json['from_class'] ?? 0,
      toClass: json['to_class'] ?? 0,
      gpa: (json['gpa'] ?? 0).toDouble(),
      resultNotes: json['result_notes'] ?? '',
      submittedAt: json['submitted_at'] ?? '',
    );
  }
}

class StudentFeedback {
  final int id;
  final int transitionId;
  final String strengths;
  final String improvements;
  final String recommendations;
  final String generatedAt;

  StudentFeedback({
    required this.id,
    required this.transitionId,
    required this.strengths,
    required this.improvements,
    required this.recommendations,
    required this.generatedAt,
  });

  factory StudentFeedback.fromJson(Map<String, dynamic> json) {
    return StudentFeedback(
      id: json['id'] ?? 0,
      transitionId: json['transition_id'] ?? 0,
      strengths: json['strengths'] ?? '',
      improvements: json['improvements'] ?? '',
      recommendations: json['recommendations'] ?? '',
      generatedAt: json['generated_at'] ?? '',
    );
  }
}

class TransitionsService {
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
  TransitionsService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _headers({String? token}) {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (token != null) h['Authorization'] = 'Bearer $token';
    return h;
  }

  Future<void> submitTransition({
    required int fromClass,
    required int toClass,
    required double gpa,
    String? resultNotes,
    String? token,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/transitions'),
      headers: _headers(token: token),
      body: jsonEncode({
        'from_class': fromClass,
        'to_class': toClass,
        'gpa': gpa,
        'result_notes': resultNotes ?? '',
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Failed to submit transition');
    }
  }

  Future<List<StudentTransition>> getMyTransitions({String? token}) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/transitions'),
      headers: _headers(token: token),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      final transitions = data['transitions'] as List? ?? [];
      return transitions.map<StudentTransition>((t) => StudentTransition.fromJson(t)).toList();
    }
    return [];
  }

  Future<List<StudentFeedback>> getMyFeedback({String? token}) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/transitions/feedback'),
      headers: _headers(token: token),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      final feedback = data['feedback'] as List? ?? [];
      return feedback.map<StudentFeedback>((f) => StudentFeedback.fromJson(f)).toList();
    }
    return [];
  }
}
