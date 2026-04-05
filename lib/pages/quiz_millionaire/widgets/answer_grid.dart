import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/millionaire_bloc.dart';
import 'millionaire_colors.dart';

const _kLetters = ['A', 'B', 'C', 'D'];

// Màu accent riêng cho từng đáp án (trạng thái bình thường)
const _kAnswerAccents = [
  Color(0xFF5B4FE9), // tím
  Color(0xFF4FACFE), // xanh dương
  Color(0xFFFFB800), // vàng
  Color(0xFFFF6B9D), // hồng
];

class AnswerGrid extends StatelessWidget {
  const AnswerGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MillionaireBloc, MillionaireState>(
      builder: (context, state) {
        final q = state.currentQuestion;
        if (q == null) return const SizedBox.shrink();

        final disabled = state.isShowingResult || state.isShowPrizeLadder;

        return Column(
          children: List.generate(q.answers.length, (idx) {
            final isCorrect =
                state.isShowingResult && idx == q.correctIndex;
            final isWrong = state.isShowingResult &&
                idx == state.selectedIndex &&
                idx != q.correctIndex;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AnswerTile(
                key: ValueKey('${state.currentIndex}-$idx'),
                letter:     _kLetters[idx],
                text:       q.answers[idx],
                index:      idx,
                accent:     _kAnswerAccents[idx % _kAnswerAccents.length],
                isHidden:   state.hiddenAnswers.contains(idx),
                isCorrect:  isCorrect,
                isWrong:    isWrong,
                isDisabled: disabled,
                onTap: () => context
                    .read<MillionaireBloc>()
                    .add(MillionaireSelectAnswer(idx)),
              ),
            );
          }),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────
class AnswerTile extends StatefulWidget {
  final String       letter;
  final String       text;
  final int          index;
  final Color        accent;
  final bool         isHidden;
  final bool         isCorrect;
  final bool         isWrong;
  final bool         isDisabled;
  final VoidCallback? onTap;

  const AnswerTile({
    super.key,
    required this.letter,
    required this.text,
    required this.index,
    required this.accent,
    required this.isHidden,
    required this.isCorrect,
    required this.isWrong,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  State<AnswerTile> createState() => _AnswerTileState();
}

class _AnswerTileState extends State<AnswerTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _scale;
  late Animation<double>   _fade;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _scale = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0, 0.4, curve: Curves.easeIn)));
    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ── Màu theo trạng thái ──
  Color get _bg {
    if (widget.isCorrect) return MillionaireColors.correctBg;
    if (widget.isWrong)   return MillionaireColors.wrongBg;
    return MillionaireColors.bgAnswer;
  }

  Color get _borderColor {
    if (widget.isCorrect) return MillionaireColors.correct;
    if (widget.isWrong)   return MillionaireColors.wrong;
    return _pressed
        ? widget.accent
        : MillionaireColors.border;
  }

  Color get _letterBg {
    if (widget.isCorrect) return MillionaireColors.correct;
    if (widget.isWrong)   return MillionaireColors.wrong;
    return widget.accent;
  }

  Color get _textColor {
    if (widget.isCorrect) return MillionaireColors.correct;
    if (widget.isWrong)   return MillionaireColors.wrong;
    return MillionaireColors.textDark;
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: Opacity(
          opacity: widget.isHidden ? 0.2 : 1,
          child: GestureDetector(
            onTapDown: widget.isDisabled || widget.isHidden
                ? null
                : (_) => setState(() => _pressed = true),
            onTapUp: widget.isDisabled || widget.isHidden
                ? null
                : (_) {
                    setState(() => _pressed = false);
                    widget.onTap?.call();
                  },
            onTapCancel: () => setState(() => _pressed = false),
            child: AnimatedScale(
              scale:    _pressed ? 0.97 : 1.0,
              duration: const Duration(milliseconds: 80),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color:        _bg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _borderColor, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: _borderColor.withOpacity(
                          widget.isCorrect || widget.isWrong
                              ? 0.25
                              : _pressed ? 0.18 : 0.06),
                      blurRadius:
                          widget.isCorrect || widget.isWrong ? 16 : 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Letter badge
                    Container(
                      width:  34,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _letterBg,
                      ),
                      child: Center(
                        child: Text(
                          widget.letter,
                          style: const TextStyle(
                            fontSize:   13,
                            fontWeight: FontWeight.w900,
                            color:      Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    // Nội dung
                    Expanded(
                      child: Text(
                        widget.text,
                        style: TextStyle(
                          fontSize:   15,
                          fontWeight: FontWeight.w600,
                          color:      _textColor,
                          height:     1.2,
                        ),
                      ),
                    ),

                    // Icon kết quả
                    if (widget.isCorrect || widget.isWrong)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          transitionBuilder: (child, anim) =>
                              ScaleTransition(scale: anim, child: child),
                          child: Icon(
                            widget.isCorrect
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            key:   ValueKey(widget.isCorrect),
                            color: widget.isCorrect
                                ? MillionaireColors.correct
                                : MillionaireColors.wrong,
                            size:  22,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}