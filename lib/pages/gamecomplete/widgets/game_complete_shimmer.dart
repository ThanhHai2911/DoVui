import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class GameCompleteShimmer extends StatelessWidget {
  const GameCompleteShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 20),
          Container(width: 150, height: 20, color: Colors.white),
          const SizedBox(height: 20),
          Container(width: 120, height: 25, color: Colors.white),
          const SizedBox(height: 30),
          Container(
            width: double.infinity,
            height: 45,
            color: Colors.white,
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 45,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}