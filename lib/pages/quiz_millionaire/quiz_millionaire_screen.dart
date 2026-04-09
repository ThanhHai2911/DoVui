import 'package:dovui/data/audio/audio_manager.dart';
import 'package:dovui/data/repositories/user_level_repository.dart';
import 'package:dovui/pages/ads/ads_service.dart';
import 'package:dovui/pages/quiz_millionaire/widgets/askcontinue_dialog.dart';
import 'package:dovui/pages/quiz_millionaire/widgets/prizeladderoverlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dovui/pages/gamecomplete/game_complete_sceen.dart';
import 'package:dovui/pages/quiz/bloc/quiz_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bloc/millionaire_bloc.dart';
import 'widgets/millionaire_colors.dart';
import 'widgets/starfield_background.dart';
import 'widgets/millionaire_top_bar.dart';
import 'widgets/question_card.dart';
import 'widgets/answer_grid.dart';
import 'widgets/timer_bar.dart';

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
      create:
          (_) => MillionaireBloc(quizBloc: QuizBloc())..add(
            LoadMillionaire(
              categoryId: widget.categoryId,
              levelId: widget.levelId,
              type: widget.type,
            ),
          ),
      child: const _MillionaireView(),
    );
  }

  Future<void> _saveResult({required int score, required int total}) async {
    if (widget.levelId == null) return;

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("userId");

    if (userId == null) return;

    final maxScore = total * 10;
    final percent = maxScore > 0 ? ((score / maxScore) * 10).round() : 0;

    _userLevelRepo.saveLevel(
      userId: userId,
      levelId: widget.levelId!,
      score: percent,
    );
  }
}

class _MillionaireView extends StatefulWidget {
  const _MillionaireView();

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
      onPopInvokedWithResult: (didPop, result) {},
      child: BlocConsumer<MillionaireBloc, MillionaireState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) async {
          if (!_isNavigated && (state.isGameOver || state.isFinished)) {
            _isNavigated = true;
            _navigateToResult(context, state);
          }

          if (state.isAskContinue) {
            _showAskContinue(context);
          }
        },
        builder: (context, state) {
          if (state.isLoading) return const _LoadingView();

          if (state.currentQuestion == null && !state.isLoading) {
            return const _EmptyView();
          }

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
                                padding: const EdgeInsets.fromLTRB(
                                  14,
                                  10,
                                  8,
                                  20,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: const [
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

  // ✅ NAVIGATE + SAVE RESULT
  Future<void> _navigateToResult(
    BuildContext context,
    MillionaireState state,
  ) async {
    final screen = context.findAncestorWidgetOfExactType<MillionaireScreen>();

    final stateful = context.findAncestorStateOfType<_MillionaireScreenState>();

    if (stateful != null) {
      stateful._saveResult(
        score: state.finalScore,
        total: state.questions.length,
      );
    }

    final isWin =
        state.questions.isNotEmpty &&
        (state.finalScore / (state.questions.length * 10)) >= 0.6;
    NativeAdManager().loadAd();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (_) => GameCompleteScreen(
              score: state.finalScore,
              totalQuestions: state.questions.length,
              isWin: isWin,
              categoryId: screen?.categoryId ?? '',
              levelId: screen?.levelId,
              type: screen?.type ?? '',
            ),
      ),
    );
  }

  void _showAskContinue(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => BlocProvider.value(
            value: context.read<MillionaireBloc>(),
            child: const AskContinueDialog(),
          ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: MillionaireColors.bgDeep,
    body: Center(
      child: CircularProgressIndicator(color: MillionaireColors.gold),
    ),
  );
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: MillionaireColors.bgDeep,
    body: Center(
      child: Text(
        'Chưa có câu hỏi cho chuyên đề này',
        style: TextStyle(color: Colors.white70, fontSize: 16),
      ),
    ),
  );
}
