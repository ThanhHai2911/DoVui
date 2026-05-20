import 'package:dovui/pages/quiz_image/logic/quiz_image_contoller.dart';
import 'package:flutter/material.dart';

class QuizImageInput extends StatelessWidget {
  final List<String> userInput;
  final Function(int) onRemove;
  final QuizImageController controller;

  const QuizImageInput({
    super.key,
    required this.userInput,
    required this.onRemove,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: controller.rebuildNotifier,
      builder: (context, _, __) {
        return LayoutBuilder(
          builder: (context, constraints) {
            double maxWidth = constraints.maxWidth;
            const double spacing = 8;
            const double minSize = 24.0;
            const double maxSize = 42.0;

            // Tính số ô tối đa mỗi hàng dựa trên minSize
            int maxPerRow =
                (maxWidth / (minSize + spacing)).floor().clamp(1, 10);
            int itemPerRow =
                userInput.length < maxPerRow ? userInput.length : maxPerRow;

            // Tính size thực tế để vừa đủ width
            double itemSize =
                (maxWidth - (spacing * (itemPerRow - 1))) / itemPerRow;
            itemSize = itemSize.clamp(minSize, maxSize);

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              alignment: WrapAlignment.center,
              children: List.generate(userInput.length, (index) {
                final filled = userInput[index];
                final hint = controller.getHintLetter(index);
                final isHint = hint != null && filled.isEmpty;
                final isEmpty = filled.isEmpty && hint == null;

                return _InputCell(
                  key: ValueKey('$index-$filled-$hint'),
                  letter: filled.isNotEmpty ? filled : hint ?? '',
                  itemSize: itemSize,
                  isHint: isHint,
                  isEmpty: isEmpty,
                  isFilled: filled.isNotEmpty,
                  onTap: () => onRemove(index),
                );
              }),
            );
          },
        );
      },
    );
  }
}

class _InputCell extends StatefulWidget {
  final String letter;
  final double itemSize;
  final bool isHint;
  final bool isEmpty;
  final bool isFilled;
  final VoidCallback onTap;

  const _InputCell({
    super.key,
    required this.letter,
    required this.itemSize,
    required this.isHint,
    required this.isEmpty,
    required this.isFilled,
    required this.onTap,
  });

  @override
  State<_InputCell> createState() => _InputCellState();
}

class _InputCellState extends State<_InputCell>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _bounceAnim;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );

    _bounceAnim = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );

    if (widget.isFilled || widget.isHint) {
      _ctrl.forward();
    }
  }

  @override
  void didUpdateWidget(_InputCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isFilled && widget.isFilled) {
      _ctrl.forward(from: 0);
    }
    if (oldWidget.isFilled && !widget.isFilled) {
      _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: widget.isEmpty
            ? Container(
                width: widget.itemSize,
                height: widget.itemSize,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF6C63FF).withOpacity(0.25),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              )
            : ScaleTransition(
                scale: widget.isHint ? _bounceAnim : _scaleAnim,
                child: Container(
                  width: widget.itemSize,
                  height: widget.itemSize,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: widget.isHint
                        ? LinearGradient(
                            colors: [
                              Colors.amber.shade300,
                              Colors.amber.shade500,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : const LinearGradient(
                            colors: [
                              Color(0xFF6C63FF),
                              Color(0xFF4FACFE),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: widget.isHint
                            ? Colors.amber.withOpacity(0.4)
                            : const Color(0xFF6C63FF).withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: 3,
                        left: 4,
                        child: Container(
                          width: widget.itemSize * 0.3,
                          height: widget.itemSize * 0.15,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      Text(
                        widget.letter,
                        style: TextStyle(
                          fontSize: widget.itemSize * 0.45,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}