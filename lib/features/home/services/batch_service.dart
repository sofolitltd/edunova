import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class BatchTeacher {
  final int id;
  final String fullName;

  BatchTeacher({required this.id, required this.fullName});

  factory BatchTeacher.fromJson(Map<String, dynamic> json) {
    return BatchTeacher(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? '',
    );
  }
}

class BatchDetail {
  final int id;
  final String name;
  final List<String> days;
  final String startTime;
  final String endTime;
  final String schedule;
  final String classLevel;
  final String shift;
  final String type;
  final int courseId;
  final String courseName;
  final String courseDescription;
  final List<BatchTeacher> teachers;
  final int studentCount;

  BatchDetail({
    required this.id,
    required this.name,
    required this.days,
    required this.startTime,
    required this.endTime,
    required this.schedule,
    required this.classLevel,
    required this.shift,
    required this.type,
    required this.courseId,
    required this.courseName,
    required this.courseDescription,
    required this.teachers,
    required this.studentCount,
  });

  factory BatchDetail.fromJson(Map<String, dynamic> json) {
    return BatchDetail(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      days: ((json['days'] as List?) ?? []).map((d) => d.toString()).toList(),
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      schedule: json['schedule'] ?? '',
      classLevel: json['class_level'] ?? '',
      shift: json['shift'] ?? '',
      type: json['type'] ?? '',
      courseId: json['course_id'] ?? 0,
      courseName: json['course_name'] ?? '',
      courseDescription: json['course_description'] ?? '',
      teachers: ((json['teachers'] as List?) ?? [])
          .map((t) => BatchTeacher.fromJson(t))
          .toList(),
      studentCount: json['student_count'] ?? 0,
    );
  }
}

class BatchSubjectSchedule {
  final int id;
  final int subjectId;
  final String subjectName;
  final int? teacherId;
  final String teacherName;
  final List<String> days;
  final String startTime;
  final String endTime;

  BatchSubjectSchedule({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    required this.teacherId,
    required this.teacherName,
    required this.days,
    required this.startTime,
    required this.endTime,
  });

  factory BatchSubjectSchedule.fromJson(Map<String, dynamic> json) {
    return BatchSubjectSchedule(
      id: json['id'] ?? 0,
      subjectId: json['subject_id'] ?? 0,
      subjectName: json['subject_name'] ?? '',
      teacherId: json['teacher_id'],
      teacherName: json['teacher_name'] ?? '',
      days: ((json['days'] as List?) ?? []).map((d) => d.toString()).toList(),
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
    );
  }
}

class BatchExam {
  final int id;
  final String title;
  final String date;
  final String time;
  final String duration;
  final int totalQuestions;
  final bool isLive;

  BatchExam({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.duration,
    required this.totalQuestions,
    required this.isLive,
  });

  factory BatchExam.fromJson(Map<String, dynamic> json) {
    return BatchExam(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      duration: json['duration'] ?? '',
      totalQuestions: json['total_questions'] ?? 0,
      isLive: json['is_live'] ?? false,
    );
  }
}

class LeaderboardEntry {
  final int userId;
  final String fullName;
  final int totalScore;
  final int examsTaken;

  LeaderboardEntry({
    required this.userId,
    required this.fullName,
    required this.totalScore,
    required this.examsTaken,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['user_id'] ?? 0,
      fullName: json['full_name'] ?? '',
      totalScore: json['total_score'] ?? 0,
      examsTaken: json['exams_taken'] ?? 0,
    );
  }
}

class BatchMyResult {
  final int examId;
  final String examTitle;
  final String examDate;
  final int score;
  final int totalQuestions;
  final String completedAt;

  BatchMyResult({
    required this.examId,
    required this.examTitle,
    required this.examDate,
    required this.score,
    required this.totalQuestions,
    required this.completedAt,
  });

  double get percentage => totalQuestions > 0 ? (score / totalQuestions) * 100 : 0;

  factory BatchMyResult.fromJson(Map<String, dynamic> json) {
    return BatchMyResult(
      examId: json['exam_id'] ?? 0,
      examTitle: json['exam_title'] ?? '',
      examDate: json['exam_date'] ?? '',
      score: json['score'] ?? 0,
      totalQuestions: json['total_questions'] ?? 0,
      completedAt: json['completed_at'] ?? '',
    );
  }
}

class BatchService {
  static String get _baseUrl {
    if (kIsWeb) return 'http://localhost:8080/api';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8080/api';
      default:
        return 'http://localhost:8080/api';
    }
  }

  Map<String, String> _headers(String? token) {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (token != null) h['Authorization'] = 'Bearer $token';
    return h;
  }

  Future<BatchDetail?> getBatchDetail(String? token, int batchId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/batches/$batchId'),
      headers: _headers(token),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return BatchDetail.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<List<BatchSubjectSchedule>> getBatchSubjects(String? token, int batchId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/batches/$batchId/subjects'),
      headers: _headers(token),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as List;
      return data.map((e) => BatchSubjectSchedule.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<BatchExam>> getBatchExams(String? token, int batchId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/batches/$batchId/exams'),
      headers: _headers(token),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as List;
      return data.map((e) => BatchExam.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<LeaderboardEntry>> getBatchLeaderboard(String? token, int batchId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/batches/$batchId/leaderboard'),
      headers: _headers(token),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as List;
      return data.map((e) => LeaderboardEntry.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<BatchMyResult>> getBatchMyResults(String? token, int batchId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/batches/$batchId/my-results'),
      headers: _headers(token),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as List;
      return data.map((e) => BatchMyResult.fromJson(e)).toList();
    }
    return [];
  }
}
