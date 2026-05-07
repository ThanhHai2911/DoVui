import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dovui/data/repositories/quiz_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/category_model.dart';
import '../models/man_model.dart';
import '../models/question_model.dart';
import '../models/topic_model.dart';

class FirebaseQuizRepository implements IQuizRepository {
  final _firestore = FirebaseFirestore.instance;

  // ── Categories ──────────────────────────────────────────
  @override
  Stream<List<CategoryModel>> getCategories() {
    return _firestore
        .collection("categories")
        .orderBy("order")
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return CategoryModel(
                id: doc.id,
                name: data["name"] ?? "",
                image: data["image"] ?? "",
                order: data["order"] ?? 0,
                type: data["type"] ?? "direct",
              );
            }).toList());
  }

  // ── Questions ────────────────────────────────────────────
  @override
  Stream<List<QuestionModel>> getQuestions({
    required String categoryId,
    String? levelId,
    required String type,
  }) {
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
          .map((snapshot) => snapshot.docs
              .map((doc) => QuestionModel.fromMap(doc.data()))
              .toList());
    }
  }

  @override
  Future<List<QuestionModel>> getQuestionsOnce({
    required String categoryId,
    String? levelId,
    required String type,
  }) async {
    return getQuestions(
      categoryId: categoryId,
      levelId: levelId,
      type: type,
    ).first;
  }

  @override
  Future<List<QuestionModel>> fetchQuestionsFromApi(String category) async {
    final response = await http.get(
      Uri.parse(
          "https://quizapi.io/api/v1/questions?category=$category&limit=10"),
      headers: {"X-Api-Key": dotenv.env['API_KEY']!},
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.asMap().entries.map((entry) {
        final question = QuestionModel.fromQuizApi(entry.value);
        return QuestionModel(
          question: question.question,
          answers: question.answers,
          correctIndex: question.correctIndex,
          order: entry.key,
        );
      }).toList();
    } else {
      throw Exception("Failed to load questions");
    }
  }

  // ── Levels ───────────────────────────────────────────────
  @override
  Stream<List<LevelModel>> getLevels(String categoryId) {
    return _firestore
        .collection("categories")
        .doc(categoryId)
        .collection("mans")
        .orderBy("order")
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return LevelModel(id: doc.id, name: data["name"] ?? "");
            }).toList());
  }

  @override
  Future<List<LevelModel>> getLevelsOnce(String categoryId) async {
    try {
      final snapshot = await _firestore
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

  // ── Topics ───────────────────────────────────────────────
  @override
  Stream<List<TopicModel>> getTopics(String categoryId) {
    return _firestore
        .collection("categories")
        .doc(categoryId)
        .collection("Language")
        .orderBy("order")
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return TopicModel(
                id: doc.id,
                name: data["name"] ?? "",
                image: data["image"] ?? "",
                category: data['category'] ?? '',
              );
            }).toList());
  }

  // ── User Score ───────────────────────────────────────────
  @override
  Future<void> addStarsToUser(int score) async {
    if (score <= 0) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _firestore.collection('users').doc(uid).update({
      'score': FieldValue.increment(score),
    });
  }

  @override
  Future<int> getUserScore() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return 0;
    final doc = await _firestore.collection('users').doc(uid).get();
    return (doc.data()?['score'] as int?) ?? 0;
  }

  @override
  Future<bool> deductStars(int amount) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;

    final docRef = _firestore.collection('users').doc(uid);
    return _firestore.runTransaction<bool>((tx) async {
      final doc = await tx.get(docRef);
      final current = (doc.data()?['score'] as num?)?.toInt() ?? 0;
      if (current < amount) return false;
      tx.update(docRef, {'score': current - amount});
      return true;
    });
  }
}