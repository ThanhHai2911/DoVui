import 'dart:async';
import 'package:dovui/presentation/quiz/bloc/word_answer_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dovui/services/quiz_service.dart';
import 'package:dovui/data/models/question_model.dart';
import '../logic/word_answer_controller.dart';
import 'word_answer_event.dart';

class WordAnswerBloc extends Bloc<WordAnswerEvent, WordAnswerState> {
  final String categoryId;
  final String? levelId;
  final String type;

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
  }

  /// ================= LOAD =================

  void _onLoadQuestions(
      LoadQuestions event, Emitter<WordAnswerState> emit) {
    emit(WordAnswerLoading());

    _subscription?.cancel();

    _subscription = QuizService.getQuestions(
      categoryId: categoryId,
      levelId: levelId,
      type: type,
    ).listen((data) {
      add(_QuestionsLoaded(data));
    });
  }

  void _onQuestionsLoaded(
      _QuestionsLoaded event, Emitter<WordAnswerState> emit) {
    if (event.questions.isEmpty) return;

    _questions = event.questions;
    _currentIndex = 0;
    _score = 0;

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

    _controller = WordAnswerController(q)
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

  void _onNextQuestion(
      NextQuestion event, Emitter<WordAnswerState> emit) {
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

  void _onAnswerCorrect(
      AnswerCorrect event, Emitter<WordAnswerState> emit) {
    _score++;
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
}

/// ================= PRIVATE EVENT =================

class _QuestionsLoaded extends WordAnswerEvent {
  final List<QuestionModel> questions;

  _QuestionsLoaded(this.questions);
}