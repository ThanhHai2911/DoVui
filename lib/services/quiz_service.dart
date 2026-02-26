import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';
import '../models/man_model.dart';
import '../models/question_model.dart';

class QuizService {
  static final _firestore = FirebaseFirestore.instance;

  /// ===============================
  /// LOAD CATEGORIES
  /// ===============================
  static Stream<List<CategoryModel>> getCategories() {
  return _firestore
      .collection("categories")
      .orderBy("order")
      .snapshots()
      .map((snapshot) {
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
  });
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
    }
    else {
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
        return LevelModel(
          id: doc.id,
          name: data["name"] ?? "",
        );
      }).toList();
    });
  }
}