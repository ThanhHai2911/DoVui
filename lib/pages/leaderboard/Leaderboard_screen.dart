import 'package:dovui/app/resources/color_manager.dart';
import 'package:dovui/pages/leaderboard/widgets/leaderboard.dart';
import 'package:dovui/pages/leaderboard/widgets/topusercard.dart';
import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

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
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                "Bảng xếp hạng",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color:  ColorManager.primaryDark
                ),
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  TopUserCard(
                    rank: "#2",
                    name: "Mike L.",
                    points: "640 points",
                    size: 70,
                  ),
                  TopUserCard(
                    rank: "#1",
                    name: "Anna D.",
                    points: "832 points",
                    size: 95,
                    isFirst: true,
                  ),
                  TopUserCard(
                    rank: "#3",
                    name: "Joe H.",
                    points: "599 points",
                    size: 70,
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Expanded(
                child: ListView(
                  children: const [
                    LeaderboardTile(
                      rank: "#4",
                      name: "Lea L.",
                      points: "530 points",
                    ),
                    LeaderboardTile(
                      rank: "#5",
                      name: "You",
                      points: "420 points",
                      isHighlight: true,
                    ),
                    LeaderboardTile(
                      rank: "#6",
                      name: "Sebastian M.",
                      points: "410 points",
                    ),
                    LeaderboardTile(
                      rank: "#7",
                      name: "Garfielda C.",
                      points: "390 points",
                    ),
                    LeaderboardTile(
                      rank: "#8",
                      name: "Garfielda C.",
                      points: "390 points",
                    ),
                    LeaderboardTile(
                      rank: "#9",
                      name: "Garfielda C.",
                      points: "390 points",
                    ),
                    LeaderboardTile(
                      rank: "#10",
                      name: "Garfielda C.",
                      points: "390 points",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
