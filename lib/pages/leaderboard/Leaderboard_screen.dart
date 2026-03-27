import 'package:dovui/resources/color_manager.dart';
import 'package:dovui/data/repositories/leaderboard_repository.dart';
import 'package:dovui/pages/leaderboard/bloc/leaderboard_bloc.dart';
import 'package:dovui/pages/leaderboard/bloc/leaderboard_event.dart';
import 'package:dovui/pages/leaderboard/bloc/leaderboard_state.dart';
import 'package:dovui/pages/leaderboard/widgets/leaderboard.dart';
import 'package:dovui/pages/leaderboard/widgets/leaderboard_shimmer.dart';
import 'package:dovui/pages/leaderboard/widgets/topusercard.dart';
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
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final w = constraints.maxWidth;

                            return Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.end, // ✅ căn đáy
                              children: [
                                // 🥈 #2
                                Expanded(
                                  child:
                                      users.length > 1
                                          ? _PodiumColumn(
                                            card: TopUserCard(
                                              rank: "#2",
                                              name: users[1].name,
                                              points: "${users[1].score} ⭐",
                                              size: w * 0.22,
                                            ),
                                            podiumHeight: w * 0.18,
                                            podiumColor: const Color(
                                              0xFFD0D8F0,
                                            ),
                                            emoji: "🥈",
                                          )
                                          : const SizedBox(),
                                ),

                                // 🥇 #1
                                Expanded(
                                  child: _PodiumColumn(
                                    card: TopUserCard(
                                      rank: "#1",
                                      name: users[0].name,
                                      points: "${users[0].score} ⭐",
                                      size: w * 0.30,
                                      isFirst: true,
                                    ),
                                    podiumHeight: w * 0.26,
                                    podiumColor: const Color(0xFF9DB4F5),
                                    emoji: "🥇",
                                  ),
                                ),

                                // 🥉 #3
                                Expanded(
                                  child:
                                      users.length > 2
                                          ? _PodiumColumn(
                                            card: TopUserCard(
                                              rank: "#3",
                                              name: users[2].name,
                                              points: "${users[2].score} ⭐",
                                              size: w * 0.18,
                                            ),
                                            podiumHeight: w * 0.12,
                                            podiumColor: const Color(
                                              0xFFE8C99A,
                                            ),
                                            emoji: "🥉",
                                          )
                                          : const SizedBox(),
                                ),
                              ],
                            );
                          },
                        ),

                      const SizedBox(height: 30),

                      /// 🔥 DANH SÁCH CÒN LẠI
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).padding.bottom + 80,
                          ),
                          itemCount:
                              users.length >= 8
                                  ? 4
                                  : (users.length > 3 ? users.length - 3 : 0),
                          itemBuilder: (context, index) {
                            final user = users[index + 3];

                            return LeaderboardTile(
                              rank: "#${index + 4}",
                              name: user.name,
                              points: "${user.score} ⭐",
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

class _PodiumColumn extends StatelessWidget {
  final Widget card;
  final double podiumHeight;
  final Color podiumColor;
  final String emoji;

  const _PodiumColumn({
    required this.card,
    required this.podiumHeight,
    required this.podiumColor,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        card,
        const SizedBox(height: 6),
        Container(
          width: double.infinity, // ✅ chiếm full width của Expanded
          height: podiumHeight,
          decoration: BoxDecoration(
            color: podiumColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          alignment: Alignment.center,
          child: Text(emoji, style: const TextStyle(fontSize: 24)),
        ),
      ],
    );
  }
}
