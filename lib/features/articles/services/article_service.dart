import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Article {
  final int id;
  final String title;
  final String content;
  final String category;
  final String imageUrl;
  final bool isPublished;
  final String createdAt;

  Article({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.imageUrl,
    required this.isPublished,
    required this.createdAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? '',
      imageUrl: json['image_url'] ?? '',
      isPublished: json['is_published'] ?? false,
      createdAt: json['created_at'] ?? '',
    );
  }
}

class ArticleService {
  static String get _baseUrl {
    if (kIsWeb) return 'http://localhost:8080/api';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8080/api';
      default:
        return 'http://localhost:8080/api';
    }
  }

  Future<List<Article>> getPublishedArticles() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/articles'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final articles = (data is List ? data : data['articles'] ?? []) as List;
      return articles.map((a) => Article.fromJson(a)).toList();
    } else {
      throw Exception('Failed to load articles');
    }
  }
}
