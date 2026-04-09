import 'package:dovui/data/audio/audio_manager.dart';
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
      AudioManager().playBackgroundMusic();
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
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                const SizedBox(height: 20),

                                /// TITLE
                                const Text(
                                  "Bảng xếp hạng",
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: ColorManager.primaryDark,
                                  ),
                                ),

                                const SizedBox(height: 30),

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
                                                    ? _AnimatedPodium(
                                                      delay: 200,
                                                      child: _PodiumColumn(
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
                                            child: _AnimatedPodium(
                                              delay: 0,
                                              child: _PodiumColumn(
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
                                                    ? _AnimatedPodium(
                                                      delay: 400,
                                                      child: _PodiumColumn(
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
                                        users.length >= 8
                                            ? 4
                                            : (users.length > 3
                                                ? users.length - 3
                                                : 0),
                                    itemBuilder: (context, index) {
                                      final user = users[index + 3];

                                      return _AnimatedTile(
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

/// PODIUM ANIMATION
class _AnimatedPodium extends StatefulWidget {
  final Widget child;
  final int delay;

  const _AnimatedPodium({required this.child, required this.delay});

  @override
  State<_AnimatedPodium> createState() => _AnimatedPodiumState();
}

class _AnimatedPodiumState extends State<_AnimatedPodium>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scale = Tween<double>(
      begin: 0.7,
      end: 1,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scale, child: widget.child);
  }
}

/// LIST ANIMATION
class _AnimatedTile extends StatefulWidget {
  final Widget child;
  final int index;

  const _AnimatedTile({required this.child, required this.index, Key? key})
    : super(key: key);

  @override
  State<_AnimatedTile> createState() => _AnimatedTileState();
}

class _AnimatedTileState extends State<_AnimatedTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fade = Tween<double>(begin: 0, end: 1).animate(_ctrl);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(_ctrl);

    Future.delayed(Duration(milliseconds: 80 * widget.index), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
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
          width: double.infinity,
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
