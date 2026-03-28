import 'package:dovui/resources/color_manager.dart';
import 'package:dovui/data/repositories/user_repository.dart';
import 'package:dovui/pages/category/categories_screen.dart';
import 'package:flutter/material.dart';

class QuizOfWeek extends StatefulWidget {
  const QuizOfWeek({super.key});

  @override
  State<QuizOfWeek> createState() => _QuizOfWeekState();
}

class _QuizOfWeekState extends State<QuizOfWeek>
    with SingleTickerProviderStateMixin {

  final userRepository = UserRepository();

  late AnimationController _floatCtrl;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _floatAnim = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween(begin: 0.9, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Column(
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
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6C63FF).withOpacity(0.15),
                  const Color(0xFF43C6AC).withOpacity(0.15),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: const Color(0xFF6C63FF).withOpacity(0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Stack(
              children: [

                /// background blob
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                ),

                Row(
                  children: [

                    /// LEFT CONTENT
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
                                  style: TextStyle(
                                      color: ColorManager.primaryText),
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
                                  builder: (_) => const Categoriesscreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorManager.gamecomplete,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Bắt đầu thử thách!",
                              style: TextStyle(
                                color: ColorManager.cardColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    /// RIGHT IMAGE
                    Expanded(
                      flex: 1,
                      child: AnimatedBuilder(
                        animation: _floatAnim,
                        builder: (_, child) {
                          return Transform.translate(
                            offset: Offset(0, _floatAnim.value),
                            child: child,
                          );
                        },
                        child: Image.asset(
                          "assets/images/win.png",
                          height: 80,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

