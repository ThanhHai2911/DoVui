import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dovui/services/quiz_service.dart';
import 'quiz_event.dart';
import 'quiz_state.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  StreamSubscription? _subscription;
  Timer? _timer;
  List<int> usedIndexes = [];

  QuizBloc() : super(const QuizState()) {
    on<LoadQuiz>(_onLoadQuiz);
    on<SelectAnswer>(_onSelectAnswer);
    on<NextQuestion>(_onNextQuestion);
    on<TimeTick>(_onTimeTick);
    on<TimeUp>(_onTimeUp);
  }

  Future<void> _onLoadQuiz(
      LoadQuiz event, Emitter<QuizState> emit) async {
    emit(state.copyWith(isLoading: true));

    await emit.forEach(
      QuizService.getQuestions(
        categoryId: event.categoryId,
        levelId: event.levelId,
        type: event.type,
      ),
      onData: (questions) {
        if (questions.isEmpty) {
          return state.copyWith(isLoading: false);
        }

        usedIndexes.clear();
        final randomIndex = Random().nextInt(questions.length);

        _startTimer();

        return state.copyWith(
          isLoading: false,
          questions: questions,
          currentQuestion: questions[randomIndex],
          questionCount: 1,
        );
      },
    );
  }

  void _startTimer() {
    _timer?.cancel();
    add(TimeTick());

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(TimeTick());
    });
  }

  void _onTimeTick(TimeTick event, Emitter<QuizState> emit) {
    if (state.timeLeft <= 1) {
      add(TimeUp());
    } else {
      emit(state.copyWith(timeLeft: state.timeLeft - 1));
    }
  }

  void _onTimeUp(TimeUp event, Emitter<QuizState> emit) {
    _timer?.cancel();

    final newLives = state.lives - 1;

    if (newLives <= 0) {
      emit(state.copyWith(
        lives: newLives,
        showResult: true,
        isGameOver: true,
      ));
      return;
    }

    emit(state.copyWith(
      lives: newLives,
      showResult: true,
    ));

    Future.delayed(const Duration(seconds: 1), () {
      add(NextQuestion());
    });
  }

  void _onSelectAnswer(
      SelectAnswer event, Emitter<QuizState> emit) {
    _timer?.cancel();

    final isCorrect =
        event.index == state.currentQuestion?.correctIndex;

    int newLives = state.lives;
    int newScore = state.score;

    if (isCorrect) {
      newScore++;
    } else {
      newLives--;
    }

    if (newLives <= 0) {
      emit(state.copyWith(
        selectedIndex: event.index,
        showResult: true,
        lives: newLives,
        isGameOver: true,
      ));
      return;
    }

    emit(state.copyWith(
      selectedIndex: event.index,
      showResult: true,
      lives: newLives,
      score: newScore,
    ));

    Future.delayed(const Duration(seconds: 1), () {
      add(NextQuestion());
    });
  }

  void _onNextQuestion(
      NextQuestion event, Emitter<QuizState> emit) {
    if (state.questions.isEmpty) return;

    if (usedIndexes.length == state.questions.length) {
      emit(state.copyWith(isGameOver: true, isWin: true));
      return;
    }

    int index;
    final random = Random();
    do {
      index = random.nextInt(state.questions.length);
    } while (usedIndexes.contains(index));

    usedIndexes.add(index);

    _startTimer();

    emit(state.copyWith(
      currentQuestion: state.questions[index],
      selectedIndex: null,
      showResult: false,
      questionCount: state.questionCount + 1,
      timeLeft: 15,
    ));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _timer?.cancel();
    return super.close();
  }
}