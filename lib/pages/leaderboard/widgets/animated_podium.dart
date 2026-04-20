import 'package:flutter/material.dart';

class AnimatedPodium extends StatefulWidget {
  final Widget child;
  final int delay;

  const AnimatedPodium({required this.child, required this.delay});

  @override
  State<AnimatedPodium> createState() => AnimatedPodiumState();
}

class AnimatedPodiumState extends State<AnimatedPodium>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scale = Tween<double>(
      begin: 0.7,
      end: 1,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));

    Future.delayed(Duration(milliseconds: widget.delay), () {
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
    return ScaleTransition(scale: _scale, child: widget.child);
  }
}
