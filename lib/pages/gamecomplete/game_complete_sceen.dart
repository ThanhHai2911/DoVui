import 'package:flutter/material.dart';

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

class _GameCompleteScreenState extends State<GameCompleteScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWin = widget.isWin;
    final accentColor =
        isWin ? const Color(0xFFFFD700) : const Color(0xFFFF5252);
    final emoji = isWin ? '🏆' : '💔';
    final title = isWin ? 'Xuất Sắc!' : 'Thất Bại!';
    final subtitle = isWin ? 'Bạn đã hoàn thành!' : 'Cố lên lần sau nhé!';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isWin
              ? const LinearGradient(
                  colors: [
                    Color(0xFF1a1a2e),
                    Color(0xFF16213e),
                    Color(0xFF0f3460),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [
                    Color(0xFF1a1a1a),
                    Color(0xFF2d1b1b),
                    Color(0xFF3d1515),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: _scaleAnim,
                      child:
                          Text(emoji, style: const TextStyle(fontSize: 90)),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: accentColor,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: const TextStyle(
                          fontSize: 16, color: Colors.white54),
                    ),
                    const SizedBox(height: 40),

                    // Card điểm
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 28),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: accentColor.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'SAO KIẾM ĐƯỢC',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white38,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${widget.score}',
                            style: TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.w900,
                              color: accentColor,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '⭐',
                            style: TextStyle(
                                fontSize: 25, color: Colors.white54),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Nút thoát
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton(
                        onPressed: () =>
                            Navigator.pop(context, widget.isWin),
                        style: OutlinedButton.styleFrom(
                          side:
                              BorderSide(color: accentColor, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Thoát',
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}