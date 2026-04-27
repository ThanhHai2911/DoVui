import 'package:flutter/material.dart';

class LeaderboardTile extends StatelessWidget {
  final String rank;
  final String name;
  final String points;
  final bool isHighlight;
  final bool isVip; // ⭐ THÊM VIP

  const LeaderboardTile({
    super.key,
    required this.rank,
    required this.name,
    required this.points,
    this.isHighlight = false,
    this.isVip = false, // ⭐ default
  });

  Color _getColorByName(String name) {
    if (name.isEmpty) return Colors.grey;

    final code = name.codeUnitAt(0);

    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
    ];

    return colors[code % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(
            rank,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xff2E2B72),
            ),
          ),
          const SizedBox(width: 20),

          /// ⭐ AVATAR + VIP
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: _getColorByName(name),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : "A",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              /// 👇 VIP ICON
              if (isVip)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Image.asset(
                    "assets/images/vip.png",
                    width: 16,
                    height: 16,
                  ),
                ),
            ],
          ),

          const SizedBox(width: 20),

          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),

          Text(
            points,
            style: const TextStyle(color: Color(0xff2E2B72)),
          ),
        ],
      ),
    );
  }
}