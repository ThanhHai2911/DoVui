import 'package:dovui/app/resources/color_manager.dart';
import 'package:dovui/data/repositories/leaderboard_repository.dart';
import 'package:dovui/presentation/leaderboard/bloc/leaderboard_bloc.dart';
import 'package:dovui/presentation/leaderboard/bloc/leaderboard_event.dart';
import 'package:dovui/presentation/leaderboard/bloc/leaderboard_state.dart';
import 'package:dovui/presentation/leaderboard/widgets/leaderboard.dart';
import 'package:dovui/presentation/leaderboard/widgets/leaderboard_shimmer.dart';
import 'package:dovui/presentation/leaderboard/widgets/topusercard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) =>
              LeaderboardBloc(LeaderboardRepository())..add(LoadLeaderboard()),
      child: Scaffold(
        backgroundColor: ColorManager.scaffoldBackground,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: BlocBuilder<LeaderboardBloc, LeaderboardState>(
            builder: (context, state) {
              if (state is LeaderboardLoading) {
                return const LeaderboardShimmer();
              }

              if (state is LeaderboardLoaded) {
                final users = state.users;

                if (users.isEmpty) {
                  return const Center(child: Text("Chưa có dữ liệu"));
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        "Bảng xếp hạng",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: ColorManager.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 30),

                      /// 🔥 TOP 3
                      if (users.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (users.length > 1)
                              TopUserCard(
                                rank: "#2",
                                name: users[1].name,
                                points: "${users[1].score} Điểm",
                                size: 70,
                              )
                            else
                              const SizedBox(width: 70),

                            TopUserCard(
                              rank: "#1",
                              name: users[0].name,
                              points: "${users[0].score} Điểm",
                              size: 95,
                              isFirst: true,
                            ),

                            if (users.length > 2)
                              TopUserCard(
                                rank: "#3",
                                name: users[2].name,
                                points: "${users[2].score} Điểm",
                                size: 70,
                              )
                            else
                              const SizedBox(width: 70),
                          ],
                        ),

                      const SizedBox(height: 30),

                      /// 🔥 DANH SÁCH CÒN LẠI
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).padding.bottom + 80,
                          ),
                          itemCount: users.length > 3 ? users.length - 3 : 0,
                          itemBuilder: (context, index) {
                            final user = users[index + 3];

                            return LeaderboardTile(
                              rank: "#${index + 4}",
                              name: user.name,
                              points: "${user.score} Điểm",
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }

              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }
}
