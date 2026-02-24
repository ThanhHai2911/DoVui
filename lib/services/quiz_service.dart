import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/question_model.dart';

class QuizService {
  static Future<List<QuestionModel>> getQuestions(String categoryId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection("categories")
        .doc(categoryId)
        .get();

    if (!snapshot.exists) return [];

    final data = snapshot.data();
    final List list = data?["questions"] ?? [];

    return list.map((e) => QuestionModel.fromMap(e)).toList();
  }

  static Future<void> saveScore(int score, int total) async {
    await FirebaseFirestore.instance.collection("scores").add({
      "score": score,
      "total": total,
      "createdAt": Timestamp.now(),
    });
  }
}