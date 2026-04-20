import 'package:flutter/material.dart';
import 'package:dovui/pages/quiz/bloc/quiz_state.dart';

class QuizProgressBar extends StatelessWidget {
  final QuizState state;

  const QuizProgressBar({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final progress = state.questions.isNotEmpty
        ? state.questionCount / state.questions.length
        : 0.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        builder: (_, value, __) => LinearProgressIndicator(
          value: value,
          minHeight: 8,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(
            Color.lerp(const Color(0xFF6C63FF), const Color(0xFF43C6AC), value)!,
          ),
        ),
      ),
    );
  }
}