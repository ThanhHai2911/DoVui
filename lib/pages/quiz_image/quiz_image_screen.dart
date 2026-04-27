import 'package:dovui/pages/ads/widgets/adsService.dart';
import 'package:dovui/pages/quiz_image/widgets/quiz_image_input.dart';
import 'package:dovui/pages/word_answer/widgets/%20word_answer_header.dart';
import 'package:dovui/resources/color_manager.dart';
import 'package:dovui/data/repositories/user_level_repository.dart';
import 'package:dovui/pages/gamecomplete/game_complete_screen.dart';
import 'package:dovui/pages/quiz_image/bloc/image_question_bloc.dart';
import 'package:dovui/pages/word_answer/widgets/letter_pool_widget.dart';
import 'package:dovui/pages/word_answer/widgets/word_answer_shimmer.dart';
// Extracted widgets:
import 'widgets/quiz_image_question_card.dart';
import 'widgets/quiz_image_hint_bar_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuizImageScreen extends StatefulWidget {
  final String categoryId;
  final String? levelId;
  final String type;
  final String? roomId;
  final bool isVip;

  const QuizImageScreen({
    super.key,
    required this.categoryId,
    required this.type,
    this.levelId,
    this.roomId,
    required this.isVip,
  });

  @override
  State<QuizImageScreen> createState() => _QuizImageScreenState();
}

class _QuizImageScreenState extends State<QuizImageScreen> with WidgetsBindingObserver {
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    final bloc = context.read<QuizImageBloc>();
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      bloc.add(QuizImagePauseTimer());
    } else if (state == AppLifecycleState.resumed) {
      bloc.add(QuizImageResumeTimer());
    }
  }

  Future<void> _saveResult({required int score, required int total}) async {
    if (widget.levelId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) return;
    final maxScore = total * 10;
    final percent = maxScore > 0 ? ((score / maxScore) * 10).round() : 0;
    _userLevelRepo.saveLevel(userId: userId, levelId: widget.levelId!, score: percent);
  }

  GameCompleteScreen _buildGameComplete({required int score, required int total}) {
    return GameCompleteScreen(
      score: score,
      totalQuestions: total,
      isWin: total > 0 && (score / (total * 10)) >= 0.6,
      categoryId: widget.categoryId,
      levelId: widget.levelId,
      type: widget.type,
      isVip: AdsService().isVip,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) {},
      child: BlocProvider(
        create: (_) => QuizImageBloc(
          categoryId: widget.categoryId,
          levelId: widget.levelId,
          type: widget.type,
        )..add(QuizImageLoadQuestions()),
        child: BlocConsumer<QuizImageBloc, QuizImageState>(
          listener: (context, state) async {
            if (state is QuizImageCompleted) {
              _saveResult(score: state.score, total: state.total);
              Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (_) => _buildGameComplete(score: state.score, total: state.total),
              ));
            }
            if (state is QuizImageTimeUp) {
              _saveResult(score: state.score, total: state.total);
              Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (_) => _buildGameComplete(score: state.score, total: state.total),
              ));
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
                              QuizImageQuestionCard(imageUrl: question.image),
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
                              const QuizImageHintBarHandler(),
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