import 'package:dovui/pages/ads/ads_service.dart';
import 'package:dovui/resources/color_manager.dart';
import 'package:dovui/pages/user/bloc/user_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hàng ngang: "Xin Chào, name" + score card
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Xin Chào, $name",
                  style: const TextStyle(
                    fontSize: 16,
                    color: ColorManager.primaryText,
                  ),
                ),

                // Card vàng + Stack để đặt nút +
                GestureDetector(
                  onTap: () => _showRewardDialog(context),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Card vàng
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 20),
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

                      // Nút + nhỏ, góc dưới trái
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
              ],
            ),

            const SizedBox(height: 8),

            // Dòng "Cùng chơi nào!"
            const Text(
              "Cùng chơi nào!",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: ColorManager.primaryDark,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showRewardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Nhận thêm vàng"),
        content: const Text("Xem quảng cáo để nhận 10 vàng?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              AdsService.showRewardedAd(() {
                context.read<UserBloc>().add(AddScoreEvent(10));
              });
            },
            child: const Text("Xem ngay"),
          ),
        ],
      ),
    );
  }
}