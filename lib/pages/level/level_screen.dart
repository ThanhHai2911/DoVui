import 'package:dovui/app/resources/color_manager.dart';
import 'package:dovui/models/man_model.dart';
import 'package:dovui/pages/category/widgets/category_shimmer.dart';
import 'package:dovui/pages/level/bloc/level_bloc.dart';
import 'package:dovui/pages/level/bloc/level_event.dart';
import 'package:dovui/pages/level/bloc/level_state.dart';
import 'package:dovui/pages/quiz/word_answer_screen.dart';
import 'package:dovui/services/quiz_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Levelscreen extends StatelessWidget {
  final String categoryId;
  final String type;

  const Levelscreen({super.key, required this.categoryId, required this.type});

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

                            return GestureDetector(
                              onTap: () {
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
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
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
                                    /// 🔥 Ảnh full phía trên
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(20),
                                            ),
                                        child: Image.asset(
                                          "assets/images/manchoi.png",
                                          fit: BoxFit.cover, // QUAN TRỌNG
                                        ),
                                      ),
                                    ),

                                    /// 🔽 Tên màn phía dưới
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Màn ${index + 1}",
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
