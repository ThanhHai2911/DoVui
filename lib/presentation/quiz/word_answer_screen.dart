import 'package:dovui/app/resources/color_manager.dart';
import 'package:dovui/data/repositories/user_level_repository.dart'; // ✅
import 'package:dovui/presentation/gamecomplete/game_complete_sceen.dart';
import 'package:dovui/presentation/quiz/bloc/word_answer_bloc.dart';
import 'package:dovui/presentation/quiz/bloc/word_answer_event.dart';
import 'package:dovui/presentation/quiz/bloc/word_answer_state.dart';
import 'package:dovui/presentation/quiz/widgets/%20word_answer_header.dart';
import 'package:dovui/presentation/quiz/widgets/%20word_answer_input.dart';
import 'package:dovui/presentation/quiz/widgets/letter_pool_widget.dart';
import 'package:dovui/presentation/quiz/widgets/word_answer_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WordAnswerScreen extends StatelessWidget {
  final String categoryId;
  final String? levelId;
  final String type;

  // ✅ Dùng UserLevelRepository thay cho gọi Firestore thẳng
  final _userLevelRepo = UserLevelRepository();

  WordAnswerScreen({
    super.key,
    required this.categoryId,
    required this.type,
    this.levelId,
  });

  /// ✅ Tính % và lưu lên Firestore
  Future<void> _saveResult({
  required int score,
  required int total,
}) async {
  if (levelId == null) return;

  final percent = total > 0 ? ((score / total) * 100).round() : 0;

  await _userLevelRepo.saveLevel(
    levelId: levelId!,
    score: percent,
  );
}


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WordAnswerBloc(
        categoryId: categoryId,
        levelId: levelId,
        type: type,
      )..add(LoadQuestions()),
      child: BlocConsumer<WordAnswerBloc, WordAnswerState>(
        listener: (context, state) async {
          // ✅ Lưu kết quả trước khi chuyển màn
          if (state is WordAnswerCompleted) {
            await _saveResult(score: state.score, total: state.total);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => GameCompleteScreen(
                  score: state.score,
                  totalQuestions: state.total,
                  isWin: state.score == state.total,
                  categoryId: categoryId,
                  levelId: levelId,
                  type: type,
                ),
              ),
            );
          }

          if (state is WordAnswerTimeUp) {
            await _saveResult(score: state.score, total: state.total);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => GameCompleteScreen(
                  score: state.score,
                  totalQuestions: state.total,
                  isWin: false,
                  categoryId: categoryId,
                  levelId: levelId,
                  type: type,
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is WordAnswerLoading) {
            return const WordAnswerShimmer();
          }

          if (state is WordAnswerLoaded) {
            final controller = state.controller;
            final question = state.question;

            return Scaffold(
              backgroundColor: ColorManager.scaffoldBackground,
              body: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    WordAnswerHeader(
                      lives: controller.lives,
                      timeLeft: controller.timeLeft,
                      currentIndex: state.currentIndex,
                      totalQuestions: state.questions.length,
                    ),
                    const SizedBox(height: 30),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            LayoutBuilder(
                              builder: (context, constraints) {
                                double screenWidth = constraints.maxWidth;
                                double horizontalPadding = screenWidth * 0.08;
                                double verticalPadding = screenWidth * 0.12;
                                double titleFont = (screenWidth * 0.045).clamp(14.0, 22.0);
                                double questionFont = (screenWidth * 0.07).clamp(18.0, 30.0);

                                return Container(
                                  width: double.infinity,
                                  margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: horizontalPadding,
                                    vertical: verticalPadding,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ColorManager.cardColor,
                                    borderRadius: BorderRadius.circular(screenWidth * 0.06),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: screenWidth * 0.04,
                                        offset: Offset(0, screenWidth * 0.02),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "🎵 Ghép tên bài hát 🎵",
                                        style: TextStyle(
                                          fontSize: titleFont,
                                          color: ColorManager.text,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: screenWidth * 0.05),
                                      Text(
                                        question.question,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: questionFont,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const Spacer(),
                            WordAnswerInput(
                              userInput: controller.userInput,
                              onRemove: controller.removeLetter,
                            ),
                            const Spacer(),
                            LetterPoolWidget(
                              letters: controller.letterPool,
                              onSelect: controller.selectLetter,
                            ),
                            const SizedBox(height: 60),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return const WordAnswerShimmer();
        },
      ),
    );
  }
}