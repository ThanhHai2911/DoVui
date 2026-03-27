import 'package:dovui/resources/color_manager.dart';
import 'package:flutter/material.dart';
import 'package:dovui/core/utils/app_date_utils.dart';

class StreakCard extends StatelessWidget {
  final int days;        // ← nhận days tính sẵn từ BLoC
  final String name;
  final int score;

  const StreakCard({
    super.key,
    required this.days,
    required this.name,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorManager.primaryDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Bạn đã trải nghiệm $days ngày",
            style: TextStyle(
              color: ColorManager.cardColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Số sao của bạn: $score",
            style: TextStyle(color: ColorManager.textWhite),
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (days % 365) / 365,
              minHeight: 8,
              backgroundColor: ColorManager.backgroundthanh,
              valueColor: AlwaysStoppedAnimation<Color>(ColorManager.mauthanh),
            ),
          ),
        ],
      ),
    );
  }
}