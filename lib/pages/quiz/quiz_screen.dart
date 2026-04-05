import 'package:dovui/data/audio/audio_manager.dart';
import 'package:dovui/resources/color_manager.dart';
import 'package:dovui/pages/gamecomplete/game_complete_sceen.dart';
import 'package:dovui/pages/quiz/bloc/quiz_event.dart';
import 'package:dovui/pages/quiz/bloc/quiz_state.dart';
import 'package:dovui/pages/quiz/widgets/answer_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/quiz_bloc.dart';

class QuizScreen extends StatefulWidget {
  final String categoryId;
  final String? levelId;
  final String type;

  const QuizScreen({
    super.key,
    required this.categoryId,
    required this.type,
    this.levelId,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  // Entry animation
  late AnimationController _entryCtrl;
  late Animation<double> _entryFade;
  late Animation<Offset> _entrySlide;

  // Question card animation
  late AnimationController _questionCtrl;
  late Animation<double> _questionScale;
  late Animation<double> _questionFade;

  // Pulse badge tiêu đề
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  // Float blobs nền
  late AnimationController _floatCtrl;
  late Animation<double> _floatAnim;

  // Timer warning shake
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  String _lastQuestion = '';

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _entryFade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));

    _questionCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _questionScale = Tween<double>(
      begin: 0.88,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _questionCtrl, curve: Curves.elasticOut));
    _questionFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _questionCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(
      begin: -8.0,
      end: 8.0,
    ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(
      begin: -4.0,
      end: 4.0,
    ).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));

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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) =>
              QuizBloc()..add(
                LoadQuiz(
                  categoryId: widget.categoryId,
                  levelId: widget.levelId,
                  type: widget.type,
                ),
              ),
      child: BlocConsumer<QuizBloc, QuizState>(
        listener: (context, state) {
          // 🎯 Khi hiện kết quả
          if (state.showResult) {
            final correctIndex = state.currentQuestion?.correctIndex;
            final selected = state.selectedIndex;

            if (correctIndex != null && selected != null) {
              if (selected == correctIndex) {
                // ✅ đúng
                AudioManager().playCorrect();
              } else {
                // ❌ sai
                AudioManager().playWrong();
              }
            }
          }
          if (state.isGameOver) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (_) => GameCompleteScreen(
                      score: state.score,
                      totalQuestions: state.questions.length,
                      isWin: state.score > 0,
                      categoryId: widget.categoryId,
                      levelId: widget.levelId,
                      type: widget.type,
                    ),
              ),
            );
          }
          // Shake khi thời gian sắp hết
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
                  "Chưa có câu hỏi cho chuyên đề này",
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
                /// ===== NỀN BLOB =====
                _buildBackground(),

                FadeTransition(
                  opacity: _entryFade,
                  child: SlideTransition(
                    position: _entrySlide,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        child: Column(
                          children: [
                            /// ===== HEADER =====
                            _buildHeader(state),

                            const SizedBox(height: 12),

                            /// ===== PROGRESS BAR =====
                            _buildProgressBar(state),

                            const SizedBox(height: 20),

                            /// ===== CARD CÂU HỎI =====
                            FadeTransition(
                              opacity: _questionFade,
                              child: ScaleTransition(
                                scale: _questionScale,
                                child: _buildQuestionCard(state),
                              ),
                            ),

                            const SizedBox(height: 60),

                            /// ===== ANSWERS =====
                            Expanded(child: _buildAnswers(context, state)),
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
    );
  }

  Widget _buildBackground() {
    return AnimatedBuilder(
      animation: _floatAnim,
      builder:
          (_, __) => Stack(
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
        /// Số câu
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
              const Text("📝", style: TextStyle(fontSize: 13)),
              const SizedBox(width: 5),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "${state.questionCount}",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6C63FF),
                      ),
                    ),
                    TextSpan(
                      text: "/${state.questions.length}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        /// Tim
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
            border: Border.all(color: Colors.red.withOpacity(0.2), width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) {
              final active = index < state.lives;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    active
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    key: ValueKey('$index-$active'),
                    size: 20,
                    color: active ? Colors.red.shade400 : Colors.grey.shade300,
                  ),
                ),
              );
            }),
          ),
        ),

        const Spacer(),

        /// Timer
        AnimatedBuilder(
          animation: _shakeAnim,
          builder:
              (_, child) => Transform.translate(
                offset: Offset(isWarning ? _shakeAnim.value : 0, 0),
                child: child,
              ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: isWarning ? timeColor.withOpacity(0.12) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: timeColor.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(color: timeColor.withOpacity(0.4), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isWarning ? "⏰" : "⏱️",
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(width: 5),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: isWarning ? 16 : 14,
                    fontWeight: FontWeight.bold,
                    color: timeColor,
                  ),
                  child: Text("${state.timeLeft}s"),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(QuizState state) {
    final progress =
        state.questions.isNotEmpty
            ? state.questionCount / state.questions.length
            : 0.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        builder:
            (_, value, __) => LinearProgressIndicator(
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
      constraints: const BoxConstraints(minHeight: 200),
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
          // Emoji nổi góc — float
          Positioned(
            top: -14,
            right: 0,
            child: AnimatedBuilder(
              animation: _floatAnim,
              builder:
                  (_, __) => Transform.translate(
                    offset: Offset(0, _floatAnim.value * 0.35),
                    child: const Text("🧠", style: TextStyle(fontSize: 28)),
                  ),
            ),
          ),
          Positioned(
            bottom: -12,
            left: 0,
            child: AnimatedBuilder(
              animation: _floatAnim,
              builder:
                  (_, __) => Transform.translate(
                    offset: Offset(0, -_floatAnim.value * 0.35),
                    child: const Text("💡", style: TextStyle(fontSize: 20)),
                  ),
            ),
          ),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Badge pulse
              ScaleTransition(
                scale: _pulseAnim,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
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
                    "❓ Câu hỏi",
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

    // Màu gradient cho 4 đáp án
    final gradients = [
      [const Color(0xFF6C63FF), const Color(0xFF9B8FFF)],
      [const Color(0xFF4FACFE), const Color(0xFF00F2FE)],
      [const Color(0xFFFFB347), const Color(0xFFFFD08A)],
      [const Color(0xFFF093FB), const Color(0xFFF5576C)],
    ];

    return GridView.builder(
      itemCount: answers.length,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.25,
      ),
      itemBuilder: (context, index) {
        List<Color> gradient = gradients[index % gradients.length];
        bool isCorrect =
            state.showResult && index == state.currentQuestion!.correctIndex;
        bool isWrong =
            state.showResult &&
            index == state.selectedIndex &&
            index != state.currentQuestion!.correctIndex;

        if (isCorrect) {
          gradient = [const Color(0xFF43C6AC), const Color(0xFF77E8D2)];
        } else if (isWrong) {
          gradient = [const Color(0xFFFF6584), const Color(0xFFFF99AA)];
        }

        return _AnswerCard(
          key: ValueKey('$index-${state.questionCount}'),
          text: answers[index],
          gradient: gradient,
          isCorrect: isCorrect,
          isWrong: isWrong,
          isDisabled: state.showResult,
          index: index,
          onTap:
              state.showResult
                  ? null
                  : () {
                    // 🔊 âm click
                    AudioManager().playClick();

                    context.read<QuizBloc>().add(SelectAnswer(index));
                  },
        );
      },
    );
  }
}

// =============================================
//  ANSWER CARD với animation
// =============================================
class _AnswerCard extends StatefulWidget {
  final String text;
  final List<Color> gradient;
  final bool isCorrect;
  final bool isWrong;
  final bool isDisabled;
  final int index;
  final VoidCallback? onTap;

  const _AnswerCard({
    super.key,
    required this.text,
    required this.gradient,
    required this.isCorrect,
    required this.isWrong,
    required this.isDisabled,
    required this.index,
    required this.onTap,
  });

  @override
  State<_AnswerCard> createState() => _AnswerCardState();
}

class _AnswerCardState extends State<_AnswerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _entryScale;
  late Animation<double> _entryFade;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _entryScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _entryFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // Stagger theo index
    Future.delayed(Duration(milliseconds: 80 * widget.index), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _entryFade,
      child: ScaleTransition(
        scale: _entryScale,
        child: GestureDetector(
          onTapDown: (_) {
            if (!widget.isDisabled) setState(() => _pressed = true);
          },
          onTapUp: (_) {
            setState(() => _pressed = false);
            widget.onTap?.call();
          },
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.93 : 1.0,
            duration: const Duration(milliseconds: 80),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: widget.gradient[0].withOpacity(
                      _pressed ? 0.2 : 0.35,
                    ),
                    blurRadius: _pressed ? 4 : 12,
                    offset: Offset(0, _pressed ? 2 : 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Highlight 3D
                  Positioned(
                    top: 8,
                    left: 10,
                    child: Container(
                      width: 50,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),

                  // Icon kết quả
                  if (widget.isCorrect || widget.isWrong)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder:
                            (child, anim) =>
                                ScaleTransition(scale: anim, child: child),
                        child: Text(
                          widget.isCorrect ? "✅" : "❌",
                          key: ValueKey(widget.isCorrect),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),

                  // Nội dung
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        widget.text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.3,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
