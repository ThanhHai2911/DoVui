import 'package:dovui/app/resources/color_manager.dart';
import 'package:dovui/models/topic_model.dart';
import 'package:dovui/pages/category/widgets/category_shimmer.dart';
import 'package:dovui/pages/it_topic/bloc/topic_bloc.dart';
import 'package:dovui/pages/it_topic/bloc/topic_event.dart';
import 'package:dovui/pages/it_topic/bloc/topic_state.dart';
import 'package:dovui/pages/level/level_screen.dart';
import 'package:dovui/pages/quiz/quiz_screen.dart';
import 'package:dovui/services/quiz_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ITTopicScreen extends StatelessWidget {
  final String categoryId;

  const ITTopicScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TopicBloc()..add(LoadTopics(categoryId)),
      child: Scaffold(
        backgroundColor: ColorManager.scaffoldBackground,
        body: SafeArea(
          child: BlocBuilder<TopicBloc, TopicState>(
            builder: (context, state) {
              if (state is TopicError) {
                return const Center(child: Text("Có lỗi xảy ra"));
              }

              if (state is TopicLoading) {
                return Column(
                  children: [
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        "Chọn ngôn ngữ",
                        style: TextStyle(
                          color: ColorManager.primaryDark,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CategoryShimmer(),
                      ),
                    ),
                  ],
                );
              }
              if (state is TopicLoaded) {
                final topics = state.topics;
                return Column(
                  children: [
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        "Chọn ngôn ngữ",
                        style: TextStyle(
                          color: ColorManager.primaryDark,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: GridView.builder(
                          itemCount: topics.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 20,
                                crossAxisSpacing: 20,
                                childAspectRatio: 0.95,
                              ),
                          itemBuilder: (context, index) {
                            final topic = topics[index];

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => QuizScreen(
                                          categoryId: topic.category,
                                          type: "kythuat",
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
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(20),
                                            ),
                                        child: Image.asset(
                                          topic.image,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      child: Text(
                                        topic.name,
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
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
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }
}
