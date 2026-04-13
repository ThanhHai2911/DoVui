import 'dart:async';
import 'package:dovui/data/audio/audio_manager.dart';
import 'package:dovui/data/repositories/user_level_repository.dart';
import 'package:dovui/pages/ads/ads_service.dart';
import 'package:dovui/pages/gamecomplete/game_complete_screen.dart';
import 'package:dovui/pages/home/widgets/game_dialog.dart';
import 'package:dovui/pages/quiz/bloc/quiz_event.dart';
import 'package:dovui/pages/quiz/bloc/quiz_state.dart';
import 'package:dovui/pages/quiz/widgets/answer_card.dart';
import 'package:dovui/pages/word_answer/widgets/hint_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bloc/quiz_bloc.dart';

class QuizScreen extends StatefulWidget {
  final String categoryId;
  final String? levelId;
  final String type;

  // ── Room mode callbacks ──────────────────────────────────────────────────────
  // Nếu null → chế độ solo (navigate sang GameCompleteScreen như bình thường)
  // Nếu có → chế độ phòng (lobby sẽ xử lý điểm & kết quả, không navigate ra ngoài)
  final String? roomId;
  final VoidCallback? onFinished;       // gọi khi người chơi nộp bài xong
  final void Function(int delta)? onScoreUpdate; // gọi khi trả lời đúng

  const QuizScreen({
    super.key,
    required this.categoryId,
    required this.type,
    this.levelId,
    // solo params
    this.roomId,
    // room callbacks
    this.onFinished,
    this.onScoreUpdate,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  late AnimationController _entryCtrl;
  late Animation<double> _entryFade;
  late Animation<Offset> _entrySlide;

  late AnimationController _questionCtrl;
  late Animation<double> _questionScale;
  late Animation<double> _questionFade;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  late AnimationController _floatCtrl;
  late Animation<double> _floatAnim;

  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  final _userLevelRepo = UserLevelRepository();
  String _lastQuestion = '';

  // ── Helpers ──────────────────────────────────────────────────────────────────

  bool get _isRoomMode => widget.onFinished != null;

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

  // ─────────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _entryFade =
        CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));

    _questionCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _questionScale = Tween<double>(begin: 0.88, end: 1.0).animate(
        CurvedAnimation(parent: _questionCtrl, curve: Curves.elasticOut));
    _questionFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _questionCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.05).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -8.0, end: 8.0).animate(
        CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnim = Tween<double>(begin: -4.0, end: 4.0).animate(
        CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));

    _entryCtrl.forward();
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

  void _triggerQuestionAnim(String q) {
    if (q != _lastQuestion) {
      _lastQuestion = q;
      _questionCtrl.forward(from: 0);
    }
  }

  void _triggerShake() {
    _shakeCtrl.forward(from: 0).then((_) => _shakeCtrl.reverse());
  }

  Color _timeColor(int t) {
    if (t <= 5) return const Color(0xFFFF6584);
    if (t <= 10) return const Color(0xFFFFB347);
    return const Color(0xFF43C6AC);
  }

  // ── Game over handler ─────────────────────────────────────────────────────────

  Future<void> _handleGameOver(QuizState state) async {
    _saveResult(score: state.score, total: state.questions.length);

    if (_isRoomMode) {
      // ✅ Chế độ phòng: gọi callback, lobby tự xử lý phần còn lại
      widget.onFinished?.call();
      return;
    }

    // ✅ Chế độ solo: navigate sang GameCompleteScreen như cũ
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

  // ─────────────────────────────────────────────────────────────────────────────

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
            // ── Trả lời → cộng điểm ─────────────────────────────────────────
            if (state.showResult) {
              final correctIndex = state.currentQuestion?.correctIndex;
              final selected = state.selectedIndex;
              if (correctIndex != null && selected != null) {
                if (selected == correctIndex) {
                  AudioManager().playCorrect();
                  // Room mode: cộng điểm qua callback (lobby gọi RoomService)
                  widget.onScoreUpdate?.call(10);
                } else {
                  AudioManager().playWrong();
                }
              }
            }

            // ── Game over ────────────────────────────────────────────────────
            if (state.isGameOver) {
              await _handleGameOver(state);
            }

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
                body: Center(
                  child: Text(
                    'Chưa có câu hỏi cho chuyên đề này',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
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
                  _buildBackground(),
                  FadeTransition(
                    opacity: _entryFade,
                    child: SlideTransition(
                      position: _entrySlide,
                      child: SafeArea(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16, 12, 16, 16),
                          child: Column(
                            children: [
                              _buildHeader(state),
                              const SizedBox(height: 12),
                              _buildProgressBar(state),
                              const SizedBox(height: 40),
                              FadeTransition(
                                opacity: _questionFade,
                                child: ScaleTransition(
                                  scale: _questionScale,
                                  child: _buildQuestionCard(state),
                                ),
                              ),
                              const SizedBox(height: 60),
                              Expanded(
                                  child: _buildAnswers(context, state)),
                              const SizedBox(height: 5),
                              // ✅ Hints chỉ hiện trong solo mode
                              if (!_isRoomMode)
                                _buildHintBar(context, state),
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

  // ── Hint bar (solo only) ──────────────────────────────────────────────────────

  Widget _buildHintBar(BuildContext context, QuizState state) {
    return HintBar(
      onMagnifier: () {
        showGameDialog(
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
        );
      },
      onKey: () {
        showGameDialog(
          context: context,
          icon: '🗝️',
          iconColor: Colors.deepPurple,
          title: 'Lộ đáp án',
          description:
              'Ẩn toàn bộ đáp án sai\nchỉ còn đúng 1 lựa chọn!',
          costIcon: '⭐',
          costText: '100',
          confirmText: 'Mở thôi!',
          confirmColor: Colors.deepPurple,
          showCancel: true,
          onConfirm: () =>
              context.read<QuizBloc>().add(UseHintEliminate()),
        );
      },
      onVideo: () async {
        if (!RewardedAdManager().isAdLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('⏳ Quảng cáo chưa sẵn sàng, thử lại sau!'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
        context.read<QuizBloc>().add(PauseTimer());
        final confirmed = await showGameDialogConfirm(
          context: context,
          icon: '🎬',
          iconColor: Colors.purple,
          title: 'Xem video nhận gợi ý?',
          description:
              'Xem 1 video ngắn để\nẩn 3 đáp án sai miễn phí!',
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
            context.read<QuizBloc>().add(UseHintFree());
            context.read<QuizBloc>().add(ResumeTimer());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🎉 Đã ẩn 3 đáp án sai!'),
                backgroundColor: Color(0xFF43C6AC),
              ),
            );
          },
          onFailed: () {
            if (!mounted) return;
            context.read<QuizBloc>().add(ResumeTimer());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ Không tải được quảng cáo!'),
                backgroundColor: Colors.red,
              ),
            );
          },
        );
      },
    );
  }

  // ── UI builders (giữ nguyên từ bản cũ) ───────────────────────────────────────

  Widget _buildBackground() {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _floatAnim,
        builder: (_, __) => Stack(
          children: [
            Positioned(
              top: -50 + _floatAnim.value,
              left: -50,
              child: _blob(180, const Color(0xFF6C63FF), 0.08),
            ),
            Positioned(
              top: 160 - _floatAnim.value,
              right: -40,
              child: _blob(140, const Color(0xFFFF6584), 0.07),
            ),
            Positioned(
              bottom: 200 + _floatAnim.value * 0.5,
              left: -30,
              child: _blob(120, const Color(0xFF43C6AC), 0.07),
            ),
            Positioned(
              bottom: 60 - _floatAnim.value * 0.5,
              right: -40,
              child: _blob(160, const Color(0xFFFFB347), 0.07),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blob(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(opacity),
      ),
    );
  }

  Widget _buildHeader(QuizState state) {
    final timeColor = _timeColor(state.timeLeft);
    final isWarning = state.timeLeft <= 5;

    return Row(
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C63FF).withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: const Color(0xFF6C63FF).withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('📝', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 5),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${state.questionCount}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6C63FF),
                      ),
                    ),
                    TextSpan(
                      text: '/${state.questions.length}',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        // Lives
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
                color: Colors.red.withOpacity(0.2), width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) {
              final active = index < state.lives;
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 2),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    active
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    key: ValueKey('$index-$active'),
                    size: 20,
                    color: active
                        ? Colors.red.shade400
                        : Colors.grey.shade300,
                  ),
                ),
              );
            }),
          ),
        ),
        const Spacer(),
        // Timer
        AnimatedBuilder(
          animation: _shakeAnim,
          builder: (_, child) => Transform.translate(
            offset:
                Offset(isWarning ? _shakeAnim.value : 0, 0),
            child: child,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: isWarning
                  ? timeColor.withOpacity(0.12)
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: timeColor.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(
                  color: timeColor.withOpacity(0.4), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(isWarning ? '⏰' : '⏱️',
                    style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 5),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: isWarning ? 16 : 14,
                    fontWeight: FontWeight.bold,
                    color: timeColor,
                  ),
                  child: Text('${state.timeLeft}s'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(QuizState state) {
    final progress = state.questions.isNotEmpty
        ? state.questionCount / state.questions.length
        : 0.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        builder: (_, value, __) => LinearProgressIndicator(
          value: value,
          minHeight: 8,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(
            Color.lerp(
              const Color(0xFF6C63FF),
              const Color(0xFF43C6AC),
              value,
            )!,
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(QuizState state) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 120),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF6C63FF).withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -14,
            right: 0,
            child: AnimatedBuilder(
              animation: _floatAnim,
              builder: (_, __) => Transform.translate(
                offset: Offset(0, _floatAnim.value * 0.35),
                child:
                    const Text('🧠', style: TextStyle(fontSize: 28)),
              ),
            ),
          ),
          Positioned(
            bottom: -12,
            left: 0,
            child: AnimatedBuilder(
              animation: _floatAnim,
              builder: (_, __) => Transform.translate(
                offset: Offset(0, -_floatAnim.value * 0.35),
                child:
                    const Text('💡', style: TextStyle(fontSize: 20)),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _pulseAnim,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF9B8FFF)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C63FF).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Text(
                    '❓ Câu hỏi',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                state.currentQuestion!.question,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1B4B),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnswers(BuildContext context, QuizState state) {
    final answers = state.currentQuestion!.answers;
    final eliminated = state.eliminatedIndexes;

    final gradients = [
      [const Color(0xFF6C63FF), const Color(0xFF9B8FFF)],
      [const Color(0xFF4FACFE), const Color(0xFF00F2FE)],
      [const Color(0xFFFFB347), const Color(0xFFFFD08A)],
      [const Color(0xFFF093FB), const Color(0xFFF5576C)],
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
          List<Color> gradient = gradients[index % gradients.length];
          final isCorrect = state.showResult &&
              index == state.currentQuestion!.correctIndex;
          final isWrong = state.showResult &&
              index == state.selectedIndex &&
              index != state.currentQuestion!.correctIndex;

          if (isCorrect) {
            gradient = [
              const Color(0xFF43C6AC),
              const Color(0xFF77E8D2)
            ];
          } else if (isWrong) {
            gradient = [
              const Color(0xFFFF6584),
              const Color(0xFFFF99AA)
            ];
          } else if (isEliminated) {
            gradient = [Colors.grey.shade300, Colors.grey.shade400];
          }

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
}