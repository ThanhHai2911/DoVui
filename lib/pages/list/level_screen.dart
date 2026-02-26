import 'package:dovui/models/man_model.dart';
import 'package:dovui/pages/category/widgets/category_shimmer.dart';
import 'package:dovui/pages/question/question_screen.dart';
import 'package:dovui/pages/question/wordanswer_screen.dart';
import 'package:dovui/services/quiz_service.dart';
import 'package:flutter/material.dart';

class Levelscreen extends StatelessWidget {
  final String categoryId;
  final String type;
  const Levelscreen({super.key, required this.categoryId,required this.type,});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: SafeArea(
        child: StreamBuilder<List<LevelModel>>(
          stream: QuizService.getLevels(categoryId),
          builder: (context, snapshot) {
            final bool isLoading =
                snapshot.connectionState == ConnectionState.waiting ||
                !snapshot.hasData ||
                snapshot.data!.isEmpty;

            final levels = snapshot.data ?? [];

            return Column(
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
                const SizedBox(height: 30),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child:
                        isLoading
                            ? const CategoryShimmer()
                            : GridView.builder(
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
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          "assets/images/man.jpg",
                                          height: 80,
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          "Màn ${index + 1}",
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
