import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dovui/data/repositories/user_repository.dart';
import 'package:dovui/pages/word_answer/bloc/word_answer_state.dart';
import 'package:flutter/foundation.dart';
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
  int _gameEarned = 0;

  /// Điểm thực tế trên Firebase — dùng để check đủ tiền mua hint
  int _firebaseScore = 0;

  /// Màn hình đọc điểm này để kiểm tra trước khi show dialog hint
  int get currentScore => _firebaseScore;

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
    on<PauseTimer>((event, emit) {
      // dừng timer
      _controller?.pauseTimer();
    });

    on<ResumeTimer>((event, emit) {
      // chạy lại timer nếu game đang chạy
      if (state is WordAnswerLoaded) {
        _controller?.resumeTimer();
      }
    });
    on<UseSkipFree>(_onUseSkipFree);
  }

  Future<void> _onLoadQuestions(
    LoadQuestions event,
    Emitter<WordAnswerState> emit,
  ) async {
    emit(WordAnswerLoading());
    _userId = await userRepository.getCurrentUserId();

    // ✅ Load điểm Firebase thực tế để check hint
    if (_userId != null) {
      try {
        final snapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(_userId)
                .get();
        _firebaseScore = snapshot.data()?['score'] ?? 0;
      } catch (e) {
        debugPrint('Load firebase score error: $e');
      }
    }

    final questions = await QuizService.getQuestionsOnce(
      categoryId: categoryId,
      levelId: levelId,
      type: type,
    );

    add(_QuestionsLoaded(questions));
  }

  // Trừ Firebase + cập nhật _firebaseScore local luôn (không fetch lại)
  Future<void> _syncHintCost(int cost) async {
    if (_userId == null) return;
    try {
      _firebaseScore = (_firebaseScore - cost).clamp(0, 99999);
      await userRepository.updateScore(_userId!, _firebaseScore);
    } catch (e) {
      debugPrint('Sync hint cost error: $e');
    }
  }

  // Cộng điểm đúng vào Firebase khi kết thúc
  Future<void> _syncFinalEarned() async {
    if (_userId == null || _gameEarned <= 0) return;
    try {
      _firebaseScore = (_firebaseScore + _gameEarned).clamp(0, 99999);
      await userRepository.updateScore(_userId!, _firebaseScore);
    } catch (e) {
      debugPrint('Sync final score error: $e');
    }
  }

  void _onQuestionsLoaded(
    _QuestionsLoaded event,
    Emitter<WordAnswerState> emit,
  ) {
    if (event.questions.isEmpty) return;

    _questions = event.questions;

    if (!_isInitialized) {
      _currentIndex = 0;
      _gameEarned = 0;
      _isInitialized = true;
    }

    _loadCurrentQuestion(emit);
  }

  void _loadCurrentQuestion(Emitter<WordAnswerState> emit) {
    if (_currentIndex >= _questions.length) {
      _syncFinalEarned();
      emit(WordAnswerCompleted(_gameEarned, _questions.length));
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
        score: _gameEarned,
      ),
    );
  }

  void _onNextQuestion(NextQuestion event, Emitter<WordAnswerState> emit) {
    if (_controller == null) return;
    emit(
      WordAnswerLoaded(
        questions: _questions,
        question: _questions[_currentIndex],
        controller: _controller!,
        currentIndex: _currentIndex,
        score: _gameEarned,
      ),
    );
  }

  void _onAnswerCorrect(AnswerCorrect event, Emitter<WordAnswerState> emit) {
    _gameEarned += 15;
    _currentIndex++;
    _loadCurrentQuestion(emit);
  }

  void _onTimeUp(TimeUp event, Emitter<WordAnswerState> emit) {
    _syncFinalEarned();
    emit(WordAnswerTimeUp(_gameEarned, _questions.length));
  }

  void _onUseHintLetter(UseHintLetter event, Emitter<WordAnswerState> emit) {
    if (_controller == null) return;
    _syncHintCost(50);
    _controller!.revealOneWord();
    _rebuildLoaded(emit);
  }

  void _onUseSkip(UseSkip event, Emitter<WordAnswerState> emit) {
    if (_controller == null) return;
    _syncHintCost(100);
    _controller!.revealAllWords();
    _rebuildLoaded(emit);
  }

  void _onUseHintLetterFree(
    UseHintLetterFree event,
    Emitter<WordAnswerState> emit,
  ) {
    if (_controller == null) return;
    _controller!.revealOneWord();
    _rebuildLoaded(emit);
  }
  void _onUseSkipFree(UseSkipFree event, Emitter<WordAnswerState> emit) {
  if (_controller == null) return;
  // KHÔNG gọi _syncHintCost — miễn phí vì đã xem ad
  _controller!.revealAllWords();
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
        score: _gameEarned,
      ),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _controller?.dispose();
    return super.close();
  }
}

class _QuestionsLoaded extends WordAnswerEvent {
  final List<QuestionModel> questions;
  _QuestionsLoaded(this.questions);
}
