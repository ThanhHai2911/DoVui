import 'package:dovui/app/resources/color_manager.dart';
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
    double screenWidth = MediaQuery.of(context).size.width;

    // Scale theo màn hình
    double baseSize = screenWidth * 0.045;

    // Giới hạn để không quá to / quá nhỏ
    double fontSize = baseSize.clamp(14.0, 22.0);
    double iconSize = (baseSize + 2).clamp(16.0, 26.0);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// Thứ tự câu
          Text(
            "${currentIndex + 1}/$totalQuestions",
            style: TextStyle(
              color: ColorManager.primaryTextColor,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),

          /// Tim
          Row(
            children: List.generate(
              lives,
              (index) => Padding(
                padding: EdgeInsets.symmetric(horizontal: iconSize * 0.1),
                child: Icon(Icons.favorite, color: Colors.red, size: iconSize),
              ),
            ),
          ),

          /// Thời gian
          Text(
            "$timeLeft s",
            style: TextStyle(
              color: ColorManager.primaryTextColor,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
