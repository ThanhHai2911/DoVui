part of 'image_question_bloc.dart';

abstract class QuizImageState {}

class QuizImageInitial extends QuizImageState {}

class QuizImageLoading extends QuizImageState {}

class QuizImageLoaded extends QuizImageState {
  final QuizImageController controller;
  final List<ImageQuestion> questions;
  final int currentIndex;
  final int score;

  QuizImageLoaded({
    required this.controller,
    required this.questions,
    required this.currentIndex, 
    required this.score,
  });

  ImageQuestion get question => questions[currentIndex];
}

class QuizImageCompleted extends QuizImageState {
  final int score;
  final int total;

  QuizImageCompleted({required this.score, required this.total});
}

class QuizImageTimeUp extends QuizImageState {
  final int score;
  final int total;

  QuizImageTimeUp({required this.score, required this.total});
}

class QuizImageError extends QuizImageState {
  final String message;
  QuizImageError(this.message);
}
