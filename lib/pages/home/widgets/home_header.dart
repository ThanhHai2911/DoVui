import 'package:dovui/app/resources/color_manager.dart';
import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Xin Chào, " + "Hải",
          style: TextStyle(
            fontSize: 16,
            color: ColorManager.primaryText,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Cùng chơi nào!",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color:  ColorManager.primaryDark,
          ),
        ),
      ],
    );
  }
}