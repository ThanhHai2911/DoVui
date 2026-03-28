import 'package:flutter/material.dart';

class LetterPoolWidget extends StatelessWidget {
  final List<String> letters;
  final Function(int) onSelect;

  const LetterPoolWidget({
    super.key,
    required this.letters,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth = constraints.maxWidth;
        const double spacing = 10;
        int maxPerRow = maxWidth > 600 ? 10 : 7;
        int itemPerRow =
            letters.length < maxPerRow ? letters.length : maxPerRow;
        double itemSize =
            (maxWidth - (spacing * (itemPerRow - 1))) / itemPerRow;
        itemSize = itemSize.clamp(28.0, 42.0);

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          alignment: WrapAlignment.center,
          children: List.generate(letters.length, (index) {
            if (letters[index].isEmpty) {
              return SizedBox(width: itemSize, height: itemSize);
            }

            return _LetterTile(
              key: ValueKey('$index-${letters[index]}'),
              letter: letters[index],
              itemSize: itemSize,
              index: index,
              onSelect: onSelect,
            );
          }),
        );
      },
    );
  }
}

class _LetterTile extends StatefulWidget {
  final String letter;
  final double itemSize;
  final int index;
  final Function(int) onSelect;

  const _LetterTile({
    super.key,
    required this.letter,
    required this.itemSize,
    required this.index,
    required this.onSelect,
  });

  @override
  State<_LetterTile> createState() => _LetterTileState();
}

class _LetterTileState extends State<_LetterTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _entryScale;
  late Animation<double> _entryFade;
  bool _pressed = false;

  // Màu gradient theo index — xoay vòng
  static const List<List<Color>> _gradients = [
    [Color(0xFF6C63FF), Color(0xFF9B8FFF)],
    [Color(0xFFFF6584), Color(0xFFFF99AA)],
    [Color(0xFF43C6AC), Color(0xFF77E8D2)],
    [Color(0xFFFFB347), Color(0xFFFFD08A)],
    [Color(0xFF4FACFE), Color(0xFF00F2FE)],
    [Color(0xFFA18CD1), Color(0xFFFBC2EB)],
    [Color(0xFFF093FB), Color(0xFFF5576C)],
  ];

  List<Color> get _tileGradient =>
      _gradients[widget.index % _gradients.length];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _entryScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    _entryFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // Stagger theo index
    Future.delayed(Duration(milliseconds: 30 * widget.index), () {
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
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) {
            setState(() => _pressed = false);
            widget.onSelect(widget.index);
          },
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.82 : 1.0,
            duration: const Duration(milliseconds: 80),
            child: Container(
              width: widget.itemSize,
              height: widget.itemSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _tileGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _tileGradient[0].withOpacity(
                      _pressed ? 0.2 : 0.45,
                    ),
                    blurRadius: _pressed ? 4 : 10,
                    offset: Offset(0, _pressed ? 1 : 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Highlight góc trên — hiệu ứng 3D
                  Positioned(
                    top: 3,
                    left: 4,
                    child: Container(
                      width: widget.itemSize * 0.32,
                      height: widget.itemSize * 0.14,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  // Chữ cái
                  Text(
                    widget.letter,
                    style: TextStyle(
                      fontSize: widget.itemSize * 0.46,
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
      ),
    );
  }
}