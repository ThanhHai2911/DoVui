import 'dart:math';

import 'package:flutter/material.dart';

class Particles extends StatefulWidget {
  const Particles();

  @override
  State<Particles> createState() => _ParticlesState();
}

class _ParticlesState extends State<Particles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random random = Random();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose(); // 🔥 QUAN TRỌNG
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Stack(
          children: List.generate(15, (index) {
            final size = random.nextDouble() * 12 + 6;
            final dx = random.nextDouble() * MediaQuery.of(context).size.width;
            final dy = random.nextDouble() * MediaQuery.of(context).size.height;

            return Positioned(
              left: dx,
              top: dy - (_controller.value * 80),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}