import 'package:dovui/data/repositories/quiz_repository.dart';

class QuizService {
  final IQuizRepository _repo;

  QuizService(this._repo);
  get getCategories => _repo.getCategories;
  get getQuestions => _repo.getQuestions;
  get getQuestionsOnce => _repo.getQuestionsOnce;
  get fetchQuestionsFromApi => _repo.fetchQuestionsFromApi;
  get getLevels => _repo.getLevels;
  get getLevelsOnce => _repo.getLevelsOnce;
  get getTopics => _repo.getTopics;
  get addStarsToUser => _repo.addStarsToUser;
  get getUserScore => _repo.getUserScore;
  get deductStars => _repo.deductStars;
}