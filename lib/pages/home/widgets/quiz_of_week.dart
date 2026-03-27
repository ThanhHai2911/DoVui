import 'package:dovui/resources/color_manager.dart';
import 'package:dovui/data/repositories/user_repository.dart';
import 'package:dovui/pages/category/categories_screen.dart';
import 'package:flutter/material.dart';

class QuizOfWeek extends StatelessWidget {
  const QuizOfWeek({super.key});

  @override
  Widget build(BuildContext context) {
    final userRepository = UserRepository();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Thử thách trong tuần",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Thử thách",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    StreamBuilder<int>(
                      stream: userRepository.getTotalUsersStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text(
                            "Đang tải...",
                            style: TextStyle(color: ColorManager.primaryText),
                          );
                        }

                        final totalUsers = snapshot.data ?? 0;

                        return Text(
                          "$totalUsers người đang tranh tài – bạn có nằm trong top?",
                          style: const TextStyle(
                            color: ColorManager.primaryText,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Categoriesscreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorManager.gamecomplete,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Bắt đầu thử thách!",
                        style: TextStyle(color: ColorManager.cardColor),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                flex: 1,
                child: Image.asset(
                  "assets/images/win.png",
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
