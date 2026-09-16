import 'dart:developer';

import '../../../shared/services/api_client.dart';

class AuthService {
  final ApiClient _api;

  AuthService({ApiClient? api}) : _api = api ?? ApiClient();

  Future<void> register({
    required String fullName,
    required String mobile,
    required String password,
    required String studentClass,
  }) async {
    try {
      log('Registering user: $mobile', name: 'AuthService');
      await _api.post('/register', body: {
        'full_name': fullName,
        'mobile': mobile,
        'password': password,
        'student_class': studentClass,
      });
      log('Registration successful: $mobile', name: 'AuthService');
    } on ApiException catch (e) {
      log('Registration failed: ${e.message}', name: 'AuthService', error: e);
      throw AuthException(e.message);
    }
  }

  Future<AuthResult> login({
    required String mobile,
    required String password,
  }) async {
    try {
      log('Logging in: $mobile', name: 'AuthService');
      final data = await _api.post('/login', body: {
        'mobile': mobile,
        'password': password,
      });

      log('Login successful: $mobile', name: 'AuthService');
      return AuthResult(
        token: data['token'],
        user: data['user'] != null ? User.fromJson(data['user']) : null,
      );
    } on ApiException catch (e) {
      log('Login failed: ${e.message}', name: 'AuthService', error: e);
      throw AuthException(e.message);
    }
  }

  Future<void> verifyOTP({
    required String mobile,
    required String code,
  }) async {
    try {
      log('Verifying OTP for: $mobile', name: 'AuthService');
      await _api.post('/verify-otp', body: {
        'mobile': mobile,
        'code': code,
      });
      log('OTP verified: $mobile', name: 'AuthService');
    } on ApiException catch (e) {
      log('OTP verification failed: ${e.message}', name: 'AuthService', error: e);
      throw AuthException(e.message);
    }
  }

  Future<void> resendOTP({required String mobile}) async {
    try {
      log('Resending OTP to: $mobile', name: 'AuthService');
      await _api.post('/resend-otp', body: {
        'mobile': mobile,
      });
      log('OTP resent: $mobile', name: 'AuthService');
    } on ApiException catch (e) {
      log('Resend OTP failed: ${e.message}', name: 'AuthService', error: e);
      throw AuthException(e.message);
    }
  }

  Future<User> getUser(String token) async {
    try {
      log('Fetching user profile', name: 'AuthService');
      final data = await _api.get('/user', token: token);
      return User.fromJson(data);
    } on ApiException catch (e) {
      log('Fetch user failed: ${e.message}', name: 'AuthService', error: e);
      throw AuthException(e.message);
    }
  }

  Future<void> changePassword({
    required String token,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      log('Changing password', name: 'AuthService');
      await _api.put('/change-password', body: {
        'old_password': oldPassword,
        'new_password': newPassword,
      }, token: token);
      log('Password changed', name: 'AuthService');
    } on ApiException catch (e) {
      log('Change password failed: ${e.message}', name: 'AuthService', error: e);
      throw AuthException(e.message);
    }
  }

  Future<User> updateProfile({
    required String token,
    required String fullName,
    String fatherName = '',
    String fatherMobile = '',
    String motherName = '',
    String motherMobile = '',
    String notificationMobile = '',
    String gender = '',
    String religion = '',
    String studentClass = '',
    String shift = '',
    String school = '',
    String address = '',
  }) async {
    try {
      log('Updating profile', name: 'AuthService');
      final data = await _api.put('/user/profile', body: {
        'full_name': fullName,
        'father_name': fatherName,
        'father_mobile': fatherMobile,
        'mother_name': motherName,
        'mother_mobile': motherMobile,
        'notification_mobile': notificationMobile,
        'gender': gender,
        'religion': religion,
        'student_class': studentClass,
        'shift': shift,
        'school': school,
        'address': address,
      }, token: token);
      log('Profile updated', name: 'AuthService');
      return User.fromJson(data);
    } on ApiException catch (e) {
      log('Update profile failed: ${e.message}', name: 'AuthService', error: e);
      throw AuthException(e.message);
    }
  }

  Future<Map<String, dynamic>> getDashboardStats(String token) async {
    try {
      log('Fetching dashboard stats', name: 'AuthService');
      return await _api.get('/user/dashboard', token: token);
    } on ApiException catch (e) {
      log('Fetch dashboard stats failed: ${e.message}', name: 'AuthService', error: e);
      throw AuthException(e.message);
    }
  }

  Future<void> registerDeviceToken({
    required String token,
    required String fcmToken,
    String platform = 'android',
  }) async {
    try {
      log('Registering device token', name: 'AuthService');
      await _api.post('/device-token', body: {
        'token': fcmToken,
        'platform': platform,
      }, token: token);
      log('Device token registered', name: 'AuthService');
    } on ApiException catch (e) {
      log('Device token registration failed: ${e.message}', name: 'AuthService', error: e);
      throw AuthException(e.message);
    }
  }
}

class AuthResult {
  final String? token;
  final User? user;

  AuthResult({this.token, this.user});
}

class User {
  final int id;
  final String fullName;
  final String mobile;
  final bool verified;
  final String fatherName;
  final String fatherMobile;
  final String motherName;
  final String motherMobile;
  final String notificationMobile;
  final String gender;
  final String religion;
  final String studentClass;
  final String shift;
  final String school;
  final String address;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.fullName,
    required this.mobile,
    required this.verified,
    this.fatherName = '',
    this.fatherMobile = '',
    this.motherName = '',
    this.motherMobile = '',
    this.notificationMobile = '',
    this.gender = '',
    this.religion = '',
    this.studentClass = '',
    this.shift = '',
    this.school = '',
    this.address = '',
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? '',
      mobile: json['mobile'] ?? '',
      verified: json['verified'] ?? false,
      fatherName: json['father_name'] ?? '',
      fatherMobile: json['father_mobile'] ?? '',
      motherName: json['mother_name'] ?? '',
      motherMobile: json['mother_mobile'] ?? '',
      notificationMobile: json['notification_mobile'] ?? '',
      gender: json['gender'] ?? '',
      religion: json['religion'] ?? '',
      studentClass: json['student_class'] ?? '',
      shift: json['shift'] ?? '',
      school: json['school'] ?? '',
      address: json['address'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  bool get isProfileComplete {
    return fullName.isNotEmpty &&
        gender.isNotEmpty &&
        religion.isNotEmpty &&
        studentClass.isNotEmpty &&
        shift.isNotEmpty &&
        school.isNotEmpty &&
        address.isNotEmpty &&
        fatherName.isNotEmpty &&
        fatherMobile.isNotEmpty;
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}