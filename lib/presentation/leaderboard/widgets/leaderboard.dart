import 'package:flutter/material.dart';

class LeaderboardTile extends StatelessWidget {
  final String rank;
  final String name;
  final String points;
  final bool isHighlight;

  const LeaderboardTile({
    super.key,
    required this.rank,
    required this.name,
    required this.points,
    this.isHighlight = false,
  });

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
          const CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage("assets/images/nao.png"),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(points, style: const TextStyle(color: Color(0xff2E2B72))),
        ],
      ),
    );
  }
}
