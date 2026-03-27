import 'package:dovui/pages/quiz/bloc/word_answer_event.dart';
import 'package:equatable/equatable.dart';

abstract class QuizEvent extends Equatable {
  const QuizEvent();

  @override
  List<Object?> get props => [];
}

class LoadQuiz extends QuizEvent {
  final String categoryId;
  final String? levelId;
  final String type;

  const LoadQuiz({
    required this.categoryId,
    required this.type,
    this.levelId,
  });
}

class SelectAnswer extends QuizEvent {
  final int index;
  const SelectAnswer(this.index);
}

class NextQuestion extends QuizEvent {}

class TimeTick extends QuizEvent {}

class TimeUp extends QuizEvent {}

class Tick extends WordAnswerEvent {}