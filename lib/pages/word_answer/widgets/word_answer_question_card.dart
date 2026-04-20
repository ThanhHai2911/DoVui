import 'package:flutter/material.dart';

/// Question card with pulse badge and floating emoji decorations.
class WordAnswerQuestionCard extends StatelessWidget {
  final dynamic question;
  final Animation<double> pulseAnim;
  final Animation<double> floatAnim;

  const WordAnswerQuestionCard({
    super.key,
    required this.question,
    required this.pulseAnim,
    required this.floatAnim,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final titleFont = (screenWidth * 0.040).clamp(13.0, 18.0);
        final questionFont = (screenWidth * 0.065).clamp(17.0, 26.0);

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.07,
            vertical: screenWidth * 0.09,
          ),
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
              _FloatingEmoji(floatAnim: floatAnim, emoji: '🎵', top: -20, right: -10, fontSize: 32, direction: 1),
              _FloatingEmoji(floatAnim: floatAnim, emoji: '🎶', bottom: -16, left: -8, fontSize: 22, direction: -1),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: pulseAnim,
                    child: _PulseBadge(titleFont: titleFont),
                  ),
                  SizedBox(height: screenWidth * 0.06),
                  Text(
                    question.question,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: questionFont,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E1B4B),
                      letterSpacing: 1.2,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FloatingEmoji extends StatelessWidget {
  final Animation<double> floatAnim;
  final String emoji;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double fontSize;
  final double direction; // 1 = normal, -1 = inverse

  const _FloatingEmoji({
    required this.floatAnim,
    required this.emoji,
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.fontSize,
    required this.direction,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: AnimatedBuilder(
        animation: floatAnim,
        builder: (_, __) => Transform.translate(
          offset: Offset(0, floatAnim.value * 0.4 * direction),
          child: Text(emoji, style: TextStyle(fontSize: fontSize)),
        ),
      ),
    );
  }
}

class _PulseBadge extends StatelessWidget {
  final double titleFont;

  const _PulseBadge({required this.titleFont});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
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
      child: Text(
        '🎵 Ghép tên bài hát',
        style: TextStyle(
          fontSize: titleFont,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}