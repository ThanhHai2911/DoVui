import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audioplayers/audioplayers.dart';
import '../bloc/millionaire_bloc.dart';

class TimerBar extends StatefulWidget {
  const TimerBar({super.key});

  @override
  State<TimerBar> createState() => _TimerBarState();
}

class _TimerBarState extends State<TimerBar> {
  final AudioPlayer _player = AudioPlayer();
  bool _playedWarning = false;

  void _playWarning() async {
    try {
      await _player.play(AssetSource('audio/clock.mp3'));
    } catch (e) {
      debugPrint("Audio error: $e");
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MillionaireBloc, MillionaireState>(
      buildWhen: (p, c) => p.timeLeft != c.timeLeft,
      builder: (context, state) {
        final progress = (state.timeLeft / 60).clamp(0.0, 1.0);
        final isWarning = state.timeLeft <= 10;

        /// 🔥 Trigger sound đúng 1 lần
        if (isWarning && !_playedWarning) {
          _playedWarning = true;
          _playWarning();
        }

        /// reset khi chơi lại (time > 10)
        if (state.timeLeft > 10) {
          _playedWarning = false;
        }

        return Column(
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                color: isWarning ? Colors.red : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: isWarning ? 18 : 14,
              ),
              child: Text("⏱ ${state.timeLeft}"),
            ),

            const SizedBox(height: 6),

            TweenAnimationBuilder<double>(
              tween: Tween(begin: 1.0, end: progress),
              duration: const Duration(milliseconds: 400),
              builder: (_, value, __) => ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation(
                    isWarning ? Colors.red : Colors.amber,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}