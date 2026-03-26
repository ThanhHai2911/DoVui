import 'package:dovui/app/resources/color_manager.dart';
import 'package:dovui/presentation/quiz/quiz_screen.dart';
import 'package:dovui/presentation/quiz/word_answer_screen.dart';
import 'package:dovui/presentation/user/bloc/user_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GameCompleteScreen extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final bool isWin;

  final String categoryId;
  final String? levelId;
  final String type;

  const GameCompleteScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.isWin,
    required this.categoryId,
    this.levelId,
    required this.type,
  });

  @override
  State<GameCompleteScreen> createState() => _GameCompleteScreenState();
}

class _GameCompleteScreenState extends State<GameCompleteScreen> {
  bool _scoreUpdated = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scoreUpdated) return;

      final userState = context.read<UserBloc>().state;

      if (userState is UserRegistered) {
        context.read<UserBloc>().add(UpdateScoreEvent(widget.score));
      }

      _scoreUpdated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.scaffoldBackground,
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.isWin
                      ? Icons.emoji_events
                      : Icons.sentiment_dissatisfied,
                  size: 80,
                  color: widget.isWin ? Colors.amber : Colors.red,
                ),
                const SizedBox(height: 20),
                Text(
                  widget.isWin ? "🎉 Hoàn thành!" : "💔 Bạn thua rồi!",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "${widget.score} / ${widget.totalQuestions} điểm",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 30),

                /// 🔥 THOÁT
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context, widget.isWin);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: ColorManager.gamecomplete),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "Thoát",
                      style: TextStyle(color: ColorManager.gamecomplete),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
