import 'package:flutter/material.dart';

class WordAnswerHeader extends StatelessWidget {
  final int lives;
  final int timeLeft;
  final int currentIndex;
  final int totalQuestions;

  const WordAnswerHeader({
    super.key,
    required this.lives,
    required this.timeLeft,
    required this.currentIndex,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// Hiển thị thứ tự câu
          Text(
            "${currentIndex + 1}/$totalQuestions",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          /// Tim
          Row(
            children: List.generate(
              lives,
              (_) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: 20,
                ),
              ),
            ),
          ),

          /// Thời gian
          Text(
            "$timeLeft s",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}