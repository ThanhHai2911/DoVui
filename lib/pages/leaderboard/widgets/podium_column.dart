import 'package:flutter/material.dart';

class PodiumColumn extends StatelessWidget {
  final Widget card;
  final double podiumHeight;
  final Color podiumColor;
  final String emoji;

  const PodiumColumn({
    required this.card,
    required this.podiumHeight,
    required this.podiumColor,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        card,
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          height: podiumHeight,
          decoration: BoxDecoration(
            color: podiumColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          alignment: Alignment.center,
          child: Text(emoji, style: const TextStyle(fontSize: 24)),
        ),
      ],
    );
  }
}