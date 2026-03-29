import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  int _score = 0;

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

  // ================= USER SCORE SYNC =================

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

  // ================= SETUP =================

  void _setupController(ImageQuestion question) {
    _controller?.dispose();
    _controller = QuizImageController(question);

    _controller!.onUpdate = () {
      if (!isClosed) add(QuizImageTimerTick());
    };

    _controller!.onCorrect = () {
      _score += 10;
      _syncScoreDelta(10); // cộng điểm user
      _nextQuestion();
    };

    _controller!.onTimeUp = () {
      if (!isClosed) {
        emit(QuizImageTimeUp(score: _score, total: _questions.length));
      }
    };

    _controller!.startTimer();
  }

  void _nextQuestion() {
    _controller?.stopTimer();

    if (_currentIndex + 1 >= _questions.length) {
      emit(QuizImageCompleted(score: _score, total: _questions.length));
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
      score: _score, // nhớ truyền score ra UI
    ));
  }

  // ================= LOAD =================

  Future<void> _onLoad(
    QuizImageLoadQuestions event,
    Emitter<QuizImageState> emit,
  ) async {
    emit(QuizImageLoading());

    try {
      _userId = await userRepository.getCurrentUserId();

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
      _score = 0;

      _setupController(_questions[_currentIndex]);
      _emitLoaded();
    } catch (e) {
      emit(QuizImageError("Lỗi tải câu hỏi: $e"));
    }
  }

  // ================= ACTION =================

  void _onSelectLetter(
    QuizImageSelectLetter event,
    Emitter<QuizImageState> emit,
  ) {
    _controller?.selectLetter(event.index);
  }

  void _onRemoveLetter(
    QuizImageRemoveLetter event,
    Emitter<QuizImageState> emit,
  ) {
    _controller?.removeLetter(event.index);
  }

  void _onTimerTick(
    QuizImageTimerTick event,
    Emitter<QuizImageState> emit,
  ) {
    _emitLoaded();
  }

  // ================= HINT =================

  void _onUseHintLetter(
    QuizImageUseHintLetter event,
    Emitter<QuizImageState> emit,
  ) {
    if (_controller == null) return;

    _score = (_score - 50).clamp(0, 99999);
    _syncScoreDelta(-50);
    _controller!.revealOneWord();
    _emitLoaded();
  }

  void _onUseHintLetterFree(
    QuizImageUseHintLetterFree event,
    Emitter<QuizImageState> emit,
  ) {
    _controller?.revealOneWord();
    _emitLoaded();
  }

  void _onUseSkip(
    QuizImageUseSkip event,
    Emitter<QuizImageState> emit,
  ) {
    if (_controller == null) return;

    _score = (_score - 100).clamp(0, 99999);
    _syncScoreDelta(-100);

    _controller!.revealAllWords();
    _emitLoaded();
  }

  // ================= DISPOSE =================

  @override
  Future<void> close() {
    _controller?.dispose();
    return super.close();
  }
}