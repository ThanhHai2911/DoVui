import 'package:dovui/data/audio/audio_manager.dart';
import 'package:dovui/pages/ads/ads_service.dart';
import 'package:dovui/pages/category/categories_screen.dart';
import 'package:dovui/pages/home/widgets/home_bottom_nav.dart';
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
    with TickerProviderStateMixin {
  late AnimationController _mainCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;
  late Animation<double> _pulseAnim;
  final NativeAdManager _nativeAdManager = NativeAdManager();

  @override
  void initState() {
    super.initState();

    _mainCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scaleAnim = CurvedAnimation(parent: _mainCtrl, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _mainCtrl, curve: Curves.easeIn);
    _slideAnim = Tween<double>(
      begin: 30,
      end: 0,
    ).animate(CurvedAnimation(parent: _mainCtrl, curve: Curves.easeOutCubic));
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(_pulseCtrl);

    _mainCtrl.forward();


    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      if (widget.isWin) {
        AudioManager().playWin();
      } else {
        AudioManager().playLose();
      }
    });
    NativeAdManager().loadAd();
  }

  @override
  void dispose() {
    _mainCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _handleReplay() {
    AudioManager().stopSfx();
    Navigator.pop(context, 'replay');
  }

  void _handleExit() {
    InterstitialAdManager().showAdIfAvailable(
      onAdClosed: () {
        AudioManager().stopSfx();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeBottomNav()),
          (route) => false,
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AudioManager().playBackgroundMusic();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWin = widget.isWin;
    final accentColor =
        isWin ? const Color(0xFFFFD700) : const Color(0xFFFF5252);
    final emoji = isWin ? '🏆' : '💔';
    final title = isWin ? 'Xuất Sắc!' : 'Thất Bại!';
    final subtitle =
        isWin ? 'Bạn đã hoàn thành xuất sắc!' : 'Cố lên lần sau nhé!';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {},
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  // ── Trophy / emoji ──────────────────────────────────
                  ScaleTransition(
                    scale: _scaleAnim,
                    child: AnimatedBuilder(
                      animation: _pulseAnim,
                      builder:
                          (_, child) => Transform.scale(
                            scale: _pulseAnim.value,
                            child: child,
                          ),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color:
                              isWin
                                  ? const Color(0xFFFFFDE7)
                                  : const Color(0xFFFFEBEE),
                          shape: BoxShape.circle,
                          border: Border.all(color: accentColor, width: 2.5),
                        ),
                        child: Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 50),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Title ───────────────────────────────────────────
                  AnimatedBuilder(
                    animation: _slideAnim,
                    builder:
                        (_, child) => Transform.translate(
                          offset: Offset(0, _slideAnim.value),
                          child: child,
                        ),
                    child: Column(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color:
                                isWin
                                    ? const Color(0xFF1A1A1A)
                                    : const Color(0xFFE53935),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // ── Stars ──
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (i) {
                            final lit =
                                widget.score / widget.totalQuestions >
                                (i + 1) / 3;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Text(
                                lit ? '⭐' : '☆',
                                style: TextStyle(
                                  fontSize: 28,
                                  color:
                                      lit ? accentColor : Colors.grey.shade300,
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Score card ──────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isWin
                              ? const Color(0xFFFFFDE7)
                              : const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: accentColor.withOpacity(0.6),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'SAO KIẾM ĐƯỢC',
                          style: TextStyle(
                            fontSize: 11,
                            color: accentColor.withOpacity(0.8),
                            letterSpacing: 2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ShaderMask(
                          shaderCallback:
                              (bounds) => LinearGradient(
                                colors:
                                    isWin
                                        ? [
                                          const Color(0xFFF59E0B),
                                          const Color(0xFFEF9F27),
                                        ]
                                        : [
                                          const Color(0xFFFF5252),
                                          const Color(0xFFE53935),
                                        ],
                              ).createShader(bounds),
                          child: Text(
                            '${widget.score}',
                            style: const TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                        ),
                        Text(
                          'trên ${widget.totalQuestions} câu hỏi',
                          style: TextStyle(
                            fontSize: 12,
                            color: accentColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Native Ad ───────────────────────────────────────
                  NativeAdWidget(
                    backgroundColor: Colors.white,
                    ctaColor: const Color(0xFFFF9800),
                  ),

                  const SizedBox(height: 16),

                  // ── Chơi lại + Thoát ────────────────────────────────
                  Row(
                    children: [
                      // Thoát
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton(
                            onPressed: _handleExit,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xFFE0E0E0),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              foregroundColor: const Color(0xFF9E9E9E),
                            ),
                            child: const Text(
                              'Thoát',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // Chơi lại
                      Expanded(
                        flex: 2, // ← rộng hơn nút Thoát
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _handleReplay,
                            icon: const Icon(
                              Icons.play_arrow_rounded,
                              size: 22,
                            ),
                            label: const Text(
                              'Chơi lại',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
