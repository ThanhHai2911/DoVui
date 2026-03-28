import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dovui/data/repositories/user_repository.dart';
import 'package:dovui/pages/word_answer/bloc/word_answer_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dovui/services/quiz_service.dart';
import 'package:dovui/data/models/question_model.dart';
import '../logic/word_answer_controller.dart';
import 'word_answer_event.dart';

class WordAnswerBloc extends Bloc<WordAnswerEvent, WordAnswerState> {
  final String categoryId;
  final String? levelId;
  final String type;
  final UserRepository userRepository = UserRepository();
  String? _userId; 
  bool _isInitialized = false;


  StreamSubscription<List<QuestionModel>>? _subscription;

  List<QuestionModel> _questions = [];
  int _currentIndex = 0;
  int _score = 0;

  WordAnswerController? _controller;

  WordAnswerBloc({
    required this.categoryId,
    required this.levelId,
    required this.type,
  }) : super(WordAnswerLoading()) {
    on<LoadQuestions>(_onLoadQuestions);
    on<_QuestionsLoaded>(_onQuestionsLoaded);
    on<NextQuestion>(_onNextQuestion);
    on<AnswerCorrect>(_onAnswerCorrect);
    on<TimeUp>(_onTimeUp);
    on<UseHintLetter>(_onUseHintLetter);
    on<UseSkip>(_onUseSkip);
    on<UseHintLetterFree>(_onUseHintLetterFree);
  }

  /// ================= LOAD =================

  Future<void> _onLoadQuestions(
  LoadQuestions event,
  Emitter<WordAnswerState> emit,
) async {
  emit(WordAnswerLoading());
  _userId = await userRepository.getCurrentUserId();

  // ← dùng get() thay vì listen()
  final questions = await QuizService.getQuestionsOnce(
    categoryId: categoryId,
    levelId: levelId,
    type: type,
  );

  add(_QuestionsLoaded(questions));
}

  Future<void> _syncScoreDelta(int delta) async {
  if (_userId == null) return;

  final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(_userId)
      .get();

  final currentScore = snapshot.data()?['score'] ?? 0;
  final newScore = (currentScore + delta).clamp(0, 99999);

  await userRepository.updateScore(_userId!, newScore);
}

  void _onQuestionsLoaded(
  _QuestionsLoaded event,
  Emitter<WordAnswerState> emit,
) {
  if (event.questions.isEmpty) return;

  _questions = event.questions;

  if (!_isInitialized) {        // ← chỉ reset lần đầu
    _currentIndex = 0;
    _score = 0;
    _isInitialized = true;
  }

  _loadCurrentQuestion(emit);
}

  /// ================= LOAD QUESTION =================

  void _loadCurrentQuestion(Emitter<WordAnswerState> emit) {
    if (_currentIndex >= _questions.length) {
      emit(WordAnswerCompleted(_score, _questions.length));
      return;
    }

    final q = _questions[_currentIndex];

    _controller?.dispose();

    _controller =
        WordAnswerController(q)
          ..onUpdate = () {
            add(NextQuestion());
          }
          ..onCorrect = () {
            add(AnswerCorrect());
          }
          ..onTimeUp = () {
            add(TimeUp());
          };

    _controller!.startTimer();

    emit(
      WordAnswerLoaded(
        questions: _questions,
        question: q,
        controller: _controller!,
        currentIndex: _currentIndex,
        score: _score,
      ),
    );
  }

  /// ================= REBUILD =================

  void _onNextQuestion(NextQuestion event, Emitter<WordAnswerState> emit) {
    if (_controller == null) return;

    emit(
      WordAnswerLoaded(
        questions: _questions,
        question: _questions[_currentIndex],
        controller: _controller!,
        currentIndex: _currentIndex,
        score: _score,
      ),
    );
  }
  /// ================= CORRECT =================
  void _onAnswerCorrect(AnswerCorrect event, Emitter<WordAnswerState> emit) {
    _score += 15;
    _currentIndex++;
    _loadCurrentQuestion(emit);
  }

  /// ================= TIME UP =================

  void _onTimeUp(TimeUp event, Emitter<WordAnswerState> emit) {
    emit(WordAnswerTimeUp(_score, _questions.length));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _controller?.dispose();
    return super.close();
  }

  void _onUseHintLetter(UseHintLetter event, Emitter<WordAnswerState> emit) {
    if (_controller == null) return;
    _score = (_score - 10).clamp(0, 99999);
    _syncScoreDelta(-50);  
    _controller!.revealOneWord();
    _rebuildLoaded(emit);
  }

void _onUseSkip(UseSkip event, Emitter<WordAnswerState> emit) {
  _score = (_score - 100).clamp(0, 99999);
  _syncScoreDelta(-100);
  _controller!.revealAllWords(); // ← hiển thị gợi ý
  _rebuildLoaded(emit);          // ← chỉ rebuild, không qua câu mới
}

  // ================= HINT FREE (từ ads) =================
  void _onUseHintLetterFree(
    UseHintLetterFree event,
    Emitter<WordAnswerState> emit,
  ) {
    if (_controller == null) return;
    _controller!.revealOneWord();
    _rebuildLoaded(emit);
  }

  void _rebuildLoaded(Emitter<WordAnswerState> emit) {
    if (_currentIndex >= _questions.length) return;
    emit(
      WordAnswerLoaded(
        questions: _questions,
        question: _questions[_currentIndex],
        controller: _controller!,
        currentIndex: _currentIndex,
        score: _score,
      ),
    );
  }
}

/// ================= PRIVATE EVENT =================

class _QuestionsLoaded extends WordAnswerEvent {
  final List<QuestionModel> questions;

  _QuestionsLoaded(this.questions);
}
