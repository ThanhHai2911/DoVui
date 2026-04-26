import 'package:dovui/pages/category/widgets/category_shimmer.dart';
import 'package:dovui/pages/home/widgets/game_dialog.dart';
import 'package:dovui/pages/level/bloc/level_bloc.dart';
import 'package:dovui/pages/level/bloc/level_event.dart';
import 'package:dovui/pages/level/bloc/level_state.dart';
import 'package:dovui/pages/level/widgets/level_grid.dart'; // ← import mới
import 'package:dovui/pages/level/widgets/level_header.dart';
import 'package:dovui/pages/level/widgets/level_legend.dart';
import 'package:dovui/pages/quiz/quiz_screen.dart';
import 'package:dovui/pages/quiz_image/quiz_image_screen.dart';
import 'package:dovui/pages/quiz_millionaire/quiz_millionaire_screen.dart';
import 'package:dovui/pages/word_answer/word_answer_screen.dart';
import 'package:dovui/widgets/blob_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LevelScreen extends StatefulWidget {
  final String categoryId;
  final String type;

  const LevelScreen({super.key, required this.categoryId, required this.type});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolled = false;

  static const int _adEvery = 6;
  static const int _crossAxisCount = 2;
  static const double _spacing = 16.0;
  static const double _topPadding = 8.0;
  static const double _aspectRatio = 0.88;
  static const double _adHeight = 60.0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToNextLevel(int nextIndex) {
    if (_hasScrolled || nextIndex == 0) {
      _hasScrolled = true;
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      if (!_scrollController.position.hasContentDimensions) return;

      final double gridWidth = MediaQuery.of(context).size.width - 32;
      final double itemHeight =
          (gridWidth - _spacing) / _crossAxisCount / _aspectRatio;
      final int adsBeforeNext = nextIndex ~/ _adEvery;
      final int row = nextIndex ~/ _crossAxisCount;
      final double targetOffset =
          _topPadding +
          row * (itemHeight + _spacing) +
          adsBeforeNext * (_adHeight + _spacing) -
          (MediaQuery.of(context).size.height / 3);

      _scrollController.animateTo(
        targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );

      _hasScrolled = true;
    });
  }

  List<List<int>> _buildChunks(int totalLevels) {
    final chunks = <List<int>>[];
    int start = 0;
    while (start < totalLevels) {
      final end = (start + _adEvery).clamp(0, totalLevels);
      chunks.add(List.generate(end - start, (i) => start + i));
      start = end;
    }
    return chunks;
  }

  bool _isUnlocked(int index, List levels, Map statuses) {
    if (index == 0) return true;
    final prevStatus = statuses[levels[index - 1].id]?.status;
    final thisStatus = statuses[levels[index].id]?.status;
    return prevStatus == 'completed' ||
        (prevStatus == 'failed' && thisStatus != null);
  }

  Future<void> _onLevelTap(
    BuildContext context,
    int levelIndex,
    List levels,
    Map statuses,
  ) async {
    final level = levels[levelIndex];
    final String status = statuses[level.id]?.status ?? 'default';

    if (status == 'completed') {
      final confirm = await showGameDialogConfirm(
        context: context,
        icon: "🔄",
        iconColor: const Color(0xFF6C63FF),
        title: "Chơi lại màn ${levelIndex + 1}?",
        description: "Bạn muốn chơi lại màn này không?",
        costIcon: "⚠️",
        costText: "Màn tiếp theo vẫn giữ nguyên",
        confirmText: "Xác nhận",
        confirmColor: const Color(0xFF6C63FF),
      );
      if (confirm != true) return;
    }

    final screen = _buildGameScreen(level);

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => screen),
      ).then((_) {
        context.read<LevelBloc>().add(LoadLevels(widget.categoryId));
      });
    }
  }

  Widget _buildGameScreen(dynamic level) {
    switch (widget.type) {
      case "level":
        return WordAnswerScreen(
          categoryId: widget.categoryId,
          levelId: level.id,
          type: widget.type,
        );
      case "imagequiz":
        return QuizImageScreen(
          categoryId: widget.categoryId,
          levelId: level.id,
          type: widget.type,
        );
      case "man":
        return MillionaireScreen(
          categoryId: widget.categoryId,
          levelId: level.id,
          type: widget.type,
        );
      case "soman":
      default:
        return QuizScreen(
          categoryId: widget.categoryId,
          levelId: level.id,
          type: widget.type,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) {},
      child: BlocProvider(
        create: (_) => LevelBloc()..add(LoadLevels(widget.categoryId)),
        child: Scaffold(
          backgroundColor: const Color(0xFFF4F6FF),
          body: Stack(
            children: [
              const BlobBackground(),
              SafeArea(
                child: Column(
                  children: [
                    const LevelHeader(),
                    const LevelLegend(),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: BlocConsumer<LevelBloc, LevelState>(
                          listener: (context, state) {
                            if (state is LevelLoaded && !_hasScrolled) {
                              final levels = state.levels;
                              final statuses = state.levelStatuses;
                              int nextIndex = levels.length - 1;
                              for (int i = 0; i < levels.length; i++) {
                                if (statuses[levels[i].id]?.status !=
                                    'completed') {
                                  nextIndex = i;
                                  break;
                                }
                              }
                              _scrollToNextLevel(nextIndex);
                            }
                          },
                          builder: (context, state) {
                            if (state is LevelLoading) {
                              return const CategoryShimmer();
                            }
                            if (state is LevelLoaded) {
                              return LevelGrid( // ← dùng widget mới
                                levels: state.levels,
                                statuses: state.levelStatuses,
                                scrollController: _scrollController,
                                chunks: _buildChunks(state.levels.length),
                                isUnlocked: _isUnlocked,
                                onLevelTap: (idx) => _onLevelTap(
                                  context,
                                  idx,
                                  state.levels,
                                  state.levelStatuses,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}