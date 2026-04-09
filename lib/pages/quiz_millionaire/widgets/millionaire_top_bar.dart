import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/millionaire_bloc.dart';
import 'audience_dialog.dart';
import 'millionaire_colors.dart';

class MillionaireTopBar extends StatelessWidget {
  const MillionaireTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MillionaireBloc, MillionaireState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: MillionaireColors.gold.withOpacity(0.15),
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Lifelines ─────────────────────────────
              _LifelineBtn(
                label: '50 : 50',
                icon: '✂️',
                used: state.ll5050Used,
                disabled: !state.isPlaying,
                onTap:
                    () =>
                        context.read<MillionaireBloc>().add(UseLifeline5050()),
              ),
              // const SizedBox(width: 8),
              // _LifelineBtn(
              //   label: 'Gợi ý',
              //   icon: '💡',
              //   used: state.llHintUsed,
              //   disabled: !state.isPlaying,
              //   onTap: () {
              //     final q = state.currentQuestion;
              //     if (q == null) return;
              //     context.read<MillionaireBloc>().add(UseLifelineHint());
              //     showDialog(
              //       context: context,
              //       builder:
              //           (_) => HintDialog(
              //             question: q.question,
              //             answers: q.answers,
              //           ),
              //     );
              //   },
              // ),
              const SizedBox(width: 8),
              _LifelineBtn(
                label: 'Khán giả',
                icon: '👥',
                used: state.llAudienceUsed,
                disabled: !state.isPlaying,
                onTap: () {
                  final q = state.currentQuestion;
                  if (q == null) return;
                  context.read<MillionaireBloc>().add(UseLifelineAudience());
                  showDialog(
                    context: context,
                    builder:
                        (_) => AudienceDialog(
                          correctIndex: q.correctIndex,
                          answerCount: q.answers.length,
                        ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LifelineBtn extends StatelessWidget {
  final String label;
  final String icon;
  final bool used;
  final bool disabled;
  final VoidCallback onTap;

  const _LifelineBtn({
    required this.label,
    required this.icon,
    required this.used,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = !used && !disabled;

    return GestureDetector(
      onTap: active ? onTap : null,
      child: AnimatedOpacity(
        opacity: active ? 1.0 : 0.35,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color:
                active
                    ? MillionaireColors.gold.withOpacity(0.12)
                    : Colors.white10,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: active ? MillionaireColors.gold : Colors.white24,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: active ? MillionaireColors.gold : Colors.white38,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              if (used) ...[
                const SizedBox(width: 4),
                const Text(
                  '✗',
                  style: TextStyle(color: Colors.red, fontSize: 11),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
