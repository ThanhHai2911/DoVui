import 'package:dovui/pages/ads/ads_service.dart';
import 'package:dovui/pages/home/widgets/check_score.dart';
import 'package:dovui/pages/home/widgets/game_dialog.dart';
import 'package:dovui/pages/quiz_image/widgets/quiz_image_input.dart';
import 'package:dovui/pages/word_answer/widgets/hint_bar.dart';
import 'package:dovui/resources/color_manager.dart';
import 'package:dovui/data/repositories/user_level_repository.dart';
import 'package:dovui/pages/gamecomplete/game_complete_screen.dart';
import 'package:dovui/pages/quiz_image/bloc/image_question_bloc.dart';
import 'package:dovui/pages/word_answer/widgets/letter_pool_widget.dart';
import 'package:dovui/pages/word_answer/widgets/word_answer_shimmer.dart';
import 'package:dovui/pages/word_answer/widgets/%20word_answer_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuizImageScreen extends StatefulWidget {
  final String categoryId;
  final String? levelId;
  final String type;
  final String? roomId;

  const QuizImageScreen({
    super.key,
    required this.categoryId,
    required this.type,
    this.levelId,
    this.roomId,
  });

  @override
  State<QuizImageScreen> createState() => _QuizImageScreenState();
}

class _QuizImageScreenState extends State<QuizImageScreen>
    with WidgetsBindingObserver {
  final _userLevelRepo = UserLevelRepository();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Pause/resume khi app vào background hoặc quay lại
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    final bloc = context.read<QuizImageBloc>();
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      bloc.add(QuizImagePauseTimer());
    } else if (state == AppLifecycleState.resumed) {
      bloc.add(QuizImageResumeTimer());
    }
  }

  Future<void> _saveResult({required int score, required int total}) async {
    if (widget.levelId == null) return;

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("userId");
    if (userId == null) return;

    final maxScore = total * 10;
    final percent = maxScore > 0 ? ((score / maxScore) * 10).round() : 0;

    _userLevelRepo.saveLevel(
      userId: userId,
      levelId: widget.levelId!,
      score: percent,
    );
  }

  void _onVideoTap(BuildContext context) {
    if (!RewardedAdManager().isAdLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⏳ Quảng cáo chưa sẵn sàng, thử lại sau!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showGameDialog(
      context: context,
      icon: "🎬",
      iconColor: Colors.purple,
      title: "Xem video nhận gợi ý?",
      description: "Xem 1 video ngắn để\nhé lộ toàn bộ đáp án miễn phí!",
      costIcon: "🎬",
      costText: "Xem video",
      confirmText: "Xem ngay!",
      confirmColor: Colors.purple,
      showCancel: true,
      onConfirm: () {
        context.read<QuizImageBloc>().add(QuizImagePauseTimer()); // ⏸ dừng

        RewardedAdManager().showAd(
          onRewarded: () {
            context.read<QuizImageBloc>().add(QuizImageUseSkipFree());
            context.read<QuizImageBloc>().add(QuizImageResumeTimer()); // ▶ tiếp
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🎉 Đáp án đã được mở!'),
                  backgroundColor: Color(0xFF43C6AC),
                ),
              );
            }
          },
          onFailed: () {
            context.read<QuizImageBloc>().add(
              QuizImageResumeTimer(),
            ); // ▶ tiếp dù thất bại
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('❌ Không tải được quảng cáo, thử lại sau!'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {},
      child: BlocProvider(
        create:
            (_) => QuizImageBloc(
              categoryId: widget.categoryId,
              levelId: widget.levelId,
              type: widget.type,
            )..add(QuizImageLoadQuestions()),
        child: BlocConsumer<QuizImageBloc, QuizImageState>(
          listener: (context, state) async {
            if (state is QuizImageCompleted) {
              _saveResult(score: state.score, total: state.total);

              // NativeAdManager().preloadPool();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => GameCompleteScreen(
                        score: state.score,
                        totalQuestions: state.total,
                        isWin:
                            state.total > 0 &&
                            (state.score / (state.total * 10)) >= 0.6,
                        categoryId: widget.categoryId,
                        levelId: widget.levelId,
                        type: widget.type,
                      ),
                ),
              );
            }

            if (state is QuizImageTimeUp) {
              _saveResult(score: state.score, total: state.total);
              // RepaintBoundary(child: NativeAdWidget());
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => GameCompleteScreen(
                        score: state.score,
                        totalQuestions: state.total,
                        isWin:
                            state.total > 0 &&
                            (state.score / (state.total * 10)) >= 0.6,
                        categoryId: widget.categoryId,
                        levelId: widget.levelId,
                        type: widget.type,
                      ),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is QuizImageLoading) return const WordAnswerShimmer();

            if (state is QuizImageLoaded) {
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
  borderRadius: BorderRadius.circular(16),
  child: Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: Colors.grey.shade300, // viền nhẹ
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 6,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        question.image,
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover, // 👈 QUAN TRỌNG (đẹp hơn contain)
      ),
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
                                  final score =
                                      context
                                          .read<QuizImageBloc>()
                                          .currentScore;
                                  checkScoreAndShowHint(
                                    context: context,
                                    currentScore: score,
                                    cost: 50,
                                    hintIcon: "🔍",
                                    hintTitle: "Gợi ý chữ cái",
                                    hintDescription:
                                        "Hé lộ 1 chữ cái đúng\ncho câu trả lời hiện tại",
                                    hintColor: Colors.amber,
                                    confirmText: "Dùng ngay!",
                                    onConfirm:
                                        () => context.read<QuizImageBloc>().add(
                                          QuizImageUseHintLetter(),
                                        ),
                                  );
                                },
                                onKey: () {
                                  final score =
                                      context
                                          .read<QuizImageBloc>()
                                          .currentScore;
                                  checkScoreAndShowHint(
                                    context: context,
                                    currentScore: score,
                                    cost: 100,
                                    hintIcon: "🗝️",
                                    hintTitle: "Mở đáp án",
                                    hintDescription:
                                        "Hiện toàn bộ đáp án\ncâu hỏi hiện tại",
                                    hintColor: Colors.deepPurple,
                                    confirmText: "Mở thôi!",
                                    onConfirm:
                                        () => context.read<QuizImageBloc>().add(
                                          QuizImageUseSkip(),
                                        ),
                                  );
                                },
                                onVideo: () => _onVideoTap(context),
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
      ),
    );
  }
}
