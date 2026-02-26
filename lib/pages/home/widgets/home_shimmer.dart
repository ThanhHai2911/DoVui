import 'package:dovui/shimmer/app_shimmer.dart';
import 'package:flutter/material.dart';

class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          const AppShimmer(height: 60),

          const SizedBox(height: 25),

          const AppShimmer(height: 120),

          const SizedBox(height: 30),

          const AppShimmer(height: 150),

          const SizedBox(height: 30),

          const AppShimmer(height: 20, width: 120),

          const SizedBox(height: 20),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 1,
            ),
            itemBuilder: (_, __) =>
                const AppShimmer(height: 120),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}