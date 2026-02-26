import 'dart:async';
import 'package:dovui/app/resources/color_manager.dart';
import 'package:dovui/pages/gamecomplete/game_complete_sceen.dart';
import 'package:dovui/pages/question/widgets/%20word_answer_header.dart';
import 'package:dovui/pages/question/widgets/%20word_answer_input.dart';
import 'package:dovui/pages/question/widgets/letter_pool_widget.dart';
import 'package:dovui/pages/question/widgets/word_answer_shimmer.dart';
import 'package:dovui/pages/question/logic/word_answer_controller.dart';
import 'package:flutter/material.dart';
import 'package:dovui/services/quiz_service.dart';
import 'package:dovui/models/question_model.dart';

class WordAnswerScreen extends StatefulWidget {
  final String categoryId;
  final String? levelId;
  final String type;

  const WordAnswerScreen({
    super.key,
    required this.categoryId,
    required this.type,
    this.levelId,
  });

  @override
  State<WordAnswerScreen> createState() => _WordAnswerScreenState();
}

class _WordAnswerScreenState extends State<WordAnswerScreen> {
  WordAnswerController? controller;
  QuestionModel? question;
  bool isLoading = true;

  List<QuestionModel> questions = [];
  int currentIndex = 0;
  int score = 0;

  StreamSubscription<List<QuestionModel>>? _subscription;

  @override
  void initState() {
    super.initState();
    listenQuestions();
  }

  void listenQuestions() {
    isLoading = true;

    _subscription = QuizService.getQuestions(
      categoryId: widget.categoryId,
      levelId: widget.levelId,
      type: widget.type,
    ).listen((data) {
      if (!mounted) return;

      if (data.isNotEmpty) {
        questions = data;
        currentIndex = 0;
        loadCurrentQuestion();
      }
    });
  }

  void loadCurrentQuestion() {
    if (currentIndex >= questions.length) {
      showGameCompleted();
      return;
    }

    final q = questions[currentIndex];

    controller?.dispose();

    setState(() {
      question = q;

      controller = WordAnswerController(q)
        ..onUpdate = () {
          if (mounted) setState(() {});
        }
        ..onTimeUp = () {
          if (!mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => GameCompleteScreen(
                score: score,
                totalQuestions: questions.length,
                isWin: false,
              ),
            ),
          );
        }
        ..onCorrect = () {
          if (!mounted) return;

          score++;

          Future.delayed(const Duration(milliseconds: 500), () {
            if (!mounted) return;
            currentIndex++;
            loadCurrentQuestion();
          });
        };

      controller!.startTimer();
      isLoading = false;
    });
  }

  void showGameCompleted() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameCompleteScreen(
          score: score,
          totalQuestions: questions.length,
          isWin: score == questions.length,
        ),
      ),
    );

    if (result == true) {
      setState(() {
        score = 0;
        currentIndex = 0;
      });

      loadCurrentQuestion();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || controller == null || question == null) {
      return const WordAnswerShimmer();
    }

    return Scaffold(
      backgroundColor: ColorManager.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 15),

            WordAnswerHeader(
              lives: controller!.lives,
              timeLeft: controller!.timeLeft,
              currentIndex: currentIndex,
              totalQuestions: questions.length,
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

                        double titleFont =
                            (screenWidth * 0.045).clamp(14.0, 22.0);
                        double questionFont =
                            (screenWidth * 0.07).clamp(18.0, 30.0);

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
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.06),
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
                                question!.question,
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
                      userInput: controller!.userInput,
                      onRemove: controller!.removeLetter,
                    ),

                    const Spacer(),

                    LetterPoolWidget(
                      letters: controller!.letterPool,
                      onSelect: controller!.selectLetter,
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
}