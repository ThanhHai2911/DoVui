import 'dart:math';
import 'package:flutter/material.dart';

class StarfieldBackground extends StatefulWidget {
  const StarfieldBackground({super.key});

  @override
  State<StarfieldBackground> createState() => _StarfieldBackgroundState();
}

class _StarfieldBackgroundState extends State<StarfieldBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _ctrl.value;
        return Stack(
          children: [
            // Nền trắng
            Container(color: const Color(0xFFF5F6FF)),

            // Blob tím nhạt góc trên trái
            Positioned(
              top: -60 + t * 20,
              left: -60,
              child: _blob(260, const Color(0xFF5B4FE9), 0.06),
            ),
            // Blob vàng góc trên phải
            Positioned(
              top: 80 - t * 15,
              right: -40,
              child: _blob(180, const Color(0xFFFFB800), 0.07),
            ),
            // Blob xanh góc dưới trái
            Positioned(
              bottom: 120 + t * 18,
              left: -50,
              child: _blob(200, const Color(0xFF00C48C), 0.05),
            ),
            // Blob hồng góc dưới phải
            Positioned(
              bottom: -40 - t * 10,
              right: -60,
              child: _blob(220, const Color(0xFFFF4D6A), 0.05),
            ),
          ],
        );
      },
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
}