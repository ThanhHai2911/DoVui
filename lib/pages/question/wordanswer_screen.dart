import 'package:dovui/pages/gamecomplete/game_complete_sceen.dart';
import 'package:dovui/pages/question/widgets/%20word_answer_header.dart';
import 'package:dovui/pages/question/widgets/%20word_answer_input.dart';
import 'package:dovui/pages/question/widgets/letter_pool_widget.dart';
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

  @override
  void initState() {
    super.initState();

    QuizService.getQuestions(
      categoryId: widget.categoryId,
      levelId: widget.levelId,
      type: widget.type,
    ).first.then((data) {
      if (!mounted) return;
      if (data.isEmpty) return;

      questions = data;
      currentIndex = 0;

      loadCurrentQuestion();
    });
  }

  void loadCurrentQuestion() {
    if (currentIndex >= questions.length) {
      showGameCompleted();
      return;
    }

    final q = questions[currentIndex];

    setState(() {
      question = q;

      controller =
          WordAnswerController(q)
            ..onUpdate = () {
              if (mounted) setState(() {});
            }
            ..onTimeUp = () {
              if (!mounted) return;

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => GameCompleteScreen(
                        score: score,
                        totalQuestions: questions.length,
                        isWin: false,
                      ),
                ),
              );
            }
            ..onCorrect = () {
              if (!mounted) return;

              score++; // 👈 tăng điểm

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
        builder:
            (_) => GameCompleteScreen(
              score: score,
              totalQuestions: questions.length,
              isWin: score == questions.length,
            ),
      ),
    );

    // Nếu bấm "Chơi lại"
    if (result == true) {
      setState(() {
        score = 0;
        currentIndex = 0;
      });

      loadCurrentQuestion();
    }
  }

  void loadQuestion() {
    QuizService.getQuestions(
      categoryId: widget.categoryId,
      levelId: widget.levelId,
      type: widget.type,
    ).first.then((data) {
      if (!mounted) return;
      if (data.isEmpty) return;

      final q = data.first;

      setState(() {
        question = q;

        controller =
            WordAnswerController(q)
              ..onUpdate = () {
                if (mounted) setState(() {});
              }
              /// Hết tim -> hiện dialog thay vì thoát
              ..onTimeUp = () {
                if (!mounted) return;

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => GameCompleteScreen(
                          score: score,
                          totalQuestions: questions.length,
                          isWin: false,
                        ),
                  ),
                );
              }
              /// Trả lời đúng -> load câu mới
              ..onCorrect = () {
                if (!mounted) return;

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("🎉 Chính xác!")));

                Future.delayed(const Duration(milliseconds: 800), () {
                  if (!mounted) return;
                  loadQuestion();
                });
              };

        controller!.startTimer();
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || controller == null || question == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xff3A3472),
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
                    /// ===== CARD CÂU HỎI =====
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 35,
                        vertical: 50,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 15,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "🎵 Ghép tên bài hát",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            question!.question,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    /// ===== Ô TRẢ LỜI (GIỮA MÀN HÌNH) =====
                    WordAnswerInput(
                      userInput: controller!.userInput,
                      onRemove: controller!.removeLetter,
                    ),

                    const Spacer(),

                    /// ===== Ô CHỌN CHỮ (SÁT ĐÁY) =====
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
