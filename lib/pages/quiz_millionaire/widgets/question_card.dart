import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/millionaire_bloc.dart';
import 'millionaire_colors.dart';

class QuestionCard extends StatefulWidget {
  const QuestionCard({super.key});

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard>
    with TickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;
  String _lastQuestion = '';

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _fade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0, 0.5, curve: Curves.easeIn)));
    _scale = Tween<double>(begin: 0.92, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.03).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _triggerAnim(String q) {
    if (q != _lastQuestion) {
      _lastQuestion = q;
      _ctrl.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MillionaireBloc, MillionaireState>(
      buildWhen: (p, c) => p.currentIndex != c.currentIndex,
      builder: (_, state) {
        final q = state.currentQuestion;
        if (q == null) return const SizedBox.shrink();
        _triggerAnim(q.question);

        return FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 26),
              decoration: BoxDecoration(
                color: MillionaireColors.bgCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: MillionaireColors.border, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: MillionaireColors.primary.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Badge số câu
                  ScaleTransition(
                    scale: _pulse,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 7),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF5B4FE9),
                            Color(0xFF9B8FFF),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: MillionaireColors.primary.withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        'CÂU ${state.questionNumber} / ${state.questions.length}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Nội dung câu hỏi
                  Text(
                    q.question,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: MillionaireColors.textDark,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Điểm câu này
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('⭐',
                          style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 4),
                      Text(
                        '${kPrizeLevels[state.currentIndex.clamp(0, 14)]} điểm',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: MillionaireColors.gold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}