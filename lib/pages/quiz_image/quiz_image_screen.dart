import 'package:dovui/pages/home/widgets/game_dialog.dart';
import 'package:dovui/pages/quiz_image/widgets/quiz_image_input.dart';
import 'package:dovui/pages/word_answer/widgets/hint_bar.dart';
import 'package:dovui/resources/color_manager.dart';
import 'package:dovui/data/repositories/user_level_repository.dart';
import 'package:dovui/pages/gamecomplete/game_complete_sceen.dart';
import 'package:dovui/pages/quiz_image/bloc/image_question_bloc.dart';
import 'package:dovui/pages/word_answer/widgets/letter_pool_widget.dart';
import 'package:dovui/pages/word_answer/widgets/word_answer_shimmer.dart';
import 'package:dovui/pages/word_answer/widgets/%20word_answer_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuizImageScreen extends StatelessWidget {
  final String categoryId;
  final String? levelId;
  final String type;

  final _userLevelRepo = UserLevelRepository();

  QuizImageScreen({
    super.key,
    required this.categoryId,
    required this.type,
    this.levelId,
  });

  Future<void> _saveResult({required int score, required int total}) async {
  if (levelId == null) return;
  final maxScore = total * 10;
  final percent = maxScore > 0 ? ((score / maxScore) * 10).round() : 0;
  await _userLevelRepo.saveLevel(levelId: levelId!, score: percent);
}

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) => QuizImageBloc(
            categoryId: categoryId,
            levelId: levelId,
            type: type,
          )..add(QuizImageLoadQuestions()),
      child: BlocConsumer<QuizImageBloc, QuizImageState>(
        listener: (context, state) async {
          if (state is QuizImageCompleted) {
            await _saveResult(score: state.score, total: state.total);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (_) => GameCompleteScreen(
                      score: state.score,
                      totalQuestions: state.total,
                      isWin: state.total > 0 && (state.score / (state.total * 10)) >= 0.6,
                      categoryId: categoryId,
                      levelId: levelId,
                      type: type,
                    ),
              ),
            );
          }

          if (state is QuizImageTimeUp) {
            await _saveResult(score: state.score, total: state.total);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (_) => GameCompleteScreen(
                      score: state.score,
                      totalQuestions: state.total,
                      isWin: state.total > 0 && (state.score / (state.total * 10)) >= 0.6,
                      categoryId: categoryId,
                      levelId: levelId,
                      type: type,
                    ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is QuizImageLoading) {
            return const WordAnswerShimmer();
          }

          if (state is QuizImageLoaded) {
            final controller = state.controller;
            final question = state.question; // ✅ ImageQuestion

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
                                final screenWidth = constraints.maxWidth;
                                final horizontalPadding = screenWidth * 0.08;
                                final verticalPadding = screenWidth * 0.05;
                                final titleFont = (screenWidth * 0.045).clamp(
                                  14.0,
                                  22.0,
                                );

                                return Container(
                                  width: double.infinity,
                                  margin: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.02,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: horizontalPadding,
                                    vertical: verticalPadding,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ColorManager.cardColor,
                                    borderRadius: BorderRadius.circular(
                                      screenWidth * 0.06,
                                    ),
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
                                        "🖼️ Đoán tên qua hình ảnh 🖼️",
                                        style: TextStyle(
                                          fontSize: titleFont,
                                          color: ColorManager.text,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: screenWidth * 0.05),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: SizedBox(
                                          height: 150,
                                          width: double.infinity,
                                          child: Image.network(
                                            question.image,
                                            height: 150,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (
                                              context,
                                              child,
                                              loadingProgress,
                                            ) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Container(
                                                color: Colors.grey.shade100,
                                                child: const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                ),
                                              );
                                            },
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              return Container(
                                                color: Colors.grey.shade200,
                                                child: const Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.broken_image,
                                                      color: Colors.grey,
                                                      size: 40,
                                                    ),
                                                    SizedBox(height: 8),
                                                    Text("Không tải được ảnh"),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const Spacer(),
                            QuizImageInput(
                              userInput: controller.userInput,
                              onRemove: controller.removeLetter,
                              controller: controller,
                            ),
                            const Spacer(),
                            LetterPoolWidget(
                              letters: controller.letterPool,
                              onSelect: controller.selectLetter,
                            ),
                            const SizedBox(height: 20),
                            HintBar(
                              onMagnifier: () {
                                showGameDialog(
                                  context: context,
                                  icon: "🔍",
                                  iconColor: Colors.amber,
                                  title: "Gợi ý chữ cái",
                                  description:
                                      "Hé lộ 1 chữ cái đúng\ncho câu trả lời hiện tại",
                                  costIcon: "⭐",
                                  costText: "Tốn 50 sao",
                                  confirmText: "Dùng ngay!",
                                  confirmColor: Colors.amber,
                                  onConfirm:
                                      () => context.read<QuizImageBloc>().add(
                                        QuizImageUseHintLetter(),
                                      ),
                                );
                              },
                              onKey: () {
                                showGameDialog(
                                  context: context,
                                  icon: "🗝️",
                                  iconColor: Colors.deepPurple,
                                  title: "Mở đáp án",
                                  description:
                                      "Hiện toàn bộ đáp án\ncâu hỏi hiện tại",
                                  costIcon: "⭐",
                                  costText: "Tốn 100 sao",
                                  confirmText: "Mở thôi!",
                                  confirmColor: Colors.deepPurple,
                                  onConfirm:
                                      () => context.read<QuizImageBloc>().add(
                                        QuizImageUseSkip(),
                                      ),
                                );
                              },
                              onVideo: () {
                                showGameDialog(
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
                                  onConfirm: () {
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is QuizImageError) {
            return Scaffold(body: Center(child: Text(state.message)));
          }

          return const WordAnswerShimmer();
        },
      ),
    );
  }
}

