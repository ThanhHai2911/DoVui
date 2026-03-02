import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class QuizShimmer extends StatelessWidget {
  const QuizShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(height: 20, width: 120, color: Colors.white),
            const SizedBox(height: 30),
            Container(height: 150, color: Colors.white),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.builder(
                itemCount: 4,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemBuilder: (_, __) =>
                    Container(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}