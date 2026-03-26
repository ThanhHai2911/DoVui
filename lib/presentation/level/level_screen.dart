import 'package:dovui/app/resources/color_manager.dart';
import 'package:dovui/data/models/user_level_model.dart';
import 'package:dovui/presentation/category/widgets/category_shimmer.dart';
import 'package:dovui/presentation/level/bloc/level_bloc.dart';
import 'package:dovui/presentation/level/bloc/level_event.dart';
import 'package:dovui/presentation/level/bloc/level_state.dart';
import 'package:dovui/presentation/quiz/word_answer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Levelscreen extends StatelessWidget {
  final String categoryId;
  final String type;

  const Levelscreen({super.key, required this.categoryId, required this.type});

  /// Trả về màu tương ứng với trạng thái level
  Color _cardColor(String status) {
    switch (status) {
      case 'completed':
        return const Color(0xFF4CAF50); // ✅ Xanh lá — đạt ≥ 60%
      case 'failed':
        return const Color(0xFFF44336); // ❌ Đỏ — dưới 60%
      default:
        return Colors.white; // ⬜ Trắng — chưa chơi
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LevelBloc()..add(LoadLevels(categoryId)),
      child: Scaffold(
        backgroundColor: ColorManager.scaffoldBackground,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),

              const Center(
                child: Text(
                  "Danh sách màn",
                  style: TextStyle(
                    color: Color(0xff2E2B72),
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: BlocBuilder<LevelBloc, LevelState>(
                    builder: (context, state) {
                      if (state is LevelLoading) {
                        return const CategoryShimmer();
                      }

                      if (state is LevelLoaded) {
                        final levels = state.levels;
                        final statuses =
                            state.levelStatuses; // ✅ map trạng thái

                        return GridView.builder(
                          itemCount: levels.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 20,
                                crossAxisSpacing: 20,
                                childAspectRatio: 0.95,
                              ),
                          itemBuilder: (context, index) {
                            final level = levels[index];

                            final UserLevelModel? userLevel =
                                statuses[level.id];
                            final String status =
                                userLevel?.status ?? 'default';
                            final Color cardColor = _cardColor(status);

                            /// 🔥 CHECK UNLOCK
                            bool isUnlocked;

                            if (index == 0) {
                              isUnlocked = true;
                            } else {
                              final prevLevel = levels[index - 1];
                              final prevStatus = statuses[prevLevel.id]?.status;

                              isUnlocked = prevStatus == 'completed';
                            }

                            return GestureDetector(
                              onTap:
                                  isUnlocked
                                      ? () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => WordAnswerScreen(
                                                  categoryId: categoryId,
                                                  levelId: level.id,
                                                  type: type,
                                                ),
                                          ),
                                        ).then((_) {
                                          context.read<LevelBloc>().add(
                                            LoadLevels(categoryId),
                                          );
                                        });
                                      }
                                      : null, // ❌ khóa thì không cho click

                              child: Stack(
                                children: [
                                  /// 🔥 CARD
                                  Container(
                                    decoration: BoxDecoration(
                                      color: cardColor,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 6,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                  top: Radius.circular(20),
                                                ),
                                            child: Stack(
                                              children: [
                                                Image.asset(
                                                  "assets/images/manchoi.png",
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                ),

                                                /// 🔒 Overlay nếu bị khóa
                                                if (!isUnlocked)
                                                  Container(
                                                    color: Colors.black
                                                        .withOpacity(0.5),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          child: Column(
                                            children: [
                                              Text(
                                                "Màn ${index + 1}",
                                                style: TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      status == 'default'
                                                          ? Colors.black
                                                          : Colors.white,
                                                ),
                                              ),

                                              if (status != 'default') ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  status == 'completed'
                                                      ? '★ Hoàn thành'
                                                      : '✗ Chưa đạt',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  /// 🔥 ICON KHÓA
                                  if (!isUnlocked)
                                    const Positioned(
                                      bottom: 10,
                                      right: 10,
                                      child: Icon(
                                        Icons.lock,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        );
                      }

                      return const SizedBox();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
