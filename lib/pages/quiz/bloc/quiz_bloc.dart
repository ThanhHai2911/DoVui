import 'dart:async';
import 'dart:math';
import 'package:dovui/data/models/question_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dovui/services/quiz_service.dart';
import 'quiz_event.dart';
import 'quiz_state.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  Timer? _timer;
  List<int> usedIndexes = [];
  final QuizService quizService;

  QuizBloc({required this.quizService}) : super(const QuizState()) {
    on<LoadQuiz>(_onLoadQuiz);
    on<SelectAnswer>(_onSelectAnswer);
    on<NextQuestion>(_onNextQuestion);
    on<TimeTick>(_onTimeTick);
    on<TimeUp>(_onTimeUp);
    on<UseHint5050>(_onUseHint5050);
    on<UseHintEliminate>(_onUseHintEliminate);
    on<UseHintFree>(_onUseHintFree);
    on<PauseTimer>(_onPauseTimer);
    on<ResumeTimer>(_onResumeTimer);
  }

  Future<void> _onLoadQuiz(LoadQuiz event, Emitter<QuizState> emit) async {
    emit(state.copyWith(isLoading: true));

    // ✅ Thêm explicit type cho emit.forEach
await emit.forEach<List<QuestionModel>>(
  quizService.getQuestions(
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
    Future.microtask(() => _startTimer());

    return state.copyWith(
      isLoading: false,
      questions: questions,
      currentQuestion: questions[randomIndex],
      questionCount: 1,
      eliminatedIndexes: [],
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

  Future<void> _onTimeUp(TimeUp event, Emitter<QuizState> emit) async {
    _timer?.cancel();

    final newLives = state.lives - 1;

    if (newLives <= 0) {
      // ✅ Cộng điểm cuối game
      await quizService.addStarsToUser(state.score);

      emit(state.copyWith(lives: newLives, showResult: true, isGameOver: true));
      return;
    }

    emit(state.copyWith(lives: newLives, showResult: true));

    Future.delayed(const Duration(seconds: 1), () {
      if (!isClosed) {  // ← Add this check
        add(NextQuestion());
      }
    });
  }

  Future<void> _onSelectAnswer(
    SelectAnswer event,
    Emitter<QuizState> emit,
  ) async {
    _timer?.cancel();

    final isCorrect = event.index == state.currentQuestion?.correctIndex;

    int newLives = state.lives;
    int newScore = state.score;

    if (isCorrect) {
      newScore += 10;
    } else {
      newLives--;
    }

    if (newLives <= 0) {
      // ✅ Cộng điểm cuối game
      await quizService.addStarsToUser(newScore);

      emit(
        state.copyWith(
          selectedIndex: event.index,
          showResult: true,
          lives: newLives,
          score: newScore,
          isGameOver: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        selectedIndex: event.index,
        showResult: true,
        lives: newLives,
        score: newScore,
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (!isClosed) {  // ← Add this check
        add(NextQuestion());
      }
    });
  }

  Future<void> _onNextQuestion(
    NextQuestion event,
    Emitter<QuizState> emit,
  ) async {
    if (state.questions.isEmpty) return;

    if (usedIndexes.length == state.questions.length) {
      // ✅ Cộng điểm cuối game
      await quizService.addStarsToUser(state.score);

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

    emit(
      state.copyWith(
        currentQuestion: state.questions[index],
        selectedIndex: null,
        showResult: false,
        questionCount: state.questionCount + 1,
        timeLeft: 15,
        eliminatedIndexes: [],
      ),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  // ── 50/50: trừ 50 sao ─────────────────────────────────────
  Future<void> _onUseHint5050(
    UseHint5050 event,
    Emitter<QuizState> emit,
  ) async {
    final correct = state.currentQuestion?.correctIndex;
    if (correct == null) return;

    // Kiểm tra + trừ sao trên Firestore
    final success = await quizService.deductStars(50);
    if (!success) {
      emit(state.copyWith(hintError: 'not_enough_stars'));
      emit(state.copyWith(hintError: null)); // reset ngay
      return;
    }

    final wrongIndexes =
        [0, 1, 2, 3]
            .where((i) => i != correct && !state.eliminatedIndexes.contains(i))
            .toList()
          ..shuffle();

    final toEliminate = wrongIndexes.take(2).toList();

    emit(
      state.copyWith(
        eliminatedIndexes: [...state.eliminatedIndexes, ...toEliminate],
      ),
    );
  }

  // ── Lộ đáp án: trừ 100 sao ───────────────────────────────
  Future<void> _onUseHintEliminate(
    UseHintEliminate event,
    Emitter<QuizState> emit,
  ) async {
    final correct = state.currentQuestion?.correctIndex;
    if (correct == null) return;

    final success = await quizService.deductStars(100);
    if (!success) {
      emit(state.copyWith(hintError: 'not_enough_stars'));
      emit(state.copyWith(hintError: null));
      return;
    }

    final wrongIndexes = [0, 1, 2, 3].where((i) => i != correct).toList();
    emit(state.copyWith(eliminatedIndexes: wrongIndexes));
  }

  // ── Xem video: miễn phí, không trừ sao ───────────────────
  void _onUseHintFree(UseHintFree event, Emitter<QuizState> emit) {
    final correct = state.currentQuestion?.correctIndex;
    if (correct == null) return;
    final wrongIndexes = [0, 1, 2, 3].where((i) => i != correct).toList();
    emit(state.copyWith(eliminatedIndexes: wrongIndexes));
  }

  // Thêm 2 handler
  void _onPauseTimer(PauseTimer event, Emitter<QuizState> emit) {
    _timer?.cancel();
  }

  void _onResumeTimer(ResumeTimer event, Emitter<QuizState> emit) {
    _startTimer();
  }
}
