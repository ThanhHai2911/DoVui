import 'package:dovui/data/repositories/user_level_repository.dart';
import 'package:dovui/pages/ads/widgets/adsService.dart';
import 'package:dovui/pages/gamecomplete/game_complete_screen.dart';
import 'package:dovui/pages/word_answer/bloc/word_answer_bloc.dart';
import 'package:dovui/pages/word_answer/bloc/word_answer_event.dart';
import 'package:dovui/pages/word_answer/bloc/word_answer_state.dart';
import 'package:dovui/pages/word_answer/widgets/%20word_answer_header.dart';
import 'package:dovui/pages/word_answer/widgets/%20word_answer_input.dart';
import 'package:dovui/pages/word_answer/widgets/letter_pool_widget.dart';
import 'package:dovui/pages/word_answer/widgets/word_answer_background.dart';
import 'package:dovui/pages/word_answer/widgets/word_answer_hint_bar_handler.dart';
import 'package:dovui/pages/word_answer/widgets/word_answer_question_card.dart';
import 'package:dovui/pages/word_answer/widgets/word_answer_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WordAnswerScreen extends StatefulWidget {
  final String categoryId;
  final String? levelId;
  final String type;

  const WordAnswerScreen({
    super.key,
    required this.categoryId,
    required this.type,
    this.levelId,
  });

  @override
  State<WordAnswerScreen> createState() => _WordAnswerScreenState();
}

class _WordAnswerScreenState extends State<WordAnswerScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final _userLevelRepo = UserLevelRepository();

  late AnimationController _entryController;
  late AnimationController _questionController;
  late AnimationController _pulseController;
  late AnimationController _floatController;

  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _questionScaleAnim;
  late Animation<double> _questionFadeAnim;
  late Animation<double> _pulseAnim;
  late Animation<double> _floatAnim;

  String _lastQuestionId = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initAnimations();
    _entryController.forward();
  }

  void _initAnimations() {
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic));

    _questionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _questionScaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _questionController, curve: Curves.elasticOut),
    );
    _questionFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _questionController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _entryController.dispose();
    _questionController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _saveResult({required int score, required int total}) async {
    if (widget.levelId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("userId");
    if (userId == null) return;
    final maxScore = total * 10;
    final percent = maxScore > 0 ? ((score / maxScore) * 10).round() : 0;
    _userLevelRepo.saveLevel(userId: userId, levelId: widget.levelId!, score: percent);
  }

  void _triggerQuestionAnim(String questionId) {
    if (questionId != _lastQuestionId) {
      _lastQuestionId = questionId;
      _questionController.forward(from: 0);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    final bloc = context.read<WordAnswerBloc>();
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      bloc.add(PauseTimer());
    } else if (state == AppLifecycleState.resumed) {
      bloc.add(ResumeTimer());
    }
  }

  GameCompleteScreen _buildGameComplete({required int score, required int total}) {
    return GameCompleteScreen(
      score: score,
      totalQuestions: total,
      isWin: total > 0 && (score / (total * 10)) >= 0.6,
      categoryId: widget.categoryId,
      levelId: widget.levelId,
      type: widget.type,
      isVip: AdsService().isVip,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {},
      child: BlocProvider(
        create: (_) => WordAnswerBloc(
          categoryId: widget.categoryId,
          levelId: widget.levelId,
          type: widget.type,
        )..add(LoadQuestions()),
        child: BlocConsumer<WordAnswerBloc, WordAnswerState>(
          listener: (context, state) async {
            if (state is WordAnswerCompleted) {
              _saveResult(score: state.score, total: state.total);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => _buildGameComplete(score: state.score, total: state.total)),
              );
            }
            if (state is WordAnswerTimeUp) {
              _saveResult(score: state.score, total: state.total);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => _buildGameComplete(score: state.score, total: state.total)),
              );
            }
          },
          builder: (context, state) {
            if (state is WordAnswerLoading) return const WordAnswerShimmer();

            if (state is WordAnswerLoaded) {
              final controller = state.controller;
              final question = state.question;
              _triggerQuestionAnim(question.question);

              return Scaffold(
                backgroundColor: const Color(0xFFF4F6FF),
                body: Stack(
                  children: [
                    WordAnswerBackground(floatController: _floatController, floatAnim: _floatAnim),
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: SafeArea(
                          child: Column(
                            children: [
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: WordAnswerHeader(
                                  lives: controller.lives,
                                  timeLeft: controller.timeLeft,
                                  currentIndex: state.currentIndex,
                                  totalQuestions: state.questions.length,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Column(
                                    children: [
                                      FadeTransition(
                                        opacity: _questionFadeAnim,
                                        child: ScaleTransition(
                                          scale: _questionScaleAnim,
                                          child: WordAnswerQuestionCard(
                                            question: question,
                                            pulseAnim: _pulseAnim,
                                            floatAnim: _floatAnim,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      WordAnswerInput(
                                        userInput: controller.userInput,
                                        onRemove: controller.removeLetter,
                                        controller: controller,
                                      ),
                                      const Spacer(),
                                      LetterPoolWidget(
                                        letters: controller.letterPool,
                                        onSelect: controller.selectLetter,
                                      ),
                                      const SizedBox(height: 20),
                                      WordAnswerHintBarHandler(),
                                      const SizedBox(height: 16),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return const WordAnswerShimmer();
          },
        ),
      ),
    );
  }
}