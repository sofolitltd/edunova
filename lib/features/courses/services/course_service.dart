import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Course {
  final int id;
  final String title;
  final String titleBn;
  final String description;
  final String subject;
  final String teacher;
  final String instructors;
  final String classLevel;
  final String type;
  final String schedule;
  final String color;
  final String gradient;
  final int price;
  final int oldPrice;
  final String duration;
  final String badge;
  final int studentsCount;
  final int classesCount;
  final int examsCount;
  final double rating;
  final int reviewsCount;
  final String curriculum;
  final String features;

  Course({
    required this.id,
    required this.title,
    required this.titleBn,
    required this.description,
    required this.subject,
    required this.teacher,
    required this.instructors,
    required this.classLevel,
    required this.type,
    required this.schedule,
    required this.color,
    required this.gradient,
    required this.price,
    required this.oldPrice,
    required this.duration,
    required this.badge,
    required this.studentsCount,
    required this.classesCount,
    required this.examsCount,
    required this.rating,
    required this.reviewsCount,
    this.curriculum = '',
    this.features = '',
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      titleBn: json['title_bn'] ?? '',
      description: json['description'] ?? '',
      subject: json['subject'] ?? '',
      teacher: json['teacher'] ?? '',
      instructors: json['instructors'] ?? '',
      classLevel: json['class_level'] ?? '',
      type: json['type'] ?? 'online',
      schedule: json['schedule'] ?? '',
      color: json['color'] ?? '#6366F1',
      gradient: json['gradient'] ?? 'from-primary to-primary-dark',
      price: json['price'] ?? 0,
      oldPrice: json['old_price'] ?? 0,
      duration: json['duration'] ?? '',
      badge: json['badge'] ?? '',
      studentsCount: json['students_count'] ?? 0,
      classesCount: json['classes_count'] ?? 0,
      examsCount: json['exams_count'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      reviewsCount: json['reviews_count'] ?? 0,
      curriculum: json['curriculum'] is String
          ? json['curriculum']
          : json['curriculum'] != null
              ? jsonEncode(json['curriculum'])
              : '',
      features: json['features'] is String
          ? json['features']
          : json['features'] != null
              ? jsonEncode(json['features'])
              : '',
    );
  }
}

class CourseService {
  static String get _baseUrl {
    if (kIsWeb) return 'http://localhost:8080/api';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8080/api';
      default:
        return 'http://localhost:8080/api';
    }
  }

  Future<List<Course>> getCourses({String? classLevel, String? type}) async {
    final params = <String, String>{};
    if (classLevel != null && classLevel != 'all') params['class_level'] = classLevel;
    if (type != null && type != 'all') params['type'] = type;

    final uri = params.isEmpty
        ? Uri.parse('$_baseUrl/courses')
        : Uri.parse('$_baseUrl/courses').replace(queryParameters: params);

    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = (data is List ? data : data['courses'] ?? []) as List;
      return list.map((c) => Course.fromJson(c)).toList();
    } else {
      throw Exception('Failed to load courses');
    }
  }

  Future<List<Course>> getFreeCourses() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/user/free-courses'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = (data is List ? data : data['courses'] ?? []) as List;
      return list.map((c) => Course.fromJson(c)).toList();
    } else {
      throw Exception('Failed to load free courses');
    }
  }

  Future<Course> getCourseById(int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/courses/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Course.fromJson(data);
    } else {
      throw Exception('Failed to load course');
    }
  }

  Future<void> enroll({
    required int courseId,
    required String fullName,
    required String mobile,
    int amount = 0,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/enrollments'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'course_id': courseId,
        'full_name': fullName,
        'mobile': mobile,
        'amount': amount,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Enrollment failed');
    }
  }

  Future<List<Enrollment>> getMyEnrollments(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/user/enrollments'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = data is List ? data : <dynamic>[];
      return list.map((e) => Enrollment.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load enrollments');
    }
  }
}

class Enrollment {
  final int id;
  final int courseId;
  final String courseName;
  final String courseType;
  final String fullName;
  final String mobile;
  final int? userId;
  final String paymentMethod;
  final String mobileBanking;
  final int amount;
  final String sentFrom;
  final String sentTo;
  final String referralSource;
  final String status;
  final String enrolledBy;
  final int? batchId;
  final String batchName;
  final String batchSchedule;
  final String createdAt;
  final String updatedAt;

  Enrollment({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.courseType,
    required this.fullName,
    required this.mobile,
    this.userId,
    required this.paymentMethod,
    required this.mobileBanking,
    required this.amount,
    required this.sentFrom,
    required this.sentTo,
    required this.referralSource,
    required this.status,
    required this.enrolledBy,
    this.batchId,
    required this.batchName,
    this.batchSchedule = '',
    required this.createdAt,
    required this.updatedAt,
  });

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    return Enrollment(
      id: json['id'] ?? 0,
      courseId: json['course_id'] ?? 0,
      courseName: json['course_name'] ?? '',
      courseType: json['course_type'] ?? '',
      fullName: json['full_name'] ?? '',
      mobile: json['mobile'] ?? '',
      userId: json['user_id'],
      paymentMethod: json['payment_method'] ?? '',
      mobileBanking: json['mobile_banking'] ?? '',
      amount: json['amount'] ?? 0,
      sentFrom: json['sent_from'] ?? '',
      sentTo: json['sent_to'] ?? '',
      referralSource: json['referral_source'] ?? '',
      status: json['status'] ?? 'pending',
      enrolledBy: json['enrolled_by'] ?? '',
      batchId: json['batch_id'],
      batchName: json['batch_name'] ?? '',
      batchSchedule: json['batch_schedule'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}
