import 'dart:async';
import 'dart:math';
import 'package:dovui/models/question_model.dart';
import 'package:dovui/pages/question/widgets/answer_item.dart';
import 'package:dovui/services/quiz_service.dart';
import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  final String categoryId;

  const QuizScreen({super.key, required this.categoryId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<QuestionModel> questions = [];
  List<int> usedIndexes = [];

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
    loadQuestions();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> loadQuestions() async {
    questions = await QuizService.getQuestions(widget.categoryId);

    if (questions.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = false;
    });

    getRandomQuestion();
  }

  void startTimer() {
    timeLeft = 15;
    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft <= 0) {
        t.cancel();
        nextQuestion();
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

    setState(() {
      selectedIndex = index;
      showResult = true;
    });

    if (index == currentQuestion!.correctIndex) {
      score++;
    }

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) nextQuestion();
    });
  }

  void nextQuestion() {
    if (mounted) {
      getRandomQuestion();
    }
  }

  Future<void> finishQuiz() async {
    timer?.cancel();

    await QuizService.saveScore(score, questions.length);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("🎉 Hoàn thành!"),
        content: Text("Bạn đạt $score/${questions.length} điểm"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              resetQuiz();
            },
            child: const Text("Chơi lại"),
          )
        ],
      ),
    );
  }

  void resetQuiz() {
    setState(() {
      score = 0;
      questionCount = 0;
      usedIndexes.clear();
    });

    getRandomQuestion();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xff6C4BFF),
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
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Điểm: $score",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "$timeLeft s",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              LinearProgressIndicator(
                value: timeLeft / 15,
                backgroundColor: Colors.white24,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.white),
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
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Expanded(
                        child: GridView.builder(
                          itemCount:
                              currentQuestion!.answers.length,
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
                              if (index ==
                                  currentQuestion!.correctIndex) {
                                color = Colors.green;
                              } else if (index ==
                                  selectedIndex) {
                                color = Colors.red;
                              }
                            }

                            return AnswerItem(
                              text: currentQuestion!.answers[index],
                              color: color,
                              onTap: showResult
                                  ? null
                                  : () => checkAnswer(index),
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