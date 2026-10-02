import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String _prodUrl = 'https://edunova-server.vercel.app/api';

  /// Override at build/run time with:
  /// flutter run --dart-define=API_BASE_URL=http://192.168.1.50:8080/api
  static const String _overrideUrl = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_overrideUrl.isNotEmpty) {
      return _overrideUrl;
    }

    // Release builds (web, Android, iOS) always talk to the deployed server —
    // "localhost"/"10.0.2.2" only resolve on a dev machine or emulator, so a
    // release build using them can never reach the backend from a real device
    // or over mobile data.
    if (kReleaseMode) {
      return _prodUrl;
    }

    if (kIsWeb) {
      return 'http://localhost:8080/api';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8080/api';
      default:
        return 'http://localhost:8080/api';
    }
  }

  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body, String? token}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    log('POST $baseUrl$path', name: 'API');
    if (body != null) log('Body: $body', name: 'API');

    final response = await _client.post(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );

    log('Response [${response.statusCode}]: ${response.body}', name: 'API');

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      final message = data['error'] ?? data['message'] ?? 'Request failed (${response.statusCode})';
      log('API Error [$path]: $message', name: 'API', level: 1000);
      throw ApiException(
        statusCode: response.statusCode,
        message: message,
      );
    }
  }

  Future<Map<String, dynamic>> get(String path, {String? token}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    log('GET $baseUrl$path', name: 'API');

    final response = await _client.get(
      Uri.parse('$baseUrl$path'),
      headers: headers,
    );

    log('Response [${response.statusCode}]: ${response.body}', name: 'API');

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: data['error'] ?? 'Unknown error',
      );
    }
  }

  Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? body, String? token}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    log('PUT $baseUrl$path', name: 'API');
    if (body != null) log('Body: $body', name: 'API');

    final response = await _client.put(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );

    log('Response [${response.statusCode}]: ${response.body}', name: 'API');

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: data['error'] ?? 'Unknown error',
      );
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => message;
}