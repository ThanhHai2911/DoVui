import 'package:dovui/app/resources/color_manager.dart';
import 'package:dovui/presentation/gamecomplete/game_complete_sceen.dart';
import 'package:dovui/presentation/quiz/bloc/quiz_event.dart';
import 'package:dovui/presentation/quiz/bloc/quiz_state.dart';
import 'package:dovui/presentation/quiz/widgets/answer_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/quiz_bloc.dart';

class QuizScreen extends StatelessWidget {
  final String categoryId;
  final String? levelId;
  final String type;

  const QuizScreen({
    super.key,
    required this.categoryId,
    required this.type,
    this.levelId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuizBloc()
        ..add(
          LoadQuiz(
            categoryId: categoryId,
            levelId: levelId,
            type: type,
          ),
        ),
      child: BlocConsumer<QuizBloc, QuizState>(
        listener: (context, state) {
          if (state.isGameOver) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => GameCompleteScreen(
                  score: state.score,
                  totalQuestions: state.questions.length,
                  isWin: state.isWin,
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state.questions.isEmpty) {
            return const Scaffold(
              body: Center(
                child: Text(
                  "Chưa có câu hỏi cho chuyên đề này",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            );
          }

          if (state.currentQuestion == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            backgroundColor: ColorManager.scaffoldBackground,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    /// HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${state.questionCount}/${state.questions.length}",
                          style: const TextStyle(
                            color: ColorManager.primaryTextColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        /// ❤️ Lives
                        Row(
                          children: List.generate(3, (index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: Icon(
                                Icons.favorite,
                                size: 18,
                                color: index < state.lives
                                    ? Colors.red
                                    : Colors.white24,
                              ),
                            );
                          }),
                        ),

                        Text(
                          "${state.timeLeft}s",
                          style: const TextStyle(
                            color: ColorManager.primaryTextColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    LinearProgressIndicator(
                      value: state.timeLeft / 15,
                      backgroundColor: ColorManager.backgroundthanh,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        ColorManager.primaryText,
                      ),
                    ),

                    const SizedBox(height: 30),

                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: Center(
                                child: Text(
                                  state.currentQuestion!.question,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            Expanded(
                              child: GridView.builder(
                                itemCount:
                                    state.currentQuestion!.answers.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 1.2,
                                ),
                                itemBuilder: (context, index) {
                                  Color color = Colors.blue;

                                  if (state.showResult) {
                                    if (index ==
                                        state.currentQuestion!.correctIndex) {
                                      color = Colors.green;
                                    } else if (index ==
                                        state.selectedIndex) {
                                      color = Colors.red;
                                    }
                                  }

                                  return AnswerItem(
                                    text: state.currentQuestion!
                                        .answers[index],
                                    color: color,
                                    onTap: state.showResult
                                        ? null
                                        : () => context
                                            .read<QuizBloc>()
                                            .add(SelectAnswer(index)),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}