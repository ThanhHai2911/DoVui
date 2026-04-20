import 'package:dovui/pages/ads/ads_service.dart';
import 'package:dovui/pages/home/widgets/check_score.dart';
import 'package:dovui/pages/home/widgets/game_dialog.dart';
import 'package:dovui/pages/quiz_image/bloc/image_question_bloc.dart';
import 'package:dovui/pages/word_answer/widgets/hint_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Wraps [HintBar] with all hint/ad logic for QuizImageScreen.
class QuizImageHintBarHandler extends StatelessWidget {
  const QuizImageHintBarHandler({super.key});

  @override
  Widget build(BuildContext context) {
    return HintBar(
      onMagnifier: () => _onMagnifier(context),
      onKey: () => _onKey(context),
      onVideo: () => _onVideo(context),
    );
  }

  void _onMagnifier(BuildContext context) {
    final score = context.read<QuizImageBloc>().currentScore;
    checkScoreAndShowHint(
      context: context,
      currentScore: score,
      cost: 50,
      hintIcon: '🔍',
      hintTitle: 'Gợi ý chữ cái',
      hintDescription: 'Hé lộ 1 chữ cái đúng\ncho câu trả lời hiện tại',
      hintColor: Colors.amber,
      confirmText: 'Dùng ngay!',
      onConfirm: () => context.read<QuizImageBloc>().add(QuizImageUseHintLetter()),
    );
  }

  void _onKey(BuildContext context) {
    final score = context.read<QuizImageBloc>().currentScore;
    checkScoreAndShowHint(
      context: context,
      currentScore: score,
      cost: 100,
      hintIcon: '🗝️',
      hintTitle: 'Mở đáp án',
      hintDescription: 'Hiện toàn bộ đáp án\ncâu hỏi hiện tại',
      hintColor: Colors.deepPurple,
      confirmText: 'Mở thôi!',
      onConfirm: () => context.read<QuizImageBloc>().add(QuizImageUseSkip()),
    );
  }

  void _onVideo(BuildContext context) {
    if (!RewardedAdManager().isAdLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⏳ Quảng cáo chưa sẵn sàng, thử lại sau!'), backgroundColor: Colors.orange),
      );
      return;
    }

    showGameDialog(
      context: context,
      icon: '🎬',
      iconColor: Colors.purple,
      title: 'Xem video nhận gợi ý?',
      description: 'Xem 1 video ngắn để\nhé lộ toàn bộ đáp án miễn phí!',
      costIcon: '🎬',
      costText: 'Xem video',
      confirmText: 'Xem ngay!',
      confirmColor: Colors.purple,
      showCancel: true,
      onConfirm: () {
        context.read<QuizImageBloc>().add(QuizImagePauseTimer());
        RewardedAdManager().showAd(
          onRewarded: () {
            context.read<QuizImageBloc>().add(QuizImageUseSkipFree());
            context.read<QuizImageBloc>().add(QuizImageResumeTimer());
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🎉 Đáp án đã được mở!'), backgroundColor: Color(0xFF43C6AC)),
              );
            }
          },
          onFailed: () {
            context.read<QuizImageBloc>().add(QuizImageResumeTimer());
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('❌ Không tải được quảng cáo, thử lại sau!'), backgroundColor: Colors.red),
              );
            }
          },
        );
      },
    );
  }
}