import 'package:flutter/material.dart';

class AnimatedTile extends StatefulWidget {
  final Widget child;
  final int index;

  const AnimatedTile({required this.child, required this.index, Key? key})
    : super(key: key);

  @override
  State<AnimatedTile> createState() => AnimatedTileState();
}

class AnimatedTileState extends State<AnimatedTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fade = Tween<double>(begin: 0, end: 1).animate(_ctrl);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(_ctrl);

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
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}