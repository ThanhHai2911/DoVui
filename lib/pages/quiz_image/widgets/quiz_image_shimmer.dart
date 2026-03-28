import 'package:dovui/shimmer/app_shimmer.dart';
import 'package:flutter/material.dart';

class WordAnswerShimmer extends StatelessWidget {
  const WordAnswerShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: const [
              SizedBox(height: 15),

              AppShimmer(height: 50, radius: 12),

              SizedBox(height: 30),

              AppShimmer(height: 180, radius: 30),

              Spacer(),

              AppShimmer(height: 60, radius: 16),

              Spacer(),

              AppShimmer(height: 100, radius: 20),

              SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}