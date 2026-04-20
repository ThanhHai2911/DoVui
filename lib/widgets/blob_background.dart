import 'package:flutter/material.dart';

class BlobBackground extends StatelessWidget {
  const BlobBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _blob(top: -60, left: -60, size: 200, color: const Color(0xFF6C63FF), opacity: 0.08),
        _blob(top: 100, right: -40, size: 150, color: const Color(0xFFFF6584), opacity: 0.07),
        _blob(bottom: 200, left: -30, size: 120, color: const Color(0xFF43C6AC), opacity: 0.07),
        _blob(bottom: 80, right: -50, size: 180, color: const Color(0xFFFFB347), opacity: 0.07),
      ],
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