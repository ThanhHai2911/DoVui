import 'package:flutter/material.dart';
import 'package:dovui/pages/quiz/bloc/quiz_state.dart';

class QuizQuestionCard extends StatelessWidget {
  final QuizState state;
  final Animation<double> pulseAnim;
  final Animation<double> floatAnim;

  const QuizQuestionCard({
    super.key,
    required this.state,
    required this.pulseAnim,
    required this.floatAnim,
  });

  @override
  Widget build(BuildContext context) {
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
          _FloatingEmoji(emoji: '🧠', size: 28, animation: floatAnim, top: -14, right: 0, factor: 0.35),
          _FloatingEmoji(emoji: '💡', size: 20, animation: floatAnim, bottom: -12, left: 0, factor: -0.35),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: pulseAnim,
                child: _QuestionLabel(),
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
}

class _QuestionLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
    );
  }
}

class _FloatingEmoji extends StatelessWidget {
  final String emoji;
  final double size;
  final Animation<double> animation;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double factor;

  const _FloatingEmoji({
    required this.emoji,
    required this.size,
    required this.animation,
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.factor,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: AnimatedBuilder(
        animation: animation,
        builder: (_, __) => Transform.translate(
          offset: Offset(0, animation.value * factor),
          child: Text(emoji, style: TextStyle(fontSize: size)),
        ),
      ),
    );
  }
}