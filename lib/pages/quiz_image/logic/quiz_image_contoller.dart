import 'dart:async';
import 'dart:math';
import 'package:dovui/data/models/image_question_model.dart';
import 'package:flutter/material.dart';

class QuizImageController {
  final ImageQuestion question;

  late List<String> userInput;
  late List<String> letterPool;
  late String correctAnswer;
  final ValueNotifier<int> rebuildNotifier = ValueNotifier(0);

  Set<int> hintIndexes = {};

  int lives = 3;
  int timeLeft = 30;

  Timer? timer;

  VoidCallback? onUpdate;
  VoidCallback? onTimeUp;
  VoidCallback? onCorrect;

  QuizImageController(this.question) {
    init();
  }

  void stopTimer() {
    timer?.cancel();
  }

  void init() {
    // correctAnswer lấy thẳng từ getter của ImageQuestion
    correctAnswer = question.correctAnswer.replaceAll(" ", "").trim();
    userInput = List.generate(correctAnswer.length, (_) => "");
    _generateLetterPool();
  }

  void _generateLetterPool() {
    List<String> letters = correctAnswer.toUpperCase().split("");
    const extra = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    final random = Random();

    while (letters.length < correctAnswer.length + 4) {
      letters.add(extra[random.nextInt(extra.length)]);
    }

    letters.shuffle();
    letterPool = List.from(letters);
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
    if (letterPool[index].isEmpty) return;

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

    int poolIndex = letterPool.indexOf("");
    if (poolIndex != -1) {
      letterPool[poolIndex] = userInput[index];
    }

    userInput[index] = "";
    onUpdate?.call();
  }

  void checkAnswer() {
    timer?.cancel();

    final result = userInput.join();

    if (result.toLowerCase() == correctAnswer.toLowerCase()) {
      onCorrect?.call();
    } else {
      handleWrong();
    }
  }

  void _notifyUpdate() {
    rebuildNotifier.value++;
    onUpdate?.call();
  }

  /// Gợi ý từng cụm từ (word) trong đáp án
  void revealOneWord() {
    final words = question.correctAnswer.split(' ');

    int offset = 0;

    for (final word in words) {
      final wordLength = word.length;

      bool wordComplete = true;
      for (int i = offset; i < offset + wordLength; i++) {
        if (i < userInput.length &&
            userInput[i].isEmpty &&
            !hintIndexes.contains(i)) {
          wordComplete = false;
          break;
        }
      }

      if (!wordComplete) {
        for (int i = offset; i < offset + wordLength; i++) {
          if (i >= userInput.length) break;
          hintIndexes.add(i);
        }
        _notifyUpdate();
        return;
      }

      offset += wordLength;
    }
  }

  /// Gợi ý toàn bộ đáp án
  void revealAllWords() {
    final wordCount = question.correctAnswer.split(' ').length;
    for (int i = 0; i < wordCount; i++) {
      revealOneWord();
    }
    _notifyUpdate();
  }

  /// Trả về chữ gợi ý tại vị trí [index], null nếu không phải hint
  String? getHintLetter(int index) {
    if (!hintIndexes.contains(index)) return null;

    final words = question.correctAnswer.split(' ');

    int offset = 0;
    for (final word in words) {
      final wordLength = word.length;

      if (index >= offset && index < offset + wordLength) {
        final letter = correctAnswer[index];
        return index == offset ? letter.toUpperCase() : letter.toLowerCase();
      }

      offset += wordLength;
    }

    return null;
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

    _generateLetterPool();
    startTimer();
    onUpdate?.call();
  }

  void dispose() {
    rebuildNotifier.dispose();
    timer?.cancel();
  }
}