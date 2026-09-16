import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ResultItem {
  final int id;
  final String subject;
  final String examName;
  final String examDate;
  final double marksObtained;
  final double marksTotal;
  final double percentage;
  final String remarks;

  ResultItem({
    required this.id,
    required this.subject,
    required this.examName,
    required this.examDate,
    required this.marksObtained,
    required this.marksTotal,
    required this.percentage,
    required this.remarks,
  });

  factory ResultItem.fromJson(Map<String, dynamic> json) {
    return ResultItem(
      id: json['id'] ?? 0,
      subject: json['subject'] ?? '',
      examName: json['exam_name'] ?? '',
      examDate: json['exam_date'] ?? '',
      marksObtained: (json['marks_obtained'] ?? 0).toDouble(),
      marksTotal: (json['marks_total'] ?? 0).toDouble(),
      percentage: (json['percentage'] ?? 0).toDouble(),
      remarks: json['remarks'] ?? '',
    );
  }
}

class SubjectSummary {
  final String subject;
  final double averagePercent;
  final int examCount;

  SubjectSummary({required this.subject, required this.averagePercent, required this.examCount});

  factory SubjectSummary.fromJson(Map<String, dynamic> json) {
    return SubjectSummary(
      subject: json['subject'] ?? '',
      averagePercent: (json['average_percent'] ?? 0).toDouble(),
      examCount: json['exam_count'] ?? 0,
    );
  }
}

class ResultSummary {
  final double overallPercent;
  final int totalExams;
  final List<SubjectSummary> bySubject;
  final List<SubjectSummary> improvementAreas;
  final List<ResultItem> recent;

  ResultSummary({
    required this.overallPercent,
    required this.totalExams,
    required this.bySubject,
    required this.improvementAreas,
    required this.recent,
  });

  factory ResultSummary.fromJson(Map<String, dynamic> json) {
    return ResultSummary(
      overallPercent: (json['overall_percent'] ?? 0).toDouble(),
      totalExams: json['total_exams'] ?? 0,
      bySubject: ((json['by_subject'] as List?) ?? [])
          .map((s) => SubjectSummary.fromJson(s))
          .toList(),
      improvementAreas: ((json['improvement_areas'] as List?) ?? [])
          .map((s) => SubjectSummary.fromJson(s))
          .toList(),
      recent: ((json['recent'] as List?) ?? [])
          .map((r) => ResultItem.fromJson(r))
          .toList(),
    );
  }

  factory ResultSummary.empty() => ResultSummary(
        overallPercent: 0,
        totalExams: 0,
        bySubject: const [],
        improvementAreas: const [],
        recent: const [],
      );
}

class ResultsService {
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
  ResultsService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _headers({String? token}) {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (token != null) h['Authorization'] = 'Bearer $token';
    return h;
  }

  Future<List<ResultItem>> getResults({String? token}) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/results'),
      headers: _headers(token: token),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as List;
      return data.map((r) => ResultItem.fromJson(r)).toList();
    }
    return [];
  }

  Future<ResultSummary> getSummary({String? token}) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/results/summary'),
      headers: _headers(token: token),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ResultSummary.fromJson(jsonDecode(response.body));
    }
    return ResultSummary.empty();
  }
}
