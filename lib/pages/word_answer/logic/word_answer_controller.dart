import 'dart:async';
import 'dart:math';
import 'package:dovui/data/models/question_model.dart';
import 'package:flutter/material.dart';

class WordAnswerController {
  final QuestionModel question;

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

  WordAnswerController(this.question) {
    init();
  }
  void stopTimer() {
    timer?.cancel();
  }

  void init() {
    correctAnswer =
        question.answers[question.correctIndex].replaceAll(" ", "").trim();

    userInput = List.generate(correctAnswer.length, (_) => "");
    _generateLetterPool();
  }

  void _generateLetterPool() {
    List<String> letters = correctAnswer.split("");
    const extra = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    final random = Random();

    // Thêm 4 chữ random
    while (letters.length < correctAnswer.length + 4) {
      letters.add(extra[random.nextInt(extra.length)]);
    }

    letters.shuffle();
    letterPool = List.from(letters); // đảm bảo list mới
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

    // Trả chữ về đúng vị trí trống đầu tiên trong pool
    int poolIndex = letterPool.indexOf("");
    if (poolIndex != -1) {
      letterPool[poolIndex] = userInput[index];
    }

    userInput[index] = "";
    onUpdate?.call();
  }

  void checkAnswer() {
    timer?.cancel();

    String result = userInput.join();

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

  void revealOneWord() {
    final fullAnswer = question.answers[question.correctIndex];
    final words = fullAnswer.split(' ');

    int offset = 0;

    for (final word in words) {
      final wordLetters = word.toUpperCase().split('');
      final wordLength = wordLetters.length;

      // Kiểm tra cụm này đã điền đủ chưa
      bool wordComplete = true;
      for (int i = offset; i < offset + wordLength; i++) {
        if (i < userInput.length &&
            userInput[i].isEmpty &&
            !hintIndexes.contains(i)) {
          wordComplete = false;
          break;
        }
      }

      // Cụm này chưa đủ → gợi ý mờ toàn bộ cụm
      if (!wordComplete) {
        for (int i = offset; i < offset + wordLength; i++) {
          if (i >= userInput.length) break;
          hintIndexes.add(i); // ← đánh dấu vị trí gợi ý
        }
        _notifyUpdate();
        return;
      }

      offset += wordLength;
    }
  }

  void revealAllWords() {
    final wordCount = question.answers[question.correctIndex].split(' ').length;
    for (int i = 0; i < wordCount; i++) {
      revealOneWord();
    }
    _notifyUpdate();
  }

  // Kiểm tra chữ tại vị trí index có phải gợi ý không
  String? getHintLetter(int index) {
    if (!hintIndexes.contains(index)) return null;

    final fullAnswer = question.answers[question.correctIndex];
    final words = fullAnswer.split(' ');

    int offset = 0;
    for (final word in words) {
      final wordLength = word.length;

      if (index >= offset && index < offset + wordLength) {
        final letter = correctAnswer[index];
        // Chữ đầu cụm → viết hoa, còn lại → viết thường
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

    // Reset lại input
    for (int i = 0; i < userInput.length; i++) {
      userInput[i] = "";
    }

    _generateLetterPool();
    startTimer();
    onUpdate?.call();
  } // Thêm vào WordAnswerController

  void pauseTimer() {
    timer?.cancel();
  }

  void resumeTimer() {
    // Chỉ resume nếu game chưa kết thúc
    if (timeLeft > 0) {
      startTimer(); // gọi lại hàm startTimer() đã có sẵn
    }
  }

  @override
  void dispose() {
    rebuildNotifier.dispose();
    timer?.cancel();
  }
}
