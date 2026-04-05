import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dovui/pages/quiz/bloc/quiz_bloc.dart';
import 'package:dovui/pages/quiz/bloc/quiz_event.dart';
import 'package:dovui/pages/quiz/bloc/quiz_state.dart';
import 'package:dovui/data/models/question_model.dart';

part 'millionaire_event.dart';
part 'millionaire_state.dart';

const List<int> kPrizeLevels = [
  10, 20, 30, 50, 100,
  200, 300, 500, 650, 800,
  1000, 1200, 1500, 2000, 3000,
];
const List<int> kSafeMilestones = [5, 10];

class MillionaireBloc extends Bloc<MillionaireEvent, MillionaireState> {
  final QuizBloc _quizBloc;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Timer? _timer;
  String _categoryId = '';
  String? _levelId;
  String _type = '';

  MillionaireBloc({required QuizBloc quizBloc})
      : _quizBloc = quizBloc,
        super(const MillionaireState()) {
    on<LoadMillionaire>(_onLoad);
    on<MillionaireSelectAnswer>(_onSelectAnswer);
    on<UseLifeline5050>(_on5050);
    on<UseLifelineHint>(_onHint);
    on<UseLifelineAudience>(_onAudience);      // ← MỚI
    on<ContinuePlaying>(_onContinue);
    on<StopAndTakePrize>(_onStop);
    on<PrizeLadderDismissed>(_onPrizeLadderDismissed);
    on<MillionaireTimeTick>(_onTimeTick);      // ← MỚI
    on<MillionaireTimeUp>(_onTimeUp);          // ← MỚI
  }

  // ── Timer ───────────────────────────────────────────
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(MillionaireTimeTick());
    });
  }

  void _onTimeTick(MillionaireTimeTick e, Emitter<MillionaireState> emit) {
    if (!state.isPlaying) return;
    if (state.timeLeft <= 1) {
      _timer?.cancel();
      add(MillionaireTimeUp());
    } else {
      emit(state.copyWith(timeLeft: state.timeLeft - 1));
    }
  }

  void _onTimeUp(MillionaireTimeUp e, Emitter<MillionaireState> emit) {
  if (!state.isPlaying) return;

  _timer?.cancel();

  emit(state.copyWith(
    status: MillionaireStatus.gameOver,
  ));
}

  // ── Load ────────────────────────────────────────────
  Future<void> _onLoad(LoadMillionaire e, Emitter<MillionaireState> emit) async {
    _categoryId = e.categoryId;
    _levelId    = e.levelId;
    _type       = e.type;

    emit(state.copyWith(status: MillionaireStatus.loading));
    _quizBloc.add(LoadQuiz(
        categoryId: e.categoryId, levelId: e.levelId, type: e.type));

    try {
      final quizState = await _quizBloc.stream
          .firstWhere((s) => !s.isLoading && s.questions.isNotEmpty)
          .timeout(const Duration(seconds: 8));
      emit(state.copyWith(
        status: MillionaireStatus.playing,
        questions: quizState.questions,
        currentIndex: 0,
        correctCount: 0,
        timeLeft: 60,
        clearSelected: true,
        clearHidden: true,
      ));
      _startTimer(); // ← bắt đầu đếm giờ
    } catch (_) {
      emit(state.copyWith(
        status: MillionaireStatus.playing,
        errorMessage: 'Không tải được câu hỏi',
      ));
    }
  }

  // ── Select answer ───────────────────────────────────
  Future<void> _onSelectAnswer(
      MillionaireSelectAnswer e, Emitter<MillionaireState> emit) async {
    if (!state.isPlaying) return;
    if (state.selectedIndex != null) return;
    final q = state.currentQuestion;
    if (q == null) return;
    _timer?.cancel();

    final isCorrect = e.index >= 0 && e.index == q.correctIndex;

    emit(state.copyWith(
      status: MillionaireStatus.showingResult,
      selectedIndex: e.index,
    ));
    await Future.delayed(const Duration(milliseconds: 1000));

    if (!isCorrect) {
      emit(state.copyWith(status: MillionaireStatus.gameOver));
      await _saveProgress(
        correctCount: state.correctCount,
        earnedPts: state.safeScore, // ← điểm milestone
        completed: false,
      );
      return;
    }

    final newCorrectCount = state.correctCount + 1;
    final answeredQNum    = state.currentIndex + 1;
    final nextIndex       = state.currentIndex + 1;
    final earnedPts       = kPrizeLevels[state.currentIndex];
    final newSafePts      = kSafeMilestones.contains(answeredQNum)
        ? earnedPts : state.safePts;

    emit(state.copyWith(
      status: MillionaireStatus.showPrizeLadder,
      currentIndex: nextIndex >= 15 ? 14 : nextIndex,
      correctCount: newCorrectCount,
      safePts: newSafePts,
      timeLeft: 60,
      clearSelected: true,
      clearHidden: true,
    ));

    if (nextIndex >= 15) {
      await _saveProgress(
        correctCount: newCorrectCount,
        earnedPts: earnedPts,
        completed: true,
      );
    }
  }

  // ── Prize Ladder dismissed ──────────────────────────
  Future<void> _onPrizeLadderDismissed(
      PrizeLadderDismissed e, Emitter<MillionaireState> emit) async {
    if (state.currentIndex >= 14 && state.correctCount >= 15) {
      emit(state.copyWith(status: MillionaireStatus.finished));
      return;
    }
    final justAnswered = state.currentIndex - 1;
    if (justAnswered >= 5) {
      emit(state.copyWith(status: MillionaireStatus.askContinue));
    } else {
      emit(state.copyWith(status: MillionaireStatus.playing));
      _startTimer(); // ← resume timer
    }
  }

  void _onContinue(ContinuePlaying e, Emitter<MillionaireState> emit) {
    emit(state.copyWith(status: MillionaireStatus.playing));
    _startTimer(); // ← resume timer
  }

  Future<void> _onStop(StopAndTakePrize e, Emitter<MillionaireState> emit) async {
    _timer?.cancel();
    emit(state.copyWith(status: MillionaireStatus.finished));
    final earnedPts = kPrizeLevels[(state.currentIndex - 1).clamp(0, 14)];
    await _saveProgress(
      correctCount: state.correctCount,
      earnedPts: earnedPts,
      completed: state.correctCount >= 7,
    );
  }

  void _on5050(UseLifeline5050 e, Emitter<MillionaireState> emit) {
    if (state.ll5050Used || !state.isPlaying) return;
    final q = state.currentQuestion;
    if (q == null) return;
    final wrong = List.generate(q.answers.length, (i) => i)
        .where((i) => i != q.correctIndex).toList()..shuffle();
    emit(state.copyWith(ll5050Used: true, hiddenAnswers: {wrong[0], wrong[1]}));
  }

  void _onHint(UseLifelineHint e, Emitter<MillionaireState> emit) {
    if (state.llHintUsed || !state.isPlaying) return;
    emit(state.copyWith(llHintUsed: true));
  }

  void _onAudience(UseLifelineAudience e, Emitter<MillionaireState> emit) {
    if (state.llAudienceUsed || !state.isPlaying) return;
    emit(state.copyWith(llAudienceUsed: true));
    // UI lắng nghe state này để show dialog
  }

  // ── Firebase ────────────────────────────────────────
  Future<void> _addScoreToUser(int pts) async {
    if (pts <= 0) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).set(
      {'score': FieldValue.increment(pts)},
      SetOptions(merge: true),
    );
  }

  Future<void> _saveProgress({
    required int correctCount,
    required int earnedPts,
    required bool completed,
  }) async {
    // Cộng điểm vào users/{uid}.score
    await _addScoreToUser(earnedPts);

    if (_levelId == null) return;
    try {
      final userRef = _db
          .collection('categories').doc(_categoryId)
          .collection('mans').doc(_levelId);

      final snap = await userRef.get();
      final existing = snap.data();
      final prevPts  = (existing?['userScore'] as int?) ?? 0;
      final prevDone = (existing?['completed'] as bool?) ?? false;

      await userRef.set({
        'userScore':    prevPts + earnedPts,
        'correctCount': correctCount,
        'completed':    prevDone || completed,
        'unlocked':     correctCount >= 7,
        'updatedAt':    FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (correctCount >= 7) await _unlockNextLevel();
    } catch (_) {}
  }

  Future<void> _unlockNextLevel() async {
    if (_levelId == null) return;
    try {
      final match = RegExp(r'(\d+)').firstMatch(_levelId!);
      if (match == null) return;
      final num  = int.parse(match.group(1)!);
      final next = 'man_${num + 1}';
      await _db.collection('categories').doc(_categoryId)
          .collection('mans').doc(next)
          .set({'isUnlocked': true}, SetOptions(merge: true));
    } catch (_) {}
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}