import 'package:flutter/material.dart';

class LevelLegend extends StatelessWidget {
  const LevelLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _LegendDot(color: const Color(0xFF43C6AC), label: "✅ Đạt"),
          const SizedBox(width: 14),
          _LegendDot(color: const Color(0xFFFF6584), label: "❌ Chưa đạt"),
          const SizedBox(width: 14),
          _LegendDot(
            color: const Color(0xFF6C63FF).withOpacity(0.2),
            label: "🎯 Mới",
          ),
          const SizedBox(width: 14),
          _LegendDot(color: Colors.grey.shade300, label: "🔒 Khóa"),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}