import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dovui/data/models/topic_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../data/models/category_model.dart';
import '../data/models/man_model.dart';
import '../data/models/question_model.dart';
import 'package:http/http.dart' as http;

class QuizService {
  static final _firestore = FirebaseFirestore.instance;

  /// ===============================
  /// LOAD CATEGORIES
  /// ===============================
  static Stream<List<CategoryModel>> getCategories() {
    return _firestore.collection("categories").orderBy("order").snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();

          return CategoryModel(
            id: doc.id,
            name: data["name"] ?? "",
            image: data["image"] ?? "",
            order: data["order"] ?? 0,
            type: data["type"] ?? "direct",
          );
        }).toList();
      },
    );
  }

  /// ===============================
  /// LOAD QUESTIONS (AUTO HANDLE)
  /// ===============================
  static Stream<List<QuestionModel>> getQuestions({
    required String categoryId,
    String? levelId,
    required String type,
  }) {
    /// ===== DIRECT MODE =====
    if (type == "direct") {
      return _firestore
          .collection("categories")
          .doc(categoryId)
          .snapshots()
          .map((doc) {
            if (!doc.exists) return [];

            final data = doc.data();
            if (data == null) return [];

            final questionsData = data["questions"];
            if (questionsData is! List) return [];

            return questionsData
                .whereType<Map<String, dynamic>>()
                .map((e) => QuestionModel.fromMap(e))
                .toList();
          });
    } else {
      return _firestore
          .collection("categories")
          .doc(categoryId)
          .collection("mans")
          .doc(levelId)
          .collection("questions")
          .orderBy("order")
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => QuestionModel.fromMap(doc.data()))
                .toList();
          });
    }
  }

  /// ===============================
  /// LOAD LEVELS (LEVEL MODE)
  /// ===============================
  static Stream<List<LevelModel>> getLevels(String categoryId) {
    return _firestore
        .collection("categories")
        .doc(categoryId)
        .collection("mans")
        .orderBy("order")
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return LevelModel(id: doc.id, name: data["name"] ?? "");
          }).toList();
        });
  }

  static Future<List<LevelModel>> getLevelsOnce(String categoryId) async {
    try {
      final snapshot =
          await _firestore
              .collection("categories")
              .doc(categoryId)
              .collection("mans")
              .orderBy("order")
              .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return LevelModel(id: doc.id, name: data["name"] ?? "");
      }).toList();
    } catch (e) {
      print("❌ LOAD LEVEL ERROR: $e");
      return [];
    }
  }

  /// ===============================
  /// LOAD TOPICS (IT MODE)
  /// ===============================
  static Stream<List<TopicModel>> getTopics(String categoryId) {
    return _firestore
        .collection("categories")
        .doc(categoryId)
        .collection("Language")
        .orderBy("order")
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return TopicModel(
              id: doc.id,
              name: data["name"] ?? "",
              image: data["image"] ?? "",
              category: data['category'] ?? '',
            );
          }).toList();
        });
  }

  /// ===============================
  /// LOAD QUESTIONS (API)
  /// ===============================
  static Future<List<QuestionModel>> fetchQuestions(String category) async {
    final response = await http.get(
      Uri.parse(
        "https://quizapi.io/api/v1/questions?category=$category&limit=10",
      ),
      headers: {"X-Api-Key": dotenv.env['API_KEY']!},
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);

      return data.asMap().entries.map((entry) {
        int index = entry.key;
        var e = entry.value;

        var question = QuestionModel.fromQuizApi(e);

        return QuestionModel(
          question: question.question,
          answers: question.answers,
          correctIndex: question.correctIndex,
          order: index,
        );
      }).toList();
    } else {
      throw Exception("Failed to load questions");
    }
  }

  static Future<List<QuestionModel>> getQuestionsOnce({
    required String categoryId,
    String? levelId,
    required String type,
  }) async {
    // Lấy snapshot một lần, không lắng nghe realtime
    final snapshot =
        await QuizService.getQuestions(
          categoryId: categoryId,
          levelId: levelId,
          type: type,
        ).first; // ← chỉ lấy emit đầu tiên rồi dừng

    return snapshot;
  }

  static Future<void> addStarsToUser(int score) async {
    if (score <= 0) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).update({
      'score': FieldValue.increment(score),
    });
  }
}
