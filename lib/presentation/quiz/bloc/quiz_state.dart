import 'package:equatable/equatable.dart';
import 'package:dovui/data/models/question_model.dart';

class QuizState extends Equatable {
  final bool isLoading;
  final List<QuestionModel> questions;
  final QuestionModel? currentQuestion;
  final int score;
  final int lives;
  final int questionCount;
  final int? selectedIndex;
  final bool showResult;
  final int timeLeft;
  final bool isGameOver;
  final bool isWin;

  const QuizState({
    this.isLoading = true,
    this.questions = const [],
    this.currentQuestion,
    this.score = 0,
    this.lives = 3,
    this.questionCount = 0,
    this.selectedIndex,
    this.showResult = false,
    this.timeLeft = 15,
    this.isGameOver = false,
    this.isWin = false,
  });

  QuizState copyWith({
    bool? isLoading,
    List<QuestionModel>? questions,
    QuestionModel? currentQuestion,
    int? score,
    int? lives,
    int? questionCount,
    int? selectedIndex,
    bool? showResult,
    int? timeLeft,
    bool? isGameOver,
    bool? isWin,
  }) {
    return QuizState(
      isLoading: isLoading ?? this.isLoading,
      questions: questions ?? this.questions,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      score: score ?? this.score,
      lives: lives ?? this.lives,
      questionCount: questionCount ?? this.questionCount,
      selectedIndex: selectedIndex,
      showResult: showResult ?? this.showResult,
      timeLeft: timeLeft ?? this.timeLeft,
      isGameOver: isGameOver ?? this.isGameOver,
      isWin: isWin ?? this.isWin,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        questions,
        currentQuestion,
        score,
        lives,
        questionCount,
        selectedIndex,
        showResult,
        timeLeft,
        isGameOver,
        isWin,
      ];
}