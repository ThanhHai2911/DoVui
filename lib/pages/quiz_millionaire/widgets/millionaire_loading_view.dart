import 'package:flutter/material.dart';
import 'millionaire_colors.dart';

/// Full-screen loading indicator for MillionaireScreen.
class MillionaireLoadingView extends StatelessWidget {
  const MillionaireLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: MillionaireColors.bgDeep,
      body: Center(
        child: CircularProgressIndicator(color: MillionaireColors.gold),
      ),
    );
  }
}

/// Full-screen empty state for MillionaireScreen.
class MillionaireEmptyView extends StatelessWidget {
  const MillionaireEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: MillionaireColors.bgDeep,
      body: Center(
        child: Text(
          'Chưa có câu hỏi cho chuyên đề này',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ),
    );
  }
}