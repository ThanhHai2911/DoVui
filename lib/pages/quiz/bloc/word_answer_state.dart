import 'package:dovui/data/models/question_model.dart';
import '../logic/word_answer_controller.dart';

abstract class WordAnswerState {}

class WordAnswerLoading extends WordAnswerState {}

class WordAnswerLoaded extends WordAnswerState {
  final List<QuestionModel> questions;
  final QuestionModel question;
  final WordAnswerController controller;
  final int currentIndex;
  final int score;

  WordAnswerLoaded({
    required this.questions,
    required this.question,
    required this.controller,
    required this.currentIndex,
    required this.score,
  });
}

class WordAnswerCompleted extends WordAnswerState {
  final int score;
  final int total;

  WordAnswerCompleted(this.score, this.total);
}

class WordAnswerTimeUp extends WordAnswerState {
  final int score;
  final int total;

  WordAnswerTimeUp(this.score, this.total);
}