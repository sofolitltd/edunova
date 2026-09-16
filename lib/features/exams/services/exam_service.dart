import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Exam {
  final int id;
  final String title;
  final int courseId;
  final String courseName;
  final String date;
  final String time;
  final String duration;
  final int totalQuestions;
  final bool isLive;
  final String? liveAt;
  final String? classLevel;
  final String? description;

  Exam({
    required this.id,
    required this.title,
    required this.courseId,
    required this.courseName,
    required this.date,
    required this.time,
    required this.duration,
    required this.totalQuestions,
    this.isLive = false,
    this.liveAt,
    this.classLevel,
    this.description,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      courseId: json['course_id'] ?? 0,
      courseName: json['course_name'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      duration: json['duration'] ?? '',
      totalQuestions: json['total_questions'] ?? 0,
      isLive: json['is_live'] ?? false,
      liveAt: json['live_at'],
      classLevel: json['class_level'],
      description: json['description'],
    );
  }
}

class ExamQuestion {
  final int id;
  final int examId;
  final String questionText;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;

  ExamQuestion({
    required this.id,
    required this.examId,
    required this.questionText,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
  });

  factory ExamQuestion.fromJson(Map<String, dynamic> json) {
    return ExamQuestion(
      id: json['id'] ?? 0,
      examId: json['exam_id'] ?? 0,
      questionText: json['question_text'] ?? '',
      optionA: json['option_a'] ?? '',
      optionB: json['option_b'] ?? '',
      optionC: json['option_c'] ?? '',
      optionD: json['option_d'] ?? '',
    );
  }
}

class ExamResult {
  final int id;
  final int examId;
  final String examTitle;
  final int totalQuestions;
  final int correctAnswers;
  final double percentage;
  final String submittedAt;

  ExamResult({
    required this.id,
    required this.examId,
    required this.examTitle,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.percentage,
    required this.submittedAt,
  });

  factory ExamResult.fromJson(Map<String, dynamic> json) {
    return ExamResult(
      id: json['id'] ?? 0,
      examId: json['exam_id'] ?? 0,
      examTitle: json['exam_title'] ?? '',
      totalQuestions: json['total_questions'] ?? 0,
      correctAnswers: json['correct_answers'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
      submittedAt: json['submitted_at'] ?? '',
    );
  }
}

class ExamService {
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
  ExamService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _headers({String? token}) {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (token != null) h['Authorization'] = 'Bearer $token';
    return h;
  }

  Future<List<Exam>> getLiveExams({String? token}) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/exams/live'),
      headers: _headers(token: token),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      final exams = data['exams'] as List? ?? [];
      return exams.map<Exam>((e) => Exam.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<ExamQuestion>> getExamQuestions(int examId, {String? token}) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/exams/$examId/questions'),
      headers: _headers(token: token),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      final questions = data['questions'] as List? ?? [];
      return questions.map<ExamQuestion>((q) => ExamQuestion.fromJson(q)).toList();
    }
    return [];
  }

  Future<void> submitExamResult({
    required int examId,
    required Map<int, String> answers,
    String? token,
  }) async {
    final answerList = answers.entries.map((e) => {
      'question_id': e.key,
      'selected_option': e.value,
    }).toList();

    final response = await _client.post(
      Uri.parse('$_baseUrl/exams/$examId/submit'),
      headers: _headers(token: token),
      body: jsonEncode({'answers': answerList}),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Failed to submit exam');
    }
  }

  Future<List<ExamResult>> getExamResults({String? token}) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/exams/results'),
      headers: _headers(token: token),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      final results = data['results'] as List? ?? [];
      return results.map<ExamResult>((r) => ExamResult.fromJson(r)).toList();
    }
    return [];
  }
}
