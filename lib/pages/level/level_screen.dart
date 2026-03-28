import 'package:dovui/resources/color_manager.dart';
import 'package:dovui/data/models/user_level_model.dart';
import 'package:dovui/pages/category/widgets/category_shimmer.dart';
import 'package:dovui/pages/level/bloc/level_bloc.dart';
import 'package:dovui/pages/level/bloc/level_event.dart';
import 'package:dovui/pages/level/bloc/level_state.dart';
import 'package:dovui/pages/word_answer/word_answer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Levelscreen extends StatelessWidget {
  final String categoryId;
  final String type;

  const Levelscreen({super.key, required this.categoryId, required this.type});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LevelBloc()..add(LoadLevels(categoryId)),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FF),
        body: Stack(
          children: [
            /// ===== NỀN TRANG TRÍ =====
            _buildBackground(),

            SafeArea(
              child: Column(
                children: [
                  _buildHeader(context),
                  _buildLegend(),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: BlocBuilder<LevelBloc, LevelState>(
                        builder: (context, state) {
                          if (state is LevelLoading) {
                            return const CategoryShimmer();
                          }

                          if (state is LevelLoaded) {
                            final levels = state.levels;
                            final statuses = state.levelStatuses;

                            return GridView.builder(
                              itemCount: levels.length,
                              padding: const EdgeInsets.only(
                                  top: 8, bottom: 20),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.88,
                              ),
                              itemBuilder: (context, index) {
                                final level = levels[index];
                                final UserLevelModel? userLevel =
                                    statuses[level.id];
                                final String status =
                                    userLevel?.status ?? 'default';

                                bool isUnlocked;
                                if (index == 0) {
                                  isUnlocked = true;
                                } else {
                                  final prevLevel = levels[index - 1];
                                  final prevStatus =
                                      statuses[prevLevel.id]?.status;
                                  isUnlocked = prevStatus == 'completed';
                                }

                                return _LevelCard(
                                  index: index,
                                  status: status,
                                  isUnlocked: isUnlocked,
                                  onTap: isUnlocked
                                      ? () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => WordAnswerScreen(
                                                categoryId: categoryId,
                                                levelId: level.id,
                                                type: type,
                                              ),
                                            ),
                                          ).then((_) {
                                            context.read<LevelBloc>().add(
                                                LoadLevels(categoryId));
                                          });
                                        }
                                      : null,
                                );
                              },
                            );
                          }

                          return const SizedBox();
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
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Positioned(
          top: -60,
          left: -60,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF6C63FF).withOpacity(0.08),
            ),
          ),
        ),
        Positioned(
          top: 100,
          right: -40,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFF6584).withOpacity(0.07),
            ),
          ),
        ),
        Positioned(
          bottom: 200,
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
          bottom: 80,
          right: -50,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFB347).withOpacity(0.07),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF9B8FFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Trang trí trong header
          Positioned(
            top: -10,
            right: 20,
            child: Text("🎮",
                style: TextStyle(
                    fontSize: 50,
                    color: Colors.white.withOpacity(0.15))),
          ),
          Positioned(
            bottom: -8,
            right: 70,
            child: Text("⭐",
                style: TextStyle(
                    fontSize: 30,
                    color: Colors.white.withOpacity(0.12))),
          ),

          Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Chọn màn chơi",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 36),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.2), width: 1),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("🏆", style: TextStyle(fontSize: 16)),
                    SizedBox(width: 8),
                    Text(
                      "Hoàn thành màn trước để mở khoá!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendDot(const Color(0xFF43C6AC), "✅ Đạt"),
          const SizedBox(width: 14),
          _legendDot(const Color(0xFFFF6584), "❌ Chưa đạt"),
          const SizedBox(width: 14),
          _legendDot(const Color(0xFF6C63FF).withOpacity(0.2), "🎯 Mới"),
          const SizedBox(width: 14),
          _legendDot(Colors.grey.shade300, "🔒 Khóa"),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style:
                TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      ],
    );
  }
}

// =============================================
//  LEVEL CARD với animation
// =============================================
class _LevelCard extends StatefulWidget {
  final int index;
  final String status;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const _LevelCard({
    required this.index,
    required this.status,
    required this.isUnlocked,
    required this.onTap,
  });

  @override
  State<_LevelCard> createState() => _LevelCardState();
}

class _LevelCardState extends State<_LevelCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Stagger delay theo index
    Future.delayed(
      Duration(milliseconds: 80 * widget.index),
      () {
        if (mounted) _controller.forward();
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Color> _getGradient() {
    if (!widget.isUnlocked) {
      return [Colors.grey.shade300, Colors.grey.shade400];
    }
    switch (widget.status) {
      case 'completed':
        return [const Color(0xFF43C6AC), const Color(0xFF2BB89A)];
      case 'failed':
        return [const Color(0xFFFF6584), const Color(0xFFE8435A)];
      default:
        return [const Color(0xFF6C63FF), const Color(0xFF9B8FFF)];
    }
  }

  String _getEmoji() {
    if (!widget.isUnlocked) return "🔒";
    switch (widget.status) {
      case 'completed':
        return "⭐";
      case 'failed':
        return "💪";
      default:
        return "🎯";
    }
  }

  String _getStatusText() {
    if (!widget.isUnlocked) return "Chưa mở";
    switch (widget.status) {
      case 'completed':
        return "Hoàn thành";
      case 'failed':
        return "Thử lại";
      default:
        return "Bắt đầu";
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _getGradient();

    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: gradient[0]
                      .withOpacity(widget.isUnlocked ? 0.4 : 0.15),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Trang trí vòng tròn nền
                Positioned(
                  top: -18,
                  right: -18,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -10,
                  left: -10,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.07),
                    ),
                  ),
                ),

                // Số màn mờ làm nền
                Positioned(
                  top: 6,
                  right: 10,
                  child: Text(
                    "${widget.index + 1}",
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withOpacity(1),
                      height: 1,
                    ),
                  ),
                ),

                // Nội dung chính
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Emoji to
                      Text(
                        _getEmoji(),
                        style: const TextStyle(fontSize: 32),
                      ),

                      const Spacer(),

                      // Tên màn
                      Text(
                        "Màn ${widget.index + 1}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 5),

                      // Badge trạng thái
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _getStatusText(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Overlay mờ nếu bị khóa
                if (!widget.isUnlocked)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: Colors.black.withOpacity(0.15),
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