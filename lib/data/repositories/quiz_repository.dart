import '../models/category_model.dart';
import '../models/man_model.dart';
import '../models/question_model.dart';
import '../models/topic_model.dart';

abstract class IQuizRepository {
  // Categories
  Stream<List<CategoryModel>> getCategories();

  // Questions
  Stream<List<QuestionModel>> getQuestions({
    required String categoryId,
    String? levelId,
    required String type,
  });

  Future<List<QuestionModel>> getQuestionsOnce({
    required String categoryId,
    String? levelId,
    required String type,
  });

  Future<List<QuestionModel>> fetchQuestionsFromApi(String category);

  // Levels
  Stream<List<LevelModel>> getLevels(String categoryId);
  Future<List<LevelModel>> getLevelsOnce(String categoryId);

  // Topics
  Stream<List<TopicModel>> getTopics(String categoryId);

  // User Score
  Future<void> addStarsToUser(int score);
  Future<int> getUserScore();
  Future<bool> deductStars(int amount);
}