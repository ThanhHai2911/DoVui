import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dovui/models/category_model.dart';
import '../models/question_model.dart';

class QuizService {
  static final _firestore = FirebaseFirestore.instance;

  /// LOAD QUESTIONS (Array trong document)
  static Future<List<QuestionModel>> getQuestions(
      String categoryId) async {
    try {
      final doc = await _firestore
          .collection("categories")
          .doc(categoryId)
          .get();

      if (!doc.exists) return [];

      final data = doc.data();
      if (data == null) return [];

      final questionsData = data["questions"];

      if (questionsData == null || questionsData is! List) {
        return [];
      }

      return questionsData
          .whereType<Map<String, dynamic>>()
          .map((e) => QuestionModel.fromMap(e))
          .toList();
    } catch (e) {
      print("Error loading questions: $e");
      return [];
    }
  }

  static Future<List<CategoryModel>> getCategories() async {
  try {
    final snapshot =
        await FirebaseFirestore.instance.collection("Categories").get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      return CategoryModel(
        id: doc.id,
        name: data["name"] ?? "",
        image: data["image"] ?? "",
      );
    }).toList();
  } catch (e) {
    print("Error loading categories: $e");
    return [];
  }
}

  /// SAVE SCORE
  static Future<void> saveScore(int score, int total) async {
    try {
      await _firestore.collection("scores").add({
        "score": score,
        "total": total,
        "createdAt": Timestamp.now(),
      });
    } catch (e) {
      print("Error saving score: $e");
    }
  }
}