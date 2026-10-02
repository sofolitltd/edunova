import 'dart:convert';
import '../../../shared/services/api_client.dart';
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

class SuggestedBatch {
  final int id;
  final String name;
  final String classLevel;
  final List<String> days;
  final String startTime;
  final String endTime;
  final String schedule;
  final String shift;
  final String type;
  final int admissionFee;
  final int noteFee;
  final int monthlyFee;
  final int courseId;
  final String courseName;
  final int maxStudents;

  SuggestedBatch({
    required this.id,
    required this.name,
    required this.classLevel,
    required this.days,
    required this.startTime,
    required this.endTime,
    required this.schedule,
    required this.shift,
    required this.type,
    required this.admissionFee,
    required this.noteFee,
    required this.monthlyFee,
    required this.courseId,
    required this.courseName,
    required this.maxStudents,
  });

  factory SuggestedBatch.fromJson(Map<String, dynamic> json) {
    return SuggestedBatch(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      classLevel: json['class_level'] ?? '',
      days: ((json['days'] as List?) ?? []).map((d) => d.toString()).toList(),
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      schedule: json['schedule'] ?? '',
      shift: json['shift'] ?? '',
      type: json['type'] ?? '',
      admissionFee: json['admission_fee'] ?? 0,
      noteFee: json['note_fee'] ?? 0,
      monthlyFee: json['monthly_fee'] ?? 0,
      courseId: json['course_id'] ?? 0,
      courseName: json['course_name'] ?? '',
      maxStudents: json['max_students'] ?? 0,
    );
  }
}

class BatchStudent {
  final int id;
  final String fullName;
  final String studentId;

  BatchStudent({required this.id, required this.fullName, required this.studentId});

  factory BatchStudent.fromJson(Map<String, dynamic> json) {
    return BatchStudent(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? '',
      studentId: json['student_id'] ?? '',
    );
  }
}

class BatchNotice {
  final int id;
  final String title;
  final String body;
  final String sentAt;
  final bool readByMe;

  BatchNotice({
    required this.id,
    required this.title,
    required this.body,
    required this.sentAt,
    required this.readByMe,
  });

  factory BatchNotice.fromJson(Map<String, dynamic> json) {
    return BatchNotice(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      sentAt: json['sent_at'] ?? '',
      readByMe: json['read_by_me'] ?? false,
    );
  }
}

class BatchPayment {
  final int id;
  final double amount;
  final String method;
  final String transactionId;
  final String status;
  final String receiptNumber;
  final String month;
  final int year;
  final String notes;
  final String createdAt;

  BatchPayment({
    required this.id,
    required this.amount,
    required this.method,
    required this.transactionId,
    required this.status,
    required this.receiptNumber,
    required this.month,
    required this.year,
    required this.notes,
    required this.createdAt,
  });

  factory BatchPayment.fromJson(Map<String, dynamic> json) {
    return BatchPayment(
      id: json['id'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
      method: json['method'] ?? '',
      transactionId: json['transaction_id'] ?? '',
      status: json['status'] ?? 'pending',
      receiptNumber: json['receipt_number'] ?? '',
      month: json['month'] ?? '',
      year: json['year'] ?? 0,
      notes: json['notes'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}

class BatchPayments {
  final int monthlyFee;
  final List<BatchPayment> payments;

  BatchPayments({required this.monthlyFee, required this.payments});

  factory BatchPayments.fromJson(Map<String, dynamic> json) {
    return BatchPayments(
      monthlyFee: json['monthly_fee'] ?? 0,
      payments: ((json['payments'] as List?) ?? [])
          .map((e) => BatchPayment.fromJson(e))
          .toList(),
    );
  }
}

class BatchService {
  Map<String, String> _headers(String? token) {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (token != null) h['Authorization'] = 'Bearer $token';
    return h;
  }

  Future<List<SuggestedBatch>> getSuggestedBatches(String? token) async {
    if (token == null) return [];
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/batches/suggested'),
      headers: _headers(token),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as List;
      return data.map((e) => SuggestedBatch.fromJson(e)).toList();
    }
    return [];
  }

  Future<BatchDetail?> getBatchDetail(String? token, int batchId) async {
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/batches/$batchId'),
      headers: _headers(token),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return BatchDetail.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<List<BatchSubjectSchedule>> getBatchSubjects(String? token, int batchId) async {
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/batches/$batchId/subjects'),
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
      Uri.parse('${ApiClient.baseUrl}/batches/$batchId/exams'),
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
      Uri.parse('${ApiClient.baseUrl}/batches/$batchId/leaderboard'),
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
      Uri.parse('${ApiClient.baseUrl}/batches/$batchId/my-results'),
      headers: _headers(token),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as List;
      return data.map((e) => BatchMyResult.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<BatchStudent>> getBatchStudents(String? token, int batchId) async {
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/batches/$batchId/students'),
      headers: _headers(token),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as List;
      return data.map((e) => BatchStudent.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<BatchNotice>> getBatchNotices(String? token, int batchId) async {
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/batches/$batchId/notices'),
      headers: _headers(token),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as List;
      return data.map((e) => BatchNotice.fromJson(e)).toList();
    }
    return [];
  }

  Future<BatchPayments?> getBatchPayments(String? token, int batchId) async {
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/batches/$batchId/payments'),
      headers: _headers(token),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return BatchPayments.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  /// Submits a monthly fee payment (bKash/Nagad-style manual transfer) for
  /// admin review. Throws [BatchPaymentException] with the server's error
  /// message on failure.
  Future<void> payBatchFee(
    String? token,
    int batchId, {
    required double amount,
    required String method,
    required String transactionId,
    required String senderNumber,
    required String month,
    required int year,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiClient.baseUrl}/batches/$batchId/payments'),
      headers: _headers(token),
      body: jsonEncode({
        'amount': amount,
        'method': method,
        'transaction_id': transactionId,
        'sender_number': senderNumber,
        'month': month,
        'year': year,
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final data = jsonDecode(response.body);
      throw BatchPaymentException(data['error'] ?? 'পেমেন্ট জমা দেওয়া যায়নি');
    }
  }
}

class BatchPaymentException implements Exception {
  final String message;
  BatchPaymentException(this.message);

  @override
  String toString() => message;
}
