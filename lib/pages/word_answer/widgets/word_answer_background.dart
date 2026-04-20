import 'package:flutter/material.dart';

/// Animated floating blobs in the background of WordAnswerScreen.
class WordAnswerBackground extends StatelessWidget {
  final AnimationController floatController;
  final Animation<double> floatAnim;

  const WordAnswerBackground({
    super.key,
    required this.floatController,
    required this.floatAnim,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: floatController,
      builder: (context, child) {
        return Stack(
          children: [
            _blob(top: -50 + floatAnim.value, left: -50, size: 180, color: const Color(0xFF6C63FF), opacity: 0.08),
            _blob(top: 150 - floatAnim.value, right: -40, size: 140, color: const Color(0xFFFF6584), opacity: 0.07),
            _blob(bottom: 200 + floatAnim.value * 0.5, left: -30, size: 120, color: const Color(0xFF43C6AC), opacity: 0.07),
            _blob(bottom: 60 - floatAnim.value * 0.5, right: -40, size: 160, color: const Color(0xFFFFB347), opacity: 0.07),
          ],
        );
      },
    );
  }

  Widget _blob({
    double? top,
    double? left,
    double? right,
    double? bottom,
    required double size,
    required Color color,
    required double opacity,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(opacity),
        ),
      ),
    );
  }
}