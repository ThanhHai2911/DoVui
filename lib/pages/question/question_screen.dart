import 'dart:async';
import 'dart:math';
import 'package:dovui/app/resources/color_manager.dart';
import 'package:dovui/models/question_model.dart';
import 'package:dovui/pages/gamecomplete/game_complete_sceen.dart';
import 'package:dovui/pages/question/widgets/answer_item.dart';
import 'package:dovui/services/quiz_service.dart';
import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
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
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<QuestionModel> questions = [];
  List<int> usedIndexes = [];
  int lives = 3;
  StreamSubscription<List<QuestionModel>>? _questionSubscription;

  QuestionModel? currentQuestion;

  int? selectedIndex;
  int score = 0;
  int questionCount = 0;

  Timer? timer;
  int timeLeft = 15;

  bool showResult = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    listenQuestions();
  }

  @override
  void dispose() {
    timer?.cancel();
    _questionSubscription?.cancel();
    loadQuestions();
    super.dispose();
  
  }

  void loadQuestions() async {
    setState(() {
      isLoading = true;
    });

    try {
      questions = await QuizService.fetchQuestions(widget.categoryId);
      getRandomQuestion();
    } catch (e) {
      print(e);
    }

    setState(() {
      isLoading = false;
    });
  }

  void listenQuestions() {
    _questionSubscription = QuizService.getQuestions(
      categoryId: widget.categoryId,
      levelId: widget.levelId,
      type: widget.type,
    ).listen((data) {
      if (!mounted) return;

      setState(() {
        questions = data;
        isLoading = false;
      });

      if (currentQuestion == null && questions.isNotEmpty) {
        getRandomQuestion();
      }
    });
  }

  void startTimer() {
    timeLeft = 15;
    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft <= 0) {
        t.cancel();

        // ❗ Hết thời gian = trừ mạng
        setState(() {
          showResult = true;
          selectedIndex = null; // không chọn đáp án nào
          lives--;
        });

        // Nếu hết mạng -> thua
        if (lives <= 0) {
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) finishGameByLose();
          });
          return;
        }

        // Nếu còn mạng -> sang câu mới
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) nextQuestion();
        });
      } else {
        if (mounted) {
          setState(() {
            timeLeft--;
          });
        }
      }
    });
  }

  void getRandomQuestion() {
    if (questions.isEmpty) return;

    if (usedIndexes.length == questions.length) {
      finishQuiz();
      return;
    }

    final random = Random();
    int index;

    do {
      index = random.nextInt(questions.length);
    } while (usedIndexes.contains(index));

    usedIndexes.add(index);

    setState(() {
      currentQuestion = questions[index];
      selectedIndex = null;
      showResult = false;
      questionCount++;
    });

    startTimer();
  }

  void checkAnswer(int index) {
    if (currentQuestion == null) return;

    timer?.cancel();

    bool isCorrect = index == currentQuestion!.correctIndex;

    setState(() {
      selectedIndex = index;
      showResult = true;

      if (isCorrect) {
        score++;
      } else {
        lives--;
      }
    });

    if (lives <= 0) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) finishGameByLose();
      });
      return;
    }

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) nextQuestion();
    });
  }

  Future<void> finishGameByLose() async {
    timer?.cancel();
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
    ).then((playAgain) {
      if (playAgain == true) {
        resetQuiz();
      }
    });
  }

  void nextQuestion() {
    if (mounted) {
      getRandomQuestion();
    }
  }

  Future<void> finishQuiz() async {
    timer?.cancel();
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (_) => GameCompleteScreen(
              score: score,
              totalQuestions: questions.length,
              isWin: true,
            ),
      ),
    ).then((playAgain) {
      if (playAgain == true) {
        resetQuiz();
      }
    });
  }

  void resetQuiz() {
    setState(() {
      score = 0;
      questionCount = 0;
      usedIndexes.clear();
      lives = 3;
    });

    getRandomQuestion();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (questions.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text(
            "Chưa có câu hỏi cho chuyên đề này",
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    if (currentQuestion == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
                    "$questionCount/${questions.length}",
                    style: const TextStyle(
                      color: ColorManager.primaryTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // ❤️ HIỂN THỊ MẠNG
                  Row(
                    children: List.generate(3, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Icon(
                          Icons.favorite,
                          size: 18,
                          color: index < lives ? Colors.red : Colors.white24,
                        ),
                      );
                    }),
                  ),

                  Text(
                    "$timeLeft s",
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
                value: timeLeft / 15,
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
                            currentQuestion!.question,
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
                          itemCount: currentQuestion!.answers.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1.2,
                              ),
                          itemBuilder: (context, index) {
                            Color color = Colors.blue;

                            if (showResult) {
                              if (index == currentQuestion!.correctIndex) {
                                color = Colors.green;
                              } else if (index == selectedIndex) {
                                color = Colors.red;
                              }
                            }

                            return AnswerItem(
                              text: currentQuestion!.answers[index],
                              color: color,
                              onTap:
                                  showResult ? null : () => checkAnswer(index),
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
  }
}
