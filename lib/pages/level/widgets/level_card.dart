import 'package:flutter/material.dart';

class LevelCard extends StatelessWidget {
  final int index;
  final String status;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const LevelCard({
    super.key,
    required this.index,
    required this.status,
    required this.isUnlocked,
    required this.onTap,
  });

  List<Color> get _gradient {
    if (!isUnlocked) return [Colors.grey.shade300, Colors.grey.shade400];
    switch (status) {
      case 'completed':
        return [const Color(0xFF43C6AC), const Color(0xFF2BB89A)];
      case 'failed':
        return [const Color(0xFFFF6584), const Color(0xFFE8435A)];
      default:
        return [const Color(0xFF6C63FF), const Color(0xFF9B8FFF)];
    }
  }

  String get _emoji {
    if (!isUnlocked) return "🔒";
    switch (status) {
      case 'completed':
        return "⭐";
      case 'failed':
        return "💪";
      default:
        return "🎯";
    }
  }

  String get _statusText {
    if (!isUnlocked) return "Chưa mở";
    switch (status) {
      case 'completed':
        return "Hoàn thành";
      case 'failed':
        return "Thử lại";
      default:
        return "Bắt đầu";
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _gradient;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(isUnlocked ? 0.4 : 0.15),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background decorative circles
            Positioned(
              top: -18,
              right: -18,
              child: _circle(70, 0.1),
            ),
            Positioned(
              bottom: -10,
              left: -10,
              child: _circle(50, 0.07),
            ),
            // Level number watermark
            Positioned(
              top: 6,
              right: 10,
              child: Text(
                "${index + 1}",
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withOpacity(1),
                  height: 1,
                ),
              ),
            ),
            // Main content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_emoji, style: const TextStyle(fontSize: 32)),
                  const Spacer(),
                  Text(
                    "Màn ${index + 1}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  _StatusBadge(text: _statusText),
                ],
              ),
            ),
            // Locked overlay
            if (!isUnlocked)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.black.withOpacity(0.15),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _circle(double size, double opacity) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity),
        ),
      );
}

class _StatusBadge extends StatelessWidget {
  final String text;

  const _StatusBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}