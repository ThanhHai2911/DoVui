import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/millionaire_bloc.dart';

class TimerBar extends StatelessWidget {
  const TimerBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MillionaireBloc, MillionaireState>(
      buildWhen: (p, c) => p.timeLeft != c.timeLeft,
      builder: (context, state) {
        final progress = state.timeLeft / 60;
        final isWarning = state.timeLeft <= 10;

        return Column(
          children: [
            Text(
              "⏱ ${state.timeLeft}",
              style: TextStyle(
                color: isWarning ? Colors.red : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: isWarning ? 18 : 14,
              ),
            ),
            const SizedBox(height: 6),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 1.0, end: progress),
              duration: const Duration(milliseconds: 400),
              builder: (_, value, __) => LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: Colors.white10,
                valueColor: AlwaysStoppedAnimation(
                  isWarning ? Colors.red : Colors.amber,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}