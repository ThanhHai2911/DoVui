import 'package:dovui/app/resources/color_manager.dart';
import 'package:dovui/pages/gamecomplete/bloc/game_complete_bloc.dart';
import 'package:dovui/pages/gamecomplete/bloc/game_complete_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GameCompleteScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final bool isWin;

  const GameCompleteScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.isWin,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) =>
              GameCompleteBloc()..add(
                LoadGameResult(
                  score: score,
                  totalQuestions: totalQuestions,
                  isWin: isWin,
                ),
              ),
      child: Scaffold(
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
                    isWin ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                    size: 80,
                    color: isWin ? Colors.amber : Colors.red,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isWin ? "🎉 Hoàn thành!" : "💔 Bạn thua rồi!",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "$score / $totalQuestions điểm",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Chơi lại
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorManager.gamecomplete,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        "Chơi lại",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Thoát
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: ColorManager.gamecomplete,
                        ),
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
      ),
    );
  }
}
