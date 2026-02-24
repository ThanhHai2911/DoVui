import 'package:dovui/pages/category/categories_screen.dart';
import 'package:dovui/pages/home/home_screen.dart';
import 'package:dovui/pages/leaderboard/Leaderboard_screen.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class HomeBottomNav extends StatefulWidget {
  const HomeBottomNav({super.key});

  @override
  State<HomeBottomNav> createState() => _HomeBottomNavState();
}

class _HomeBottomNavState extends State<HomeBottomNav> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    Categoriesscreen(),
    LeaderboardScreen(),
    const Center(child: Text("PROFILE")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          /// Nội dung chính
          _pages[_currentIndex],

          /// Bottom nổi blur thật
          Positioned(
            left: 20,
            right: 20,
            bottom: 25,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
                child: Container(
                  height: 75,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      _navItem(Icons.home, 0),
                      _navItem(Icons.grid_view, 1),
                      _navItem(Icons.bar_chart, 2),
                      _navItem(Icons.person, 3),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, int index) {
    final bool isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withOpacity(0.25)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 24,
              color: isSelected ? Colors.black : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}