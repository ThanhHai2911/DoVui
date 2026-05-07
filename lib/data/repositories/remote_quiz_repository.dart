import '../models/category_model.dart';
import '../models/man_model.dart';
import '../models/question_model.dart';
import '../models/topic_model.dart';
import 'quiz_repository.dart';

/// Dùng khi chuyển sang REST API server.
/// Chỉ cần implement các method bên dưới, UI không cần sửa gì.
class RemoteQuizRepository implements IQuizRepository {
  final String baseUrl; // ví dụ: "https://api.yourserver.com"
  final String Function() getToken; // hàm lấy JWT token

  RemoteQuizRepository({
    required this.baseUrl,
    required this.getToken,
  });

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${getToken()}',
      };

  @override
  Stream<List<CategoryModel>> getCategories() {
    // TODO: polling hoặc WebSocket nếu cần realtime
    // Tạm thời dùng Future convert sang Stream
    return Stream.fromFuture(_fetchCategories());
  }

  Future<List<CategoryModel>> _fetchCategories() async {
    // TODO: http.get("$baseUrl/categories", headers: _headers)
    throw UnimplementedError();
  }

  @override
  Stream<List<QuestionModel>> getQuestions({
    required String categoryId,
    String? levelId,
    required String type,
  }) {
    // TODO: implement
    throw UnimplementedError();
  }

  @override
  Future<List<QuestionModel>> getQuestionsOnce({
    required String categoryId,
    String? levelId,
    required String type,
  }) {
    // TODO: http.get("$baseUrl/questions?categoryId=$categoryId...")
    throw UnimplementedError();
  }

  @override
  Future<List<QuestionModel>> fetchQuestionsFromApi(String category) {
    // TODO: implement nếu vẫn dùng quizapi.io
    throw UnimplementedError();
  }

  @override
  Stream<List<LevelModel>> getLevels(String categoryId) {
    throw UnimplementedError();
  }

  @override
  Future<List<LevelModel>> getLevelsOnce(String categoryId) {
    throw UnimplementedError();
  }

  @override
  Stream<List<TopicModel>> getTopics(String categoryId) {
    throw UnimplementedError();
  }

  @override
  Future<void> addStarsToUser(int score) {
    // TODO: http.post("$baseUrl/users/score/add", body: {"score": score})
    throw UnimplementedError();
  }

  @override
  Future<int> getUserScore() {
    // TODO: http.get("$baseUrl/users/score")
    throw UnimplementedError();
  }

  @override
  Future<bool> deductStars(int amount) {
    // TODO: http.post("$baseUrl/users/score/deduct", body: {"amount": amount})
    throw UnimplementedError();
  }
}