import 'package:flutter/material.dart';

class TopUserCard extends StatelessWidget {
  final String rank;
  final String name;
  final String points;
  final double size;
  final bool isFirst;

  const TopUserCard({
    super.key,
    required this.rank,
    required this.name,
    required this.points,
    required this.size,
    this.isFirst = false,
  });

  Color _getColorByName(String name) {
    if (name.isEmpty) return Colors.grey;
    final code = name.codeUnitAt(0);
    final colors = [
      Colors.blue, Colors.red, Colors.green,
      Colors.orange, Colors.purple, Colors.teal, Colors.indigo,
    ];
    return colors[code % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Tất cả scale theo size, không hardcode
    final double avatarRadius = size * 0.38;
    final double nameFontSize = size * 0.16;
    final double pointFontSize = size * 0.13;
    final double rankFontSize = size * 0.15;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Rank badge nhỏ phía trên
        Text(
          rank,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: rankFontSize,
            color: const Color(0xFF2E2B72),
          ),
        ),
        const SizedBox(height: 4),

        // Avatar — to hơn với #1
        CircleAvatar(
          radius: avatarRadius,
          backgroundColor: _getColorByName(name),
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : "?",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: avatarRadius * 0.9,
            ),
          ),
        ),
        const SizedBox(height: 6),

        // Tên
        Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: nameFontSize,
            color: const Color(0xFF2E2B72),
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        const SizedBox(height: 2),

        // Điểm
        Text(
          points,
          style: TextStyle(
            fontSize: pointFontSize,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}