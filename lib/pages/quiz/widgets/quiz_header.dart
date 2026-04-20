import 'package:flutter/material.dart';
import 'package:dovui/pages/quiz/bloc/quiz_state.dart';

class QuizHeader extends StatelessWidget {
  final QuizState state;
  final Animation<double> shakeAnim;

  const QuizHeader({super.key, required this.state, required this.shakeAnim});

  Color _timeColor(int t) {
    if (t <= 5) return const Color(0xFFFF6584);
    if (t <= 10) return const Color(0xFFFFB347);
    return const Color(0xFF43C6AC);
  }

  @override
  Widget build(BuildContext context) {
    final timeColor = _timeColor(state.timeLeft);
    final isWarning = state.timeLeft <= 5;

    return Row(
      children: [
        _QuestionCounter(current: state.questionCount, total: state.questions.length),
        const Spacer(),
        _LivesIndicator(lives: state.lives),
        const Spacer(),
        _TimerBadge(
          timeLeft: state.timeLeft,
          timeColor: timeColor,
          isWarning: isWarning,
          shakeAnim: shakeAnim,
        ),
      ],
    );
  }
}

class _QuestionCounter extends StatelessWidget {
  final int current;
  final int total;

  const _QuestionCounter({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return _BadgeContainer(
      borderColor: const Color(0xFF6C63FF).withOpacity(0.2),
      shadowColor: const Color(0xFF6C63FF).withOpacity(0.15),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('📝', style: TextStyle(fontSize: 13)),
          const SizedBox(width: 5),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$current',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6C63FF),
                  ),
                ),
                TextSpan(
                  text: '/$total',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LivesIndicator extends StatelessWidget {
  final int lives;

  const _LivesIndicator({required this.lives});

  @override
  Widget build(BuildContext context) {
    return _BadgeContainer(
      borderColor: Colors.red.withOpacity(0.2),
      shadowColor: Colors.red.withOpacity(0.15),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          final active = index < lives;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(
                active ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                key: ValueKey('$index-$active'),
                size: 20,
                color: active ? Colors.red.shade400 : Colors.grey.shade300,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _TimerBadge extends StatelessWidget {
  final int timeLeft;
  final Color timeColor;
  final bool isWarning;
  final Animation<double> shakeAnim;

  const _TimerBadge({
    required this.timeLeft,
    required this.timeColor,
    required this.isWarning,
    required this.shakeAnim,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shakeAnim,
      builder: (_, child) => Transform.translate(
        offset: Offset(isWarning ? shakeAnim.value : 0, 0),
        child: child,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isWarning ? timeColor.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: timeColor.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(color: timeColor.withOpacity(0.4), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isWarning ? '⏰' : '⏱️', style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 5),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isWarning ? 16 : 14,
                fontWeight: FontWeight.bold,
                color: timeColor,
              ),
              child: Text('${timeLeft}s'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeContainer extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final Color shadowColor;

  const _BadgeContainer({
    required this.child,
    required this.borderColor,
    required this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: shadowColor, blurRadius: 8, offset: const Offset(0, 3)),
        ],
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: child,
    );
  }
}