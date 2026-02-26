import 'package:dovui/app/resources/color_manager.dart';
import 'package:dovui/pages/adddulieu/adddulieu.dart';
import 'package:flutter/material.dart';
import 'widgets/home_header.dart';
import 'widgets/streak_card.dart';
import 'widgets/quiz_of_week.dart';
import 'widgets/categories_section.dart';
import 'widgets/home_shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  static bool _hasLoadedOnce = false;

  @override
  void initState() {
    super.initState();
    //_runSetup();
    if (!_hasLoadedOnce) {
      _fakeLoading();
      _hasLoadedOnce = true;
    } else {
      isLoading = false;
    }
  }

  

  Future<void> _fakeLoading() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: ColorManager.scaffoldBackground,
      body: SafeArea(
        child:
            isLoading
                ? const HomeShimmer()
                : SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    size.width * 0.06,
                    0,
                    size.width * 0.06,
                    70,
                  ),
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
