import 'dart:async';
import 'dart:math';
import 'package:dovui/models/question_model.dart';
import 'package:flutter/material.dart';

class WordAnswerController {
  QuestionModel question;

  late List<String> userInput;
  late List<String> letterPool;

  int lives = 3;
  int timeLeft = 30;

  Timer? timer;
  VoidCallback? onUpdate;
  VoidCallback? onTimeUp;
  VoidCallback? onCorrect;

  WordAnswerController(this.question) {
    init();
  }

  void init() {
    String answer =
        question.answers[question.correctIndex].replaceAll(" ", "");

    userInput = List.generate(answer.length, (_) => "");
    generateLetterPool(answer);
  }

  void generateLetterPool(String correctAnswer) {
    List<String> letters = correctAnswer.split("");
    const extra = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    final random = Random();

    while (letters.length < correctAnswer.length + 4) {
      letters.add(extra[random.nextInt(extra.length)]);
    }

    letters.shuffle();
    letterPool = letters;
  }

  void startTimer() {
    timer?.cancel();
    timeLeft = 30;

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft > 0) {
        timeLeft--;
        onUpdate?.call();
      } else {
        t.cancel();
        handleWrong();
      }
    });
  }

  void selectLetter(int index) {
    int emptyIndex = userInput.indexOf("");

    if (emptyIndex == -1) return;

    userInput[emptyIndex] = letterPool[index];
    letterPool[index] = "";

    onUpdate?.call();

    if (!userInput.contains("")) {
      checkAnswer();
    }
  }

  void removeLetter(int index) {
    if (userInput[index].isEmpty) return;

    letterPool.add(userInput[index]);
    userInput[index] = "";

    onUpdate?.call();
  }

  void checkAnswer() {
    String result = userInput.join().trim();
    String correct =
        question.answers[question.correctIndex].replaceAll(" ", "").trim();

    timer?.cancel();

    if (result.toLowerCase() == correct.toLowerCase()) {
      onCorrect?.call();
    } else {
      handleWrong();
    }
  }

  void handleWrong() {
    lives--;

    if (lives <= 0) {
      onTimeUp?.call();
      return;
    }

    for (int i = 0; i < userInput.length; i++) {
      userInput[i] = "";
    }

    generateLetterPool(
        question.answers[question.correctIndex].replaceAll(" ", ""));

    startTimer();
    onUpdate?.call();
  }

  void dispose() {
    timer?.cancel();
  }
}