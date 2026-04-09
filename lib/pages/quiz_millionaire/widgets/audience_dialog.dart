import 'dart:math';
import 'package:flutter/material.dart';
import 'millionaire_colors.dart';

class AudienceDialog extends StatefulWidget {
  final int correctIndex;
  final int answerCount;

  const AudienceDialog({
    super.key,
    required this.correctIndex,
    required this.answerCount,
  });

  @override
  State<AudienceDialog> createState() => _AudienceDialogState();
}

class _AudienceDialogState extends State<AudienceDialog> {
  late List<double> percents;

  @override
  void initState() {
    super.initState();
    percents = _generate();
  }

  List<double> _generate() {
    final rng = Random();
    final correct = 50 + rng.nextInt(36); // 50–85
    final remaining = 100 - correct;
    final others = <int>[];
    int left = remaining;
    for (int i = 0; i < widget.answerCount - 2; i++) {
      final v = rng.nextInt(left + 1);
      others.add(v);
      left -= v;
    }
    others.add(left);
    others.shuffle();
    final result = List<double>.filled(widget.answerCount, 0);
    result[widget.correctIndex] = correct.toDouble();
    int j = 0;
    for (int i = 0; i < widget.answerCount; i++) {
      if (i != widget.correctIndex) result[i] = others[j++].toDouble();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    const labels = ['A', 'B', 'C', 'D'];
    const barColors = [
      Color(0xFF5B4FE9),
      Color(0xFF4FACFE),
      Color(0xFFFFB800),
      Color(0xFFFF6B9D),
    ];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: MillionaireColors.bgCard,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: MillionaireColors.primary.withOpacity(0.12),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5B4FE9), Color(0xFF9B8FFF)],
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: const [
                  Text(
                    '👥',
                    style: TextStyle(fontSize: 32),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Hỏi Khán Giả',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Kết quả bình chọn từ khán giả trường quay',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // ── Biểu đồ ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
              child: SizedBox(
                height: 180,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(widget.answerCount, (i) {
                    return _Bar(
                      label: labels[i],
                      percent: percents[i],
                      color: barColors[i % barColors.length],
                    );
                  }),
                ),
              ),
            ),

            const SizedBox(height: 40),
            // ── Divider ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Divider(color: MillionaireColors.border, height: 28),
            ),

            // ── Nút đóng ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MillionaireColors.primaryLight,
                    foregroundColor: MillionaireColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Đã hiểu',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Animated bar ────────────────────────────────────
class _Bar extends StatefulWidget {
  final String label;
  final double percent;
  final Color color;

  const _Bar({
    required this.label,
    required this.percent,
    required this.color,
  });

  @override
  State<_Bar> createState() => _BarState();
}

class _BarState extends State<_Bar> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _anim = Tween<double>(begin: 0, end: widget.percent / 100).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Phần trăm
        Text(
          '${widget.percent.toInt()}%',
          style: TextStyle(
            color: widget.color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),

        // Cột bar
        AnimatedBuilder(
          animation: _anim,
          builder: (_, __) => Container(
            width: 52,
            height: (140 * _anim.value).clamp(4.0, 140.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.color.withOpacity(0.6),
                  widget.color,
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Label tròn
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(0.1),
            border: Border.all(color: widget.color, width: 1.5),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                color: widget.color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }
}