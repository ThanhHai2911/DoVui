import 'package:flutter/material.dart';
import 'widgets/home_header.dart';
import 'widgets/streak_card.dart';
import 'widgets/quiz_of_week.dart';
import 'widgets/categories_section.dart';
import 'widgets/home_bottom_nav.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: const Color(0xffF3F4F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              HomeHeader(),
              SizedBox(height: 25),
              StreakCard(),
              SizedBox(height: 30),
              QuizOfWeek(),
              SizedBox(height: 30),
              CategoriesSection(),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}