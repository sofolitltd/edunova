import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class VocabularyWord {
  final int id;
  final String classLevel;
  final String word;
  final String meaning;
  final String meaningBn;
  final String exampleSentence;
  final String pronunciation;

  VocabularyWord({
    required this.id,
    required this.classLevel,
    required this.word,
    required this.meaning,
    required this.meaningBn,
    required this.exampleSentence,
    required this.pronunciation,
  });

  factory VocabularyWord.fromJson(Map<String, dynamic> json) {
    return VocabularyWord(
      id: json['id'] ?? 0,
      classLevel: json['class_level'] ?? '',
      word: json['word'] ?? '',
      meaning: json['meaning'] ?? '',
      meaningBn: json['meaning_bn'] ?? '',
      exampleSentence: json['example_sentence'] ?? '',
      pronunciation: json['pronunciation'] ?? '',
    );
  }
}

class QuizQuestion {
  final int wordId;
  final String word;
  final List<String> options;

  QuizQuestion({required this.wordId, required this.word, required this.options});

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      wordId: json['word_id'] ?? 0,
      word: json['word'] ?? '',
      options: ((json['options'] as List?) ?? []).map((o) => o.toString()).toList(),
    );
  }
}

class SentenceExercise {
  final int id;
  final String classLevel;
  final String prompt;
  final String sampleAnswer;

  SentenceExercise({
    required this.id,
    required this.classLevel,
    required this.prompt,
    required this.sampleAnswer,
  });

  factory SentenceExercise.fromJson(Map<String, dynamic> json) {
    return SentenceExercise(
      id: json['id'] ?? 0,
      classLevel: json['class_level'] ?? '',
      prompt: json['prompt'] ?? '',
      sampleAnswer: json['sample_answer'] ?? '',
    );
  }
}

class PracticeStats {
  final int totalPoints;
  final int level;
  final int pointsToNextLevel;
  final int currentStreak;
  final int longestStreak;
  final int quizAttempts;
  final int quizCorrect;
  final int flashcardsSeen;
  final int sentencesDone;

  PracticeStats({
    required this.totalPoints,
    required this.level,
    required this.pointsToNextLevel,
    required this.currentStreak,
    required this.longestStreak,
    required this.quizAttempts,
    required this.quizCorrect,
    required this.flashcardsSeen,
    required this.sentencesDone,
  });

  factory PracticeStats.fromJson(Map<String, dynamic> json) {
    return PracticeStats(
      totalPoints: json['total_points'] ?? 0,
      level: json['level'] ?? 1,
      pointsToNextLevel: json['points_to_next_level'] ?? 100,
      currentStreak: json['current_streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      quizAttempts: json['quiz_attempts'] ?? 0,
      quizCorrect: json['quiz_correct'] ?? 0,
      flashcardsSeen: json['flashcards_seen'] ?? 0,
      sentencesDone: json['sentences_done'] ?? 0,
    );
  }

  factory PracticeStats.empty() => PracticeStats(
        totalPoints: 0,
        level: 1,
        pointsToNextLevel: 100,
        currentStreak: 0,
        longestStreak: 0,
        quizAttempts: 0,
        quizCorrect: 0,
        flashcardsSeen: 0,
        sentencesDone: 0,
      );
}

class PracticeService {
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
  PracticeService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _headers(String? token) {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (token != null) h['Authorization'] = 'Bearer $token';
    return h;
  }

  Future<List<VocabularyWord>> getFlashcards(String? token) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/practice/flashcards'),
      headers: _headers(token),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as List;
      return data.map((w) => VocabularyWord.fromJson(w)).toList();
    }
    return [];
  }

  Future<void> reviewFlashcard(String? token, int wordId) async {
    await _client.post(
      Uri.parse('$_baseUrl/practice/flashcards/review'),
      headers: _headers(token),
      body: jsonEncode({'word_id': wordId}),
    );
  }

  Future<List<QuizQuestion>> getQuiz(String? token, {int count = 5}) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/practice/quiz?count=$count'),
      headers: _headers(token),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as List;
      return data.map((q) => QuizQuestion.fromJson(q)).toList();
    }
    return [];
  }

  Future<bool> submitQuizAttempt(String? token, int wordId, String selectedText) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/practice/quiz/attempt'),
      headers: _headers(token),
      body: jsonEncode({'word_id': wordId, 'selected_text': selectedText}),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return data['correct'] ?? false;
    }
    return false;
  }

  Future<List<SentenceExercise>> getSentenceExercises(String? token) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/practice/sentences'),
      headers: _headers(token),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as List;
      return data.map((e) => SentenceExercise.fromJson(e)).toList();
    }
    return [];
  }

  Future<String> submitSentenceAttempt(String? token, int exerciseId, String answer) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/practice/sentences/attempt'),
      headers: _headers(token),
      body: jsonEncode({'exercise_id': exerciseId, 'answer': answer}),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return data['sample_answer'] ?? '';
    }
    return '';
  }

  Future<PracticeStats> getStats(String? token) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/practice/stats'),
      headers: _headers(token),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return PracticeStats.fromJson(jsonDecode(response.body));
    }
    return PracticeStats.empty();
  }
}
