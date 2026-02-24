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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            rank,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xff2E2B72),
            ),
          ),
          const SizedBox(height: 10),
          CircleAvatar(
            radius: size / 2,
            backgroundImage: AssetImage("assets/images/dovui.png"),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            points,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}