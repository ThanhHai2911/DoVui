part of 'millionaire_bloc.dart';

enum MillionaireStatus {
  initial,
  loading,
  playing,
  showingResult,    // hiện đúng/sai
  showPrizeLadder,  // full-screen prize ladder sau khi đúng
  askContinue,      // từ câu 5 trở đi: hỏi tiếp hay dừng
  gameOver,         // trả lời sai
  finished,         // hoàn thành / tự dừng
}

class MillionaireState {
  final MillionaireStatus status;
  final List<QuestionModel> questions;
  final int currentIndex;
  final int? selectedIndex;
  final Set<int> hiddenAnswers;
  final bool ll5050Used;
  final bool llHintUsed;
  final int safePts;
  final int correctCount;  // số câu trả lời đúng trong màn
  final String? errorMessage;
  final bool llAudienceUsed;
  final int timeLeft;

  const MillionaireState({
    this.status        = MillionaireStatus.initial,
    this.questions     = const [],
    this.currentIndex  = 0,
    this.selectedIndex,
    this.hiddenAnswers = const {},
    this.ll5050Used    = false,
    this.llHintUsed    = false,
    this.safePts       = 0,
    this.correctCount  = 0,
    this.errorMessage,
    this.llAudienceUsed = false,
    this.timeLeft = 60,
  });

  bool get isLoading         => status == MillionaireStatus.loading;
  bool get isPlaying         => status == MillionaireStatus.playing;
  bool get isShowingResult   => status == MillionaireStatus.showingResult;
  bool get isShowPrizeLadder => status == MillionaireStatus.showPrizeLadder;
  bool get isAskContinue     => status == MillionaireStatus.askContinue;
  bool get isGameOver        => status == MillionaireStatus.gameOver;
  bool get isFinished        => status == MillionaireStatus.finished;

  QuestionModel? get currentQuestion =>
      questions.isNotEmpty && currentIndex < questions.length
          ? questions[currentIndex]
          : null;

  int get questionNumber => currentIndex + 1;
  int get currentPrize   => kPrizeLevels[currentIndex.clamp(0, 14)];

  // Điểm của câu vừa trả lời đúng (dùng khi hiển thị prize ladder)
  int get lastCorrectPrize =>
      kPrizeLevels[(currentIndex - 1).clamp(0, 14)];

  int get safeScore {
  // Milestone: câu 5 = kPrizeLevels[4]=100, câu 10 = kPrizeLevels[9]=800
  if (correctCount >= 10) return kPrizeLevels[9]; // 800
  if (correctCount >= 5)  return kPrizeLevels[4]; // 100
  return 0;
}

int get finalScore {
  if (isGameOver) return safeScore; // ← dùng safeScore thay vì safePts
  return kPrizeLevels[(currentIndex - 1).clamp(0, 14)];
}
  

  bool get canUnlockNextLevel => correctCount >= 7;

  MillionaireState copyWith({
    MillionaireStatus? status,
    List<QuestionModel>? questions,
    int? currentIndex,
    int? selectedIndex,
    Set<int>? hiddenAnswers,
    bool? ll5050Used,
    bool? llHintUsed,
    int? safePts,
    int? correctCount,
    String? errorMessage,
    bool clearSelected = false,
    bool clearHidden   = false,
    bool? llAudienceUsed,
    int? timeLeft,
  }) {
    return MillionaireState(
      status:        status        ?? this.status,
      questions:     questions     ?? this.questions,
      currentIndex:  currentIndex  ?? this.currentIndex,
      selectedIndex: clearSelected ? null : (selectedIndex ?? this.selectedIndex),
      hiddenAnswers: clearHidden   ? {}   : (hiddenAnswers ?? this.hiddenAnswers),
      ll5050Used:    ll5050Used    ?? this.ll5050Used,
      llHintUsed:    llHintUsed    ?? this.llHintUsed,
      safePts:       safePts       ?? this.safePts,
      correctCount:  correctCount  ?? this.correctCount,
      errorMessage:  errorMessage  ?? this.errorMessage,
      llAudienceUsed: llAudienceUsed ?? this.llAudienceUsed,
      timeLeft: timeLeft ?? this.timeLeft,
    );
  }
}