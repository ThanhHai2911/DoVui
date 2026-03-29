import 'package:dovui/pages/ads/ads_service.dart';
import 'package:dovui/pages/home/widgets/game_dialog.dart';
import 'package:dovui/pages/word_answer/widgets/hint_bar.dart';
import 'package:dovui/resources/color_manager.dart';
import 'package:dovui/data/repositories/user_level_repository.dart';
import 'package:dovui/pages/gamecomplete/game_complete_sceen.dart';
import 'package:dovui/pages/word_answer/bloc/word_answer_bloc.dart';
import 'package:dovui/pages/word_answer/bloc/word_answer_event.dart';
import 'package:dovui/pages/word_answer/bloc/word_answer_state.dart';
import 'package:dovui/pages/word_answer/widgets/%20word_answer_header.dart';
import 'package:dovui/pages/word_answer/widgets/%20word_answer_input.dart';
import 'package:dovui/pages/word_answer/widgets/letter_pool_widget.dart';
import 'package:dovui/pages/word_answer/widgets/word_answer_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    with TickerProviderStateMixin {
  final _userLevelRepo = UserLevelRepository();

  // Animation controllers
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

    // Entry animation (toàn màn hình fade + slide lên)
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );

    // Question card flip/scale khi đổi câu
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

    // Pulse animation cho badge tiêu đề
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Float animation cho emoji trang trí
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _questionController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _saveResult({required int score, required int total}) async {
    if (widget.levelId == null) return;
    final percent = total > 0 ? ((score / total) * 100).round() : 0;
    await _userLevelRepo.saveLevel(levelId: widget.levelId!, score: percent);
  }

  void _triggerQuestionAnim(String questionId) {
    if (questionId != _lastQuestionId) {
      _lastQuestionId = questionId;
      _questionController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) => WordAnswerBloc(
            categoryId: widget.categoryId,
            levelId: widget.levelId,
            type: widget.type,
          )..add(LoadQuestions()),
      child: BlocConsumer<WordAnswerBloc, WordAnswerState>(
        listener: (context, state) async {
          if (state is WordAnswerCompleted) {
            await _saveResult(score: state.score, total: state.total);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (_) => GameCompleteScreen(
                      score: state.score,
                      totalQuestions: state.total,
                      isWin: state.score > 90,
                      categoryId: widget.categoryId,
                      levelId: widget.levelId,
                      type: widget.type,
                    ),
              ),
            );
          }
          if (state is WordAnswerTimeUp) {
            await _saveResult(score: state.score, total: state.total);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (_) => GameCompleteScreen(
                      score: state.score,
                      totalQuestions: state.total,
                      isWin: state.score > 90,
                      categoryId: widget.categoryId,
                      levelId: widget.levelId,
                      type: widget.type,
                    ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is WordAnswerLoading) return const WordAnswerShimmer();

          if (state is WordAnswerLoaded) {
            final controller = state.controller;
            final question = state.question;

            // Trigger animation mỗi khi câu hỏi đổi
            _triggerQuestionAnim(question.question);

            return Scaffold(
              backgroundColor: const Color(0xFFF4F6FF),
              body: Stack(
                children: [
                  _buildBackground(),
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: SafeArea(
                        child: Column(
                          children: [
                            const SizedBox(height: 12),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Column(
                                  children: [
                                    /// Card câu hỏi — scale + fade khi đổi
                                    FadeTransition(
                                      opacity: _questionFadeAnim,
                                      child: ScaleTransition(
                                        scale: _questionScaleAnim,
                                        child: _buildQuestionCard(question),
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

                                    _buildHintBar(context),

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
    );
  }

  Widget _buildBackground() {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: -50 + _floatAnim.value,
              left: -50,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6C63FF).withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              top: 150 - _floatAnim.value,
              right: -40,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF6584).withOpacity(0.07),
                ),
              ),
            ),
            Positioned(
              bottom: 200 + _floatAnim.value * 0.5,
              left: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF43C6AC).withOpacity(0.07),
                ),
              ),
            ),
            Positioned(
              bottom: 60 - _floatAnim.value * 0.5,
              right: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFB347).withOpacity(0.07),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuestionCard(question) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;
        double titleFont = (screenWidth * 0.040).clamp(13.0, 18.0);
        double questionFont = (screenWidth * 0.065).clamp(17.0, 26.0);

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.07,
            vertical: screenWidth * 0.09,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C63FF).withOpacity(0.12),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: const Color(0xFF6C63FF).withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Emoji nổi góc phải — float animation
              Positioned(
                top: -20,
                right: -10,
                child: AnimatedBuilder(
                  animation: _floatAnim,
                  builder:
                      (_, __) => Transform.translate(
                        offset: Offset(0, _floatAnim.value * 0.4),
                        child: const Text("🎵", style: TextStyle(fontSize: 32)),
                      ),
                ),
              ),
              // Emoji nổi góc trái
              Positioned(
                bottom: -16,
                left: -8,
                child: AnimatedBuilder(
                  animation: _floatAnim,
                  builder:
                      (_, __) => Transform.translate(
                        offset: Offset(0, -_floatAnim.value * 0.4),
                        child: const Text("🎶", style: TextStyle(fontSize: 22)),
                      ),
                ),
              ),

              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Badge pulse
                  ScaleTransition(
                    scale: _pulseAnim,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF9B8FFF)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6C63FF).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        "🎵 Ghép tên bài hát",
                        style: TextStyle(
                          fontSize: titleFont,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenWidth * 0.06),

                  // Câu hỏi
                  Text(
                    question.question,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: questionFont,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E1B4B),
                      letterSpacing: 1.2,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHintBar(BuildContext context) {
    return HintBar(
      onMagnifier: () {
        showGameDialog(
          context: context,
          icon: "🔍",
          iconColor: Colors.amber,
          title: "Gợi ý chữ cái",
          description: "Hé lộ 1 phần đáp án\ncho câu trả lời hiện tại",
          costIcon: "⭐",
          costText: "Tốn 50 sao",
          confirmText: "Dùng ngay!",
          confirmColor: Colors.amber,
          onConfirm: () => context.read<WordAnswerBloc>().add(UseHintLetter()),
        );
      },
      onKey: () {
        showGameDialog(
          context: context,
          icon: "🗝️",
          iconColor: Colors.deepPurple,
          title: "Mở đáp án",
          description: "Hiện toàn bộ đáp án\ncâu hỏi hiện tại",
          costIcon: "⭐",
          costText: "Tốn 100 sao",
          confirmText: "Mở thôi!",
          confirmColor: Colors.deepPurple,
          onConfirm: () => context.read<WordAnswerBloc>().add(UseSkip()),
        );
      },
      onVideo: () {
        showGameDialog(
          context: context,
          icon: "🛠️",
          iconColor: Colors.orange,
          title: "Tính năng đang phát triển",
          description:
              "Chức năng mở đáp án đang được cập nhật.\nVui lòng quay lại sau nhé!",
          costIcon: "⭐",
          costText: "Sắp ra mắt",
          confirmText: "Đã hiểu",
          confirmColor: Colors.orange,
          showCancel: false,
          onConfirm: () {},
        );
      },
    );
  }
}

