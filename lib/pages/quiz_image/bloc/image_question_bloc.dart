import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:dovui/data/models/image_question_model.dart';
import 'package:dovui/data/repositories/image_question_repository.dart';
import 'package:dovui/data/repositories/user_repository.dart';
import 'package:dovui/pages/quiz_image/logic/quiz_image_contoller.dart';

part 'image_question_event.dart';
part 'image_question_state.dart';

class QuizImageBloc extends Bloc<QuizImageEvent, QuizImageState> {
  final String categoryId;
  final String? levelId;
  final String type;

  final ImageQuestionRepository _repo = ImageQuestionRepository();
  final UserRepository userRepository = UserRepository();

  List<ImageQuestion> _questions = [];
  int _currentIndex = 0;
  int _gameEarned = 0;

  /// Điểm thực tế trên Firebase — dùng để check đủ tiền mua hint
  int _firebaseScore = 0;

  /// Màn hình đọc điểm này để kiểm tra trước khi show dialog hint
  int get currentScore => _firebaseScore;

  String? _userId;
  QuizImageController? _controller;

  QuizImageBloc({
    required this.categoryId,
    required this.levelId,
    required this.type,
  }) : super(QuizImageInitial()) {
    on<QuizImageLoadQuestions>(_onLoad);
    on<QuizImageSelectLetter>(_onSelectLetter);
    on<QuizImageRemoveLetter>(_onRemoveLetter);
    on<QuizImageTimerTick>(_onTimerTick);
    on<QuizImageUseHintLetter>(_onUseHintLetter);
    on<QuizImageUseHintLetterFree>(_onUseHintLetterFree);
    on<QuizImageUseSkip>(_onUseSkip);
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

  void _setupController(ImageQuestion question) {
    _controller?.dispose();
    _controller = QuizImageController(question);

    _controller!.onUpdate = () {
      if (!isClosed) add(QuizImageTimerTick());
    };

    _controller!.onCorrect = () {
      _gameEarned += 10;
      _nextQuestion();
    };

    _controller!.onTimeUp = () {
      if (!isClosed) {
        _syncFinalEarned();
        emit(QuizImageTimeUp(score: _gameEarned, total: _questions.length));
      }
    };

    _controller!.startTimer();
  }

  void _nextQuestion() {
    _controller?.stopTimer();

    if (_currentIndex + 1 >= _questions.length) {
      _syncFinalEarned();
      emit(QuizImageCompleted(score: _gameEarned, total: _questions.length));
      return;
    }

    _currentIndex++;
    _setupController(_questions[_currentIndex]);
    _emitLoaded();
  }

  void _emitLoaded() {
    if (_controller == null) return;
    emit(QuizImageLoaded(
      controller: _controller!,
      questions: _questions,
      currentIndex: _currentIndex,
      score: _gameEarned,
    ));
  }

  Future<void> _onLoad(
    QuizImageLoadQuestions event,
    Emitter<QuizImageState> emit,
  ) async {
    emit(QuizImageLoading());
    try {
      _userId = await userRepository.getCurrentUserId();

      // ✅ Load điểm Firebase thực tế để check hint
      if (_userId != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(_userId)
            .get();
        _firebaseScore = snapshot.data()?['score'] ?? 0;
      }

      _questions = await _repo.fetchQuestions(
        categoryId: categoryId,
        levelId: levelId,
        type: type,
      );

      if (_questions.isEmpty) {
        emit(QuizImageError("Không có câu hỏi nào."));
        return;
      }

      _currentIndex = 0;
      _gameEarned = 0;

      _setupController(_questions[_currentIndex]);
      _emitLoaded();
    } catch (e) {
      emit(QuizImageError("Lỗi tải câu hỏi: $e"));
    }
  }

  void _onSelectLetter(QuizImageSelectLetter event, Emitter<QuizImageState> emit) {
    _controller?.selectLetter(event.index);
  }

  void _onRemoveLetter(QuizImageRemoveLetter event, Emitter<QuizImageState> emit) {
    _controller?.removeLetter(event.index);
  }

  void _onTimerTick(QuizImageTimerTick event, Emitter<QuizImageState> emit) {
    _emitLoaded();
  }

  void _onUseHintLetter(QuizImageUseHintLetter event, Emitter<QuizImageState> emit) {
    if (_controller == null) return;
    _syncHintCost(50);
    _controller!.revealOneWord();
    _emitLoaded();
  }

  void _onUseHintLetterFree(QuizImageUseHintLetterFree event, Emitter<QuizImageState> emit) {
    _controller?.revealOneWord();
    _emitLoaded();
  }

  void _onUseSkip(QuizImageUseSkip event, Emitter<QuizImageState> emit) {
    if (_controller == null) return;
    _syncHintCost(100);
    _controller!.revealAllWords();
    _emitLoaded();
  }

  @override
  Future<void> close() {
    _controller?.dispose();
    return super.close();
  }
}