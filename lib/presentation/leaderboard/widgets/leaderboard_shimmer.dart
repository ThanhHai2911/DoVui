import 'package:dovui/app/resources/color_manager.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LeaderboardShimmer extends StatelessWidget {
  const LeaderboardShimmer({super.key});

  Widget _box({double height = 20, double width = double.infinity}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.scaffoldBackground,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).padding.bottom + 20,
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Column(
              children: [
                const SizedBox(height: 20),

                /// Title
                _box(height: 36, width: 220),

                const SizedBox(height: 30),

                /// Top 3 users
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _box(height: 90, width: 70),
                    _box(height: 120, width: 95),
                    _box(height: 90, width: 70),
                  ],
                ),

                const SizedBox(height: 30),

                /// List
                Expanded(
                  child: ListView.separated(
                    itemCount: 7,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (_, __) => _box(height: 60),
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