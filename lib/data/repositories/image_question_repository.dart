import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dovui/data/models/image_question_model.dart';

class ImageQuestionRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Path: categories/{categoryId}/mans/{levelId}/questions
  Future<List<ImageQuestion>> fetchQuestions({
    required String categoryId,
    String? levelId,
    String? type,
  }) async {
    try {
      final CollectionReference col = levelId != null
          ? _db
              .collection('categories')
              .doc(categoryId)
              .collection('mans')
              .doc(levelId)
              .collection('questions')
          : _db
              .collection('categories')
              .doc(categoryId)
              .collection('questions');

      final snapshot = await col.orderBy('order').get();

      print('📦 Fetched ${snapshot.docs.length} questions | path: categories/$categoryId/mans/$levelId/questions');

      return snapshot.docs
          .map((doc) => ImageQuestion.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ ImageQuestionRepository error: $e');
      throw Exception('ImageQuestionRepository.fetchQuestions lỗi: $e');
    }
  }
}
