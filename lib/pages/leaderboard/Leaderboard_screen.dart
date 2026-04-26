import 'package:dovui/data/audio/audio_manager.dart';
import 'package:dovui/pages/leaderboard/widgets/animated_podium.dart';
import 'package:dovui/pages/leaderboard/widgets/animated_tile.dart';
import 'package:dovui/pages/leaderboard/widgets/podium_column.dart';
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
import 'package:flutter/widgets.dart';
import 'dart:math';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  late AnimationController _floatCtrl;
  late Animation<double> _float;

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _float = Tween<double>(
      begin: -12,
      end: 12,
    ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    _entryCtrl.forward();
    AudioManager().init().then((_) {
      if (mounted) {
        AudioManager().playBackgroundMusic();
      }
    });
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {},
      child: BlocProvider(
        create:
            (_) =>
                LeaderboardBloc(LeaderboardRepository())
                  ..add(LoadLeaderboard()),
        child: Scaffold(
          backgroundColor: ColorManager.scaffoldBackground,
          body: Stack(
            children: [
              /// 🌈 BACKGROUND
              AnimatedBuilder(
                animation: _float,
                builder: (_, __) {
                  return Stack(
                    children: [
                      Positioned(
                        top: -60 + _float.value,
                        left: -40,
                        child: _blob(200, const Color(0xFF6C63FF), 0.07),
                      ),

                      Positioned(
                        top: 250 - _float.value,
                        right: -40,
                        child: _blob(160, const Color(0xFFFF6584), 0.06),
                      ),

                      Positioned(
                        bottom: 120 + _float.value,
                        left: -40,
                        child: _blob(150, const Color(0xFF43C6AC), 0.06),
                      ),
                    ],
                  );
                },
              ),

              SafeArea(
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

                      return FadeTransition(
                        opacity: _fade,
                        child: SlideTransition(
                          position: _slide,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Column(
                              children: [
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          "Bảng xếp hạng",
                                          style: TextStyle(
                                            fontSize: 36,
                                            fontWeight: FontWeight.bold,
                                            color: ColorManager.primaryDark,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                /// TITLE
                                const SizedBox(height: 10),

                                /// 🏆 TOP 3
                                if (users.isNotEmpty)
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final w = constraints.maxWidth;

                                      return Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          /// #2
                                          Expanded(
                                            child:
                                                users.length > 1
                                                    ? AnimatedPodium(
                                                      delay: 200,
                                                      child: PodiumColumn(
                                                        card: TopUserCard(
                                                          key: ValueKey(
                                                            users[1].id,
                                                          ),
                                                          rank: "#2",
                                                          name: users[1].name,
                                                          points:
                                                              "${users[1].score} ⭐",
                                                          size: w * 0.22,
                                                        ),
                                                        podiumHeight: w * 0.18,
                                                        podiumColor:
                                                            const Color(
                                                              0xFFD0D8F0,
                                                            ),
                                                        emoji: "🥈",
                                                      ),
                                                    )
                                                    : const SizedBox(),
                                          ),

                                          /// #1
                                          Expanded(
                                            child: AnimatedPodium(
                                              delay: 0,
                                              child: PodiumColumn(
                                                card: TopUserCard(
                                                  key: ValueKey(users[0].id),
                                                  rank: "#1",
                                                  name: users[0].name,
                                                  points: "${users[0].score} ⭐",
                                                  size: w * 0.30,
                                                  isFirst: true,
                                                ),
                                                podiumHeight: w * 0.26,
                                                podiumColor: const Color(
                                                  0xFF9DB4F5,
                                                ),
                                                emoji: "🥇",
                                              ),
                                            ),
                                          ),

                                          /// #3
                                          Expanded(
                                            child:
                                                users.length > 2
                                                    ? AnimatedPodium(
                                                      delay: 400,
                                                      child: PodiumColumn(
                                                        card: TopUserCard(
                                                          key: ValueKey(
                                                            users[2].id,
                                                          ),
                                                          rank: "#3",
                                                          name: users[2].name,
                                                          points:
                                                              "${users[2].score} ⭐",
                                                          size: w * 0.18,
                                                        ),
                                                        podiumHeight: w * 0.12,
                                                        podiumColor:
                                                            const Color(
                                                              0xFFE8C99A,
                                                            ),
                                                        emoji: "🥉",
                                                      ),
                                                    )
                                                    : const SizedBox(),
                                          ),
                                        ],
                                      );
                                    },
                                  ),

                                const SizedBox(height: 30),

                                /// 📋 DANH SÁCH
                                Expanded(
                                  child: ListView.builder(
                                    padding: EdgeInsets.only(
                                      bottom:
                                          MediaQuery.of(
                                            context,
                                          ).padding.bottom +
                                          80,
                                    ),
                                    itemCount:
                                        users.length > 3
                                            ? min(users.length - 3, 4)
                                            : 0,
                                    itemBuilder: (context, index) {
                                      final user = users[index + 3];

                                      return AnimatedTile(
                                        index: index,
                                        child: LeaderboardTile(
                                          key: ValueKey(user.id),
                                          rank: "#${index + 4}",
                                          name: user.name,
                                          points: "${user.score} ⭐",
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _blob(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(opacity),
      ),
    );
  }
}
