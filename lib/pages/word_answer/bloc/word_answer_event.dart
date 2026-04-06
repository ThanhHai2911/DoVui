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
class UseHintLetter extends WordAnswerEvent {}   // 🔍 gợi ý chữ, trừ 10đ
class UseSkip extends WordAnswerEvent {}         // 🔑 bỏ qua, trừ 15đ
class UseHintLetterFree extends WordAnswerEvent {} // 🎬 gợi ý miễn phí từ ads
class PauseTimer extends WordAnswerEvent {}
class ResumeTimer extends WordAnswerEvent {}
class UseSkipFree extends WordAnswerEvent {} 