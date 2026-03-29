import 'package:dovui/pages/ads/ads_service.dart';
import 'package:dovui/pages/home/widgets/game_dialog.dart';
import 'package:dovui/pages/quiz_image/bloc/image_question_bloc.dart';
import 'package:dovui/resources/color_manager.dart';
import 'package:dovui/pages/user/bloc/user_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeHeader extends StatefulWidget {
  const HomeHeader({super.key});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveCtrl;
  late Animation<double> _waveAnim;

  @override
  void initState() {
    super.initState();

    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _waveAnim = Tween<double>(
      begin: -6,
      end: 6,
    ).animate(CurvedAnimation(parent: _waveCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      buildWhen: (previous, current) => current is UserRegistered,
      builder: (context, state) {
        String name = "Admin";
        int score = 300;

        if (state is UserRegistered) {
          name = state.user.name;
          score = state.user.score;
        }

        return TweenAnimationBuilder(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ROW HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// HELLO TEXT
                  Row(
                    children: [
                      AnimatedBuilder(
                        animation: _waveAnim,
                        builder: (_, child) {
                          return Transform.translate(
                            offset: Offset(0, _waveAnim.value),
                            child: child,
                          );
                        },
                        child: const Text("👋", style: TextStyle(fontSize: 18)),
                      ),

                      const SizedBox(width: 6),

                      Text(
                        "Xin Chào, $name",
                        style: const TextStyle(
                          fontSize: 16,
                          color: ColorManager.primaryText,
                        ),
                      ),
                    ],
                  ),

                  /// SCORE CARD
                  GestureDetector(
                    onTap:
                        () => showGameDialog(
                          context: context,
                          icon: "🛠️",
                          iconColor: Colors.orange,
                          title: "Tính năng đang phát triển",
                          description:
                              "Chức năng mở đáp án đang được cập nhật.\nVui lòng quay lại sau nhé!",
                          costIcon: "⭐",
                          costText: "Sắp ra mắt",
                          confirmText: "Đã hiểu",
                          confirmColor: Colors.orange,
                          showCancel: false,
                          onConfirm: () {},
                        ),
                    child: TweenAnimationBuilder(
                      tween: Tween(begin: 0.9, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutBack,
                      builder: (_, value, child) {
                        return Transform.scale(scale: value, child: child);
                      },
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.amber.withOpacity(0.25),
                                  Colors.orange.withOpacity(0.25),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withOpacity(0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "$score",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// BUTTON +
                          Positioned(
                            bottom: -6,
                            left: -6,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              /// TITLE
              ShaderMask(
                shaderCallback:
                    (bounds) => const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF43C6AC)],
                    ).createShader(bounds),
                child: const Text(
                  "Cùng chơi nào!",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
