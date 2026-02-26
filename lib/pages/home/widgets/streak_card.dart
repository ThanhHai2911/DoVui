import 'package:dovui/app/resources/color_manager.dart';
import 'package:flutter/material.dart';

class StreakCard extends StatelessWidget {
  const StreakCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:  ColorManager.primaryDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Bạn đã trải nghiệm" + " 200 " + "ngày",
            style: TextStyle(
              color: ColorManager.cardColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "+10 điểm mỗi ngày",
            style: TextStyle(color: ColorManager.textWhite),
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 0.6,
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