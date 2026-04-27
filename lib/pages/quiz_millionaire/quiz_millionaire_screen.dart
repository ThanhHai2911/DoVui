import 'package:dovui/data/audio/audio_manager.dart';
import 'package:dovui/data/repositories/user_level_repository.dart';
import 'package:dovui/pages/ads/widgets/adsService.dart';
import 'package:dovui/pages/quiz_millionaire/widgets/askcontinue_dialog.dart';
import 'package:dovui/pages/quiz_millionaire/widgets/prizeladderoverlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dovui/pages/gamecomplete/game_complete_screen.dart';
import 'package:dovui/pages/quiz/bloc/quiz_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bloc/millionaire_bloc.dart';
import 'widgets/millionaire_colors.dart';
import 'widgets/starfield_background.dart';
import 'widgets/millionaire_top_bar.dart';
import 'widgets/question_card.dart';
import 'widgets/answer_grid.dart';
import 'widgets/timer_bar.dart';
// New extracted widgets:
import 'widgets/millionaire_loading_view.dart';

class MillionaireScreen extends StatefulWidget {
  final String categoryId;
  final String? levelId;
  final String type;

  const MillionaireScreen({
    super.key,
    required this.categoryId,
    required this.type,
    this.levelId,
  });

  @override
  State<MillionaireScreen> createState() => _MillionaireScreenState();
}

class _MillionaireScreenState extends State<MillionaireScreen> {
  final _userLevelRepo = UserLevelRepository();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MillionaireBloc(quizBloc: QuizBloc())
        ..add(LoadMillionaire(
          categoryId: widget.categoryId,
          levelId: widget.levelId,
          type: widget.type,
        )),
      child: _MillionaireView(
        categoryId: widget.categoryId,
        levelId: widget.levelId,
        type: widget.type,
        onSaveResult: _saveResult, 
        isVip: AdsService().isVip,
      ),
    );
  }

  Future<void> _saveResult({required int score, required int total}) async {
    if (widget.levelId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) return;
    final maxScore = total * 10;
    final percent = maxScore > 0 ? ((score / maxScore) * 10).round() : 0;
    _userLevelRepo.saveLevel(userId: userId, levelId: widget.levelId!, score: percent);
  }
}

class _MillionaireView extends StatefulWidget {
  final String categoryId;
  final String? levelId;
  final String type;
  final Future<void> Function({required int score, required int total}) onSaveResult;
  final bool isVip;

  const _MillionaireView({
    required this.categoryId,
    required this.levelId,
    required this.type,
    required this.onSaveResult, required this.isVip,
  });

  @override
  State<_MillionaireView> createState() => _MillionaireViewState();
}

class _MillionaireViewState extends State<_MillionaireView> {
  bool _isNavigated = false;

  @override
  void initState() {
    super.initState();
    AudioManager().stopBackgroundMusic();
    AudioManager().stopSfx();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) {},
      child: BlocConsumer<MillionaireBloc, MillionaireState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) async {
          if (!_isNavigated && (state.isGameOver || state.isFinished)) {
            _isNavigated = true;
            await _navigateToResult(context, state);
          }
          if (state.isAskContinue) _showAskContinue(context);
        },
        builder: (context, state) {
          if (state.isLoading) return const MillionaireLoadingView();
          if (state.currentQuestion == null) return const MillionaireEmptyView();

          return Scaffold(
            backgroundColor: MillionaireColors.bgPage,
            body: Stack(
              children: [
                const StarfieldBackground(),
                SafeArea(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.fromLTRB(14, 10, 8, 20),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    TimerBar(),
                                    SizedBox(height: 40),
                                    QuestionCard(),
                                    SizedBox(height: 60),
                                    AnswerGrid(),
                                  ],
                                ),
                              ),
                            ),
                            const MillionaireTopBar(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (state.isShowPrizeLadder)
                  BlocProvider.value(
                    value: context.read<MillionaireBloc>(),
                    child: const PrizeLadderOverlay(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _navigateToResult(BuildContext context, MillionaireState state) async {
    await widget.onSaveResult(score: state.finalScore, total: state.questions.length);

    if (!context.mounted) return;
    final isWin = state.questions.isNotEmpty &&
        (state.finalScore / (state.questions.length * 10)) >= 0.6;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GameCompleteScreen(
          score: state.finalScore,
          totalQuestions: state.questions.length,
          isWin: isWin,
          categoryId: widget.categoryId,
          levelId: widget.levelId,
          type: widget.type,
          isVip: AdsService().isVip,
        ),
      ),
    );
  }

  void _showAskContinue(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: context.read<MillionaireBloc>(),
        child: const AskContinueDialog(),
      ),
    );
  }
}