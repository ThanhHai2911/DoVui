import 'package:equatable/equatable.dart';

abstract class WordAnswerEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadWordQuiz extends WordAnswerEvent {
  final String categoryId;
  final String? levelId;
  final String type;

  LoadWordQuiz({
    required this.categoryId,
    this.levelId,
    required this.type,
  });
}

class SelectLetter extends WordAnswerEvent {
  final String letter;

  SelectLetter(this.letter);

  @override
  List<Object?> get props => [letter];
}

class RemoveLetter extends WordAnswerEvent {
  final int index;

  RemoveLetter(this.index);

  @override
  List<Object?> get props => [index];
}

class LoadQuestions extends WordAnswerEvent {}

class NextQuestion extends WordAnswerEvent {}

class AnswerCorrect extends WordAnswerEvent {}

class TimeUp extends WordAnswerEvent {}