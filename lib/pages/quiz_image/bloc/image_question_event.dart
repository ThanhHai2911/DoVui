part of 'image_question_bloc.dart';

abstract class QuizImageEvent {}

class QuizImageLoadQuestions extends QuizImageEvent {}

class QuizImageSelectLetter extends QuizImageEvent {
  final int index;
  QuizImageSelectLetter(this.index);
}

class QuizImageRemoveLetter extends QuizImageEvent {
  final int index;
  QuizImageRemoveLetter(this.index);
}

class QuizImageTimerTick extends QuizImageEvent {}

class QuizImageUseHintLetter extends QuizImageEvent {}

class QuizImageUseHintLetterFree extends QuizImageEvent {}

class QuizImageUseSkip extends QuizImageEvent {}
class QuizImagePauseTimer extends QuizImageEvent {}
class QuizImageResumeTimer extends QuizImageEvent {}
class QuizImageUseSkipFree extends QuizImageEvent {}