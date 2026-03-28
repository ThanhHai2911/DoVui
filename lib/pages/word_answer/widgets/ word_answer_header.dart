import 'package:dovui/resources/color_manager.dart';
import 'package:flutter/material.dart';

class WordAnswerHeader extends StatefulWidget {
  final int lives;
  final int timeLeft;
  final int currentIndex;
  final int totalQuestions;

  const WordAnswerHeader({
    super.key,
    required this.lives,
    required this.timeLeft,
    required this.currentIndex,
    required this.totalQuestions,
  });

  @override
  State<WordAnswerHeader> createState() => _WordAnswerHeaderState();
}

class _WordAnswerHeaderState extends State<WordAnswerHeader>
    with TickerProviderStateMixin {
  late AnimationController _heartController;
  late AnimationController _timeController;
  late Animation<double> _heartPulse;
  late Animation<double> _timePulse;

  int _prevLives = 0;
  int _prevTime = 0;

  @override
  void initState() {
    super.initState();

    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _heartPulse = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.elasticOut),
    );

    _timeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _timePulse = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _timeController, curve: Curves.elasticOut),
    );

    _prevLives = widget.lives;
    _prevTime = widget.timeLeft;
  }

  @override
  void didUpdateWidget(WordAnswerHeader oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Tim bị mất → pulse đỏ
    if (widget.lives < oldWidget.lives) {
      _heartController.forward(from: 0);
    }

    // Thời gian sắp hết (≤ 10s) → pulse cảnh báo
    if (widget.timeLeft <= 10 && widget.timeLeft != oldWidget.timeLeft) {
      _timeController.forward(from: 0);
    }

    _prevLives = widget.lives;
    _prevTime = widget.timeLeft;
  }

  @override
  void dispose() {
    _heartController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Color _timeColor() {
    if (widget.timeLeft <= 10) return const Color(0xFFFF6584);
    if (widget.timeLeft <= 20) return const Color(0xFFFFB347);
    return const Color(0xFF43C6AC);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double progress = widget.totalQuestions > 0
        ? (widget.currentIndex + 1) / widget.totalQuestions
        : 0;

    return Column(
      children: [
        /// ===== ROW CHÍNH =====
        Row(
          children: [
            /// ----- SỐ CÂU -----
            _buildQuestionBadge(),

            const Spacer(),

            /// ----- TIM -----
            _buildLives(),

            const Spacer(),

            /// ----- THỜI GIAN -----
            _buildTimer(),
          ],
        ),

        const SizedBox(height: 12),

        /// ===== PROGRESS BAR =====
        _buildProgressBar(progress),
      ],
    );
  }

  Widget _buildQuestionBadge() {
    return Container(
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
          const Text("📝", style: TextStyle(fontSize: 14)),
          const SizedBox(width: 5),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "${widget.currentIndex + 1}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6C63FF),
                  ),
                ),
                TextSpan(
                  text: "/${widget.totalQuestions}",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLives() {
    return Container(
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
        border: Border.all(
          color: Colors.red.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(widget.lives, (index) {
          return AnimatedBuilder(
            animation: _heartPulse,
            builder: (_, __) => Transform.scale(
              // Chỉ pulse tim cuối cùng
              scale: index == widget.lives - 1
                  ? _heartPulse.value
                  : 1.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  Icons.favorite_rounded,
                  color: Colors.red.shade400,
                  size: 20,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTimer() {
    final color = _timeColor();
    final isWarning = widget.timeLeft <= 10;

    return AnimatedBuilder(
      animation: _timePulse,
      builder: (_, __) => Transform.scale(
        scale: isWarning ? _timePulse.value : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isWarning ? color.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: color.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isWarning ? "⏰" : "⏱️",
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 5),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: isWarning ? 17 : 15,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                child: Text("${widget.timeLeft}s"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (_, value, __) {
              return LinearProgressIndicator(
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
              );
            },
          ),
        ),
      ],
    );
  }
}