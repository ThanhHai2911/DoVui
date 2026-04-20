import 'package:dovui/data/audio/audio_manager.dart';
import 'package:dovui/data/repositories/user_level_repository.dart';
import 'package:dovui/pages/ads/ads_service.dart';
import 'package:dovui/pages/gamecomplete/game_complete_screen.dart';
import 'package:dovui/pages/home/widgets/game_dialog.dart';
import 'package:dovui/pages/quiz/bloc/quiz_event.dart';
import 'package:dovui/pages/quiz/bloc/quiz_state.dart';
import 'package:dovui/pages/quiz/widgets/animated_blob_background.dart';
import 'package:dovui/pages/quiz/widgets/answer_card.dart';
import 'package:dovui/pages/quiz/widgets/quiz_header.dart';
import 'package:dovui/pages/quiz/widgets/quiz_progress_bar.dart';
import 'package:dovui/pages/quiz/widgets/quiz_question_card.dart';
import 'package:dovui/pages/word_answer/widgets/hint_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bloc/quiz_bloc.dart';

class QuizScreen extends StatefulWidget {
  final String categoryId;
  final String? levelId;
  final String type;

  // Room mode (null = solo)
  final String? roomId;
  final VoidCallback? onFinished;
  final void Function(int delta)? onScoreUpdate;

  const QuizScreen({
    super.key,
    required this.categoryId,
    required this.type,
    this.levelId,
    this.roomId,
    this.onFinished,
    this.onScoreUpdate,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  // ── Animations ───────────────────────────────────────────────────────────────
  late final AnimationController _entryCtrl;
  late final AnimationController _questionCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _floatCtrl;
  late final AnimationController _shakeCtrl;

  late final Animation<double> _entryFade;
  late final Animation<Offset> _entrySlide;
  late final Animation<double> _questionScale;
  late final Animation<double> _questionFade;
  late final Animation<double> _pulseAnim;
  late final Animation<double> _floatAnim;
  late final Animation<double> _shakeAnim;

  final _userLevelRepo = UserLevelRepository();
  String _lastQuestion = '';

  bool get _isRoomMode => widget.onFinished != null;

  // ── Lifecycle ─────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _entryCtrl.forward();
  }

  void _initAnimations() {
    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _entryFade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _entrySlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));

    _questionCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    _questionScale = Tween<double>(begin: 0.88, end: 1.0)
        .animate(CurvedAnimation(parent: _questionCtrl, curve: Curves.elasticOut));
    _questionFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _questionCtrl, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );

    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.05)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _floatCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -8.0, end: 8.0)
        .animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    _shakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnim = Tween<double>(begin: -4.0, end: 4.0)
        .animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _questionCtrl.dispose();
    _pulseCtrl.dispose();
    _floatCtrl.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────

  void _triggerQuestionAnim(String q) {
    if (q != _lastQuestion) {
      _lastQuestion = q;
      _questionCtrl.forward(from: 0);
    }
  }

  void _triggerShake() {
    _shakeCtrl.forward(from: 0).then((_) => _shakeCtrl.reverse());
  }

  Future<void> _saveResult({required int score, required int total}) async {
    if (widget.levelId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) return;
    final maxScore = total * 10;
    final percent = maxScore > 0 ? ((score / maxScore) * 10).round() : 0;
    _userLevelRepo.saveLevelWithType(
      userId: userId,
      levelId: widget.levelId!,
      score: percent,
      type: widget.type,
    );
  }

  Future<void> _handleGameOver(QuizState state) async {
    _saveResult(score: state.score, total: state.questions.length);

    if (_isRoomMode) {
      widget.onFinished?.call();
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => GameCompleteScreen(
            score: state.score,
            totalQuestions: state.questions.length,
            isWin: state.score >= 60,
            categoryId: widget.categoryId,
            levelId: widget.levelId,
            type: widget.type,
          ),
        ),
      );
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) {},
      child: BlocProvider(
        create: (_) => QuizBloc()
          ..add(LoadQuiz(
            categoryId: widget.categoryId,
            levelId: widget.levelId,
            type: widget.type,
          )),
        child: BlocConsumer<QuizBloc, QuizState>(
          listener: (context, state) async {
            if (state.showResult) {
              final correct = state.currentQuestion?.correctIndex;
              final selected = state.selectedIndex;
              if (correct != null && selected != null) {
                if (selected == correct) {
                  AudioManager().playCorrect();
                  widget.onScoreUpdate?.call(10);
                } else {
                  AudioManager().playWrong();
                }
              }
            }
            if (state.isGameOver) await _handleGameOver(state);
            if (state.timeLeft <= 5) _triggerShake();
          },
          builder: (context, state) {
            if (state.isLoading) {
              return const Scaffold(
                backgroundColor: Color(0xFFF4F6FF),
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (state.questions.isEmpty) {
              return const Scaffold(
                backgroundColor: Color(0xFFF4F6FF),
                body: Center(child: Text('Chưa có câu hỏi cho chuyên đề này', style: TextStyle(fontSize: 18))),
              );
            }
            if (state.currentQuestion == null) {
              return const Scaffold(
                backgroundColor: Color(0xFFF4F6FF),
                body: Center(child: CircularProgressIndicator()),
              );
            }

            _triggerQuestionAnim(state.currentQuestion!.question);

            return Scaffold(
              backgroundColor: const Color(0xFFF4F6FF),
              body: Stack(
                children: [
                  AnimatedBlobBackground(floatAnim: _floatAnim),
                  FadeTransition(
                    opacity: _entryFade,
                    child: SlideTransition(
                      position: _entrySlide,
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                          child: Column(
                            children: [
                              QuizHeader(state: state, shakeAnim: _shakeAnim),
                              const SizedBox(height: 12),
                              QuizProgressBar(state: state),
                              const SizedBox(height: 40),
                              FadeTransition(
                                opacity: _questionFade,
                                child: ScaleTransition(
                                  scale: _questionScale,
                                  child: QuizQuestionCard(
                                    state: state,
                                    pulseAnim: _pulseAnim,
                                    floatAnim: _floatAnim,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 60),
                              Expanded(child: _buildAnswers(context, state)),
                              const SizedBox(height: 5),
                              if (!_isRoomMode) _buildHintBar(context, state),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnswers(BuildContext context, QuizState state) {
    final answers = state.currentQuestion!.answers;
    final eliminated = state.eliminatedIndexes;

    const gradients = [
      [Color(0xFF6C63FF), Color(0xFF9B8FFF)],
      [Color(0xFF4FACFE), Color(0x00F2FE00)],
      [Color(0xFFFFB347), Color(0xFFFFD08A)],
      [Color(0xFFF093FB), Color(0xFFF5576C)],
    ];

    return RepaintBoundary(
      child: GridView.builder(
        itemCount: answers.length,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.25,
        ),
        itemBuilder: (context, index) {
          final isEliminated = eliminated.contains(index);
          final isCorrect = state.showResult && index == state.currentQuestion!.correctIndex;
          final isWrong = state.showResult &&
              index == state.selectedIndex &&
              index != state.currentQuestion!.correctIndex;

          List<Color> gradient = List<Color>.from(gradients[index % gradients.length]);
          if (isCorrect) gradient = [const Color(0xFF43C6AC), const Color(0xFF77E8D2)];
          else if (isWrong) gradient = [const Color(0xFFFF6584), const Color(0xFFFF99AA)];
          else if (isEliminated) gradient = [Colors.grey.shade300, Colors.grey.shade400];

          return AnswerCard(
            key: ValueKey('${state.questionCount}-$index'),
            text: answers[index],
            gradient: gradient,
            isCorrect: isCorrect,
            isWrong: isWrong,
            isDisabled: state.showResult || isEliminated,
            isEliminated: isEliminated,
            index: index,
            onTap: (state.showResult || isEliminated)
                ? null
                : () {
                    AudioManager().playClick();
                    context.read<QuizBloc>().add(SelectAnswer(index));
                  },
          );
        },
      ),
    );
  }

  Widget _buildHintBar(BuildContext context, QuizState state) {
    return HintBar(
      onMagnifier: () => showGameDialog(
        context: context,
        icon: '✂️',
        iconColor: Colors.amber,
        title: 'Loại 50/50',
        description: 'Ẩn 2 đáp án sai bất kỳ\nchỉ còn 2 lựa chọn!',
        costIcon: '⭐',
        costText: '50',
        confirmText: 'Dùng ngay!',
        confirmColor: Colors.amber,
        showCancel: true,
        onConfirm: () => context.read<QuizBloc>().add(UseHint5050()),
      ),
      onKey: () => showGameDialog(
        context: context,
        icon: '🗝️',
        iconColor: Colors.deepPurple,
        title: 'Lộ đáp án',
        description: 'Ẩn toàn bộ đáp án sai\nchỉ còn đúng 1 lựa chọn!',
        costIcon: '⭐',
        costText: '100',
        confirmText: 'Mở thôi!',
        confirmColor: Colors.deepPurple,
        showCancel: true,
        onConfirm: () => context.read<QuizBloc>().add(UseHintEliminate()),
      ),
      onVideo: () => _onVideoHint(context),
    );
  }

  Future<void> _onVideoHint(BuildContext context) async {
    if (!RewardedAdManager().isAdLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⏳ Quảng cáo chưa sẵn sàng, thử lại sau!'), backgroundColor: Colors.orange),
      );
      return;
    }
    context.read<QuizBloc>().add(PauseTimer());
    final confirmed = await showGameDialogConfirm(
      context: context,
      icon: '🎬',
      iconColor: Colors.purple,
      title: 'Xem video nhận gợi ý?',
      description: 'Xem 1 video ngắn để\nẩn 3 đáp án sai miễn phí!',
      costIcon: '🎬',
      costText: 'Xem video',
      confirmText: 'Xem ngay!',
      confirmColor: Colors.purple,
      showCancel: true,
    );
    if (confirmed != true) {
      context.read<QuizBloc>().add(ResumeTimer());
      return;
    }
    RewardedAdManager().showAd(
      onRewarded: () {
        if (!mounted) return;
        context.read<QuizBloc>()
          ..add(UseHintFree())
          ..add(ResumeTimer());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 Đã ẩn 3 đáp án sai!'), backgroundColor: Color(0xFF43C6AC)),
        );
      },
      onFailed: () {
        if (!mounted) return;
        context.read<QuizBloc>().add(ResumeTimer());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Không tải được quảng cáo!'), backgroundColor: Colors.red),
        );
      },
    );
  }
}