import 'package:flutter/material.dart';

class AnswerCard extends StatefulWidget {
  final String text;
  final List<Color> gradient;
  final bool isCorrect;
  final bool isWrong;
  final bool isDisabled;
  final bool isEliminated;
  final int index;
  final VoidCallback? onTap;

  const AnswerCard({
    super.key,
    required this.text,
    required this.gradient,
    required this.isCorrect,
    required this.isWrong,
    required this.isDisabled,
    required this.isEliminated,
    required this.index,
    required this.onTap,
  });

  @override
  State<AnswerCard> createState() => _AnswerCardState();
}

class _AnswerCardState extends State<AnswerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _entryScale;
  late Animation<double> _entryFade;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _entryScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _entryFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );
    Future.delayed(Duration(milliseconds: 80 * widget.index), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _entryFade,
      child: ScaleTransition(
        scale: _entryScale,
        child: GestureDetector(
          onTapDown: (_) {
            if (!widget.isDisabled) setState(() => _pressed = true);
          },
          onTapUp: (_) {
            setState(() => _pressed = false);
            widget.onTap?.call();
          },
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.93 : 1.0,
            duration: const Duration(milliseconds: 80),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: widget.gradient[0].withOpacity(
                      _pressed ? 0.2 : 0.35,
                    ),
                    blurRadius: _pressed ? 4 : 12,
                    offset: Offset(0, _pressed ? 2 : 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // ── Highlight 3D ──
                  Positioned(
                    top: 8,
                    left: 10,
                    child: Container(
                      width: 50,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),

                  // ── Icon kết quả ──
                  if (!widget.isEliminated &&
                      (widget.isCorrect || widget.isWrong))
                    Positioned(
                      top: 8,
                      right: 8,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder:
                            (child, anim) =>
                                ScaleTransition(scale: anim, child: child),
                        child: Text(
                          widget.isCorrect ? "✅" : "❌",
                          key: ValueKey(widget.isCorrect),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),

                  // ── Nội dung chữ ──
                  Center(
                    child: Opacity(
                      opacity: widget.isEliminated ? 0.4 : 1.0,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          widget.text,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.3,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
