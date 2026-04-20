import 'package:flutter/material.dart';

/// Animated floating blob background for quiz screens.
class AnimatedBlobBackground extends StatelessWidget {
  final Animation<double> floatAnim;

  const AnimatedBlobBackground({super.key, required this.floatAnim});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: floatAnim,
        builder: (_, __) => Stack(
          children: [
            _blob(top: -50 + floatAnim.value, left: -50, size: 180, color: const Color(0xFF6C63FF), opacity: 0.08),
            _blob(top: 160 - floatAnim.value, right: -40, size: 140, color: const Color(0xFFFF6584), opacity: 0.07),
            _blob(bottom: 200 + floatAnim.value * 0.5, left: -30, size: 120, color: const Color(0xFF43C6AC), opacity: 0.07),
            _blob(bottom: 60 - floatAnim.value * 0.5, right: -40, size: 160, color: const Color(0xFFFFB347), opacity: 0.07),
          ],
        ),
      ),
    );
  }

  Widget _blob({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required Color color,
    required double opacity,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
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