import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dovui/data/audio/audio_manager.dart';
import 'package:dovui/pages/ads/ads_service.dart';
import 'package:dovui/pages/ads/widgets/adsService.dart';
import 'package:dovui/pages/home/widgets/home_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameCompleteScreen extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final bool isWin;
  final String categoryId;
  final String? levelId;
  final String type;
  final bool isVip;

  const GameCompleteScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.isWin,
    required this.categoryId,
    this.levelId,
    required this.type,
    required this.isVip,
  });

  @override
  State<GameCompleteScreen> createState() => _GameCompleteScreenState();
}

class _GameCompleteScreenState extends State<GameCompleteScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _patternCtrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;
  late Animation<double> _pulseAnim;
  late Animation<double> _patternAnim;

  bool _isVip = false;
  bool _isVipLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadVipFromFirebase();

    _mainCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _patternCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _scaleAnim = CurvedAnimation(parent: _mainCtrl, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _mainCtrl, curve: Curves.easeIn);
    _slideAnim = Tween<double>(
      begin: 40,
      end: 0,
    ).animate(CurvedAnimation(parent: _mainCtrl, curve: Curves.easeOutCubic));
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.07).animate(_pulseCtrl);
    _patternAnim = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_patternCtrl);

    _mainCtrl.forward();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      widget.isWin ? AudioManager().playWin() : AudioManager().playLose();
    });
  }

  Future<void> _loadVipFromFirebase() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId != null && userId.isNotEmpty) {
        final doc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get();

        final vip = doc.data()?['isVip'] ?? false;
        if (mounted) {
          setState(() {
            _isVip = vip == true;
            _isVipLoaded = true;
          });
          AdsService().setVip(_isVip);
        }
      } else {
        if (mounted) setState(() => _isVipLoaded = true);
      }
    } catch (e) {
      debugPrint('VIP check error: $e');
      if (mounted) {
        setState(() {
          _isVip = widget.isVip;
          _isVipLoaded = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _mainCtrl.dispose();
    _pulseCtrl.dispose();
    _patternCtrl.dispose();
    super.dispose();
  }

  void _navigateHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeBottomNav(initialIndex: 1)),
      (route) => false,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AudioManager().playBackgroundMusic();
    });
  }

  void _handleReplay() {
    AudioManager().stopSfx();
    if (_isVip) {
      _navigateHome();
      return;
    }
    RewardedAdManager().showAd(
      onRewarded: () {
        AudioManager().stopSfx();
        _navigateHome();
      },
      onFailed: () {
        AudioManager().stopSfx();
        _navigateHome();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVipLoaded) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isWin = widget.isWin;

    // Màu chủ đạo theo kết quả
    final primaryColor =
        isWin ? const Color(0xFFFFB300) : const Color(0xFFEF5350);
    final lightBg =
        isWin ? const Color(0xFFFFF8E1) : const Color(0xFFFFEBEE);
    final emoji = isWin ? '🏆' : '💔';
    final title = isWin ? 'Xuất Sắc!' : 'Thất Bại!';
    final subtitle =
        isWin ? 'Bạn đã hoàn thành xuất sắc!' : 'Cố lên lần sau nhé!';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) {},
      child: Scaffold(
        backgroundColor: Colors.white,
        // ── Nút chơi lại cố định ở dưới ──
        bottomNavigationBar: Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(
            24,
            12,
            24,
            MediaQuery.of(context).padding.bottom + 24,
          ),
          child: SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _handleReplay,
              icon: Icon(
                _isVip
                    ? Icons.play_arrow_rounded
                    : Icons.play_circle_outline_rounded,
                size: 22,
              ),
              label: Text(
                _isVip ? 'Chơi lại' : 'Xem video để chơi lại',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isVip ? const Color(0xFF43A047) : const Color(0xFFFF6D00),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 0,
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            // ── Hoạ tiết nền ──
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _patternAnim,
                builder: (_, __) {
                  return CustomPaint(
                    painter: _BackgroundPatternPainter(
                      animValue: _patternAnim.value,
                      isWin: isWin,
                      accentColor: primaryColor,
                    ),
                  );
                },
              ),
            ),

            // ── Nội dung chính ──
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      // Trophy / Heart icon
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
                            width: 108,
                            height: 108,
                            decoration: BoxDecoration(
                              color: lightBg,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: primaryColor,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.25),
                                  blurRadius: 24,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                emoji,
                                style: const TextStyle(fontSize: 52),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Title + subtitle + stars
                      AnimatedBuilder(
                        animation: _slideAnim,
                        builder:
                            (_, child) => Transform.translate(
                              offset: Offset(0, _slideAnim.value),
                              child: child,
                            ),
                        child: Column(
                          children: [
                            // VIP badge (chỉ hiện khi là VIP)
                            if (_isVip) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFFA000),
                                      Color(0xFFFFD54F),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.workspace_premium_rounded,
                                      size: 13,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'VIP',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],

                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                color:
                                    isWin
                                        ? const Color(0xFF1A1A1A)
                                        : const Color(0xFFB71C1C),
                                letterSpacing: 0.3,
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
                            const SizedBox(height: 14),
                            // Stars
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(3, (i) {
                                final ratio =
                                    widget.score / widget.totalQuestions;
                                final lit = ratio > (i + 1) / 3;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 400),
                                    child: Icon(
                                      lit ? Icons.star_rounded : Icons.star_outline_rounded,
                                      key: ValueKey('$i$lit'),
                                      size: 34,
                                      color:
                                          lit
                                              ? primaryColor
                                              : Colors.grey.shade300,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Score card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 22,
                        ),
                        decoration: BoxDecoration(
                          color: lightBg,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: primaryColor.withOpacity(0.5),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'ĐIỂM SỐ',
                              style: TextStyle(
                                fontSize: 11,
                                color: primaryColor.withOpacity(0.75),
                                letterSpacing: 2.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${widget.score}',
                              style: TextStyle(
                                fontSize: 62,
                                fontWeight: FontWeight.w900,
                                color: primaryColor,
                                height: 1.0,
                              ),
                            ),
                            Text(
                              'trên ${widget.totalQuestions} câu hỏi',
                              style: TextStyle(
                                fontSize: 13,
                                color: primaryColor.withOpacity(0.65),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Progress bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: widget.score / widget.totalQuestions,
                                minHeight: 8,
                                backgroundColor: primaryColor.withOpacity(0.15),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Native Ad — chỉ hiện cho user thường
                      if (!_isVip)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const NativeAdWidget(),
                        ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hoạ tiết nền tuỳ chỉnh ──────────────────────────────────────────────────
class _BackgroundPatternPainter extends CustomPainter {
  final double animValue;
  final bool isWin;
  final Color accentColor;

  _BackgroundPatternPainter({
    required this.animValue,
    required this.isWin,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke;
    final fillPaint = Paint()..style = PaintingStyle.fill;

    // Màu hoạ tiết rất nhẹ (opacity thấp để nền trắng vẫn sạch)
    final patternColor = accentColor.withOpacity(0.06);
    final dotColor = accentColor.withOpacity(0.08);

    paint.color = patternColor;
    paint.strokeWidth = 1.0;

    // ── Vòng tròn lớn trang trí góc trên phải ──
    canvas.drawCircle(
      Offset(size.width + 20, -20),
      120,
      paint..color = accentColor.withOpacity(0.07),
    );
    canvas.drawCircle(
      Offset(size.width + 20, -20),
      80,
      paint..color = accentColor.withOpacity(0.05),
    );

    // ── Vòng tròn góc dưới trái ──
    canvas.drawCircle(
      Offset(-30, size.height + 30),
      100,
      paint..color = accentColor.withOpacity(0.06),
    );
    canvas.drawCircle(
      Offset(-30, size.height + 30),
      60,
      paint..color = accentColor.withOpacity(0.04),
    );

    // ── Grid chấm tròn toàn màn hình ──
    const double spacing = 36;
    const double dotRadius = 1.8;
    fillPaint.color = dotColor;

    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, fillPaint);
      }
    }

    // ── Các hình thoi nhỏ trang trí (chuyển động chậm) ──
    final diamondPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..color = accentColor.withOpacity(0.09);

    final positions = [
      Offset(size.width * 0.15, size.height * 0.12),
      Offset(size.width * 0.82, size.height * 0.25),
      Offset(size.width * 0.08, size.height * 0.65),
      Offset(size.width * 0.88, size.height * 0.72),
    ];
    const sizes = [18.0, 14.0, 12.0, 16.0];

    for (int i = 0; i < positions.length; i++) {
      final offset =
          math.sin(animValue + i * math.pi / 2) * 3; // float nhẹ
      final center = positions[i] + Offset(0, offset);
      final s = sizes[i];
      final path =
          Path()
            ..moveTo(center.dx, center.dy - s)
            ..lineTo(center.dx + s * 0.6, center.dy)
            ..lineTo(center.dx, center.dy + s)
            ..lineTo(center.dx - s * 0.6, center.dy)
            ..close();
      canvas.drawPath(path, diamondPaint);
    }

    // ── Ngôi sao nhỏ (chỉ khi thắng) ──
    if (isWin) {
      final starPaint =
          Paint()
            ..style = PaintingStyle.fill
            ..color = accentColor.withOpacity(0.10);

      final starPositions = [
        Offset(size.width * 0.92, size.height * 0.08),
        Offset(size.width * 0.05, size.height * 0.35),
        Offset(size.width * 0.75, size.height * 0.88),
      ];
      const starSizes = [10.0, 8.0, 9.0];

      for (int i = 0; i < starPositions.length; i++) {
        final rotate =
            animValue * 0.15 + i * math.pi / 3; // xoay rất chậm
        _drawStar(
          canvas,
          starPositions[i],
          starSizes[i],
          rotate,
          starPaint,
        );
      }
    }
  }

  void _drawStar(
    Canvas canvas,
    Offset center,
    double size,
    double rotation,
    Paint paint,
  ) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final outerAngle = rotation + (i * 2 * math.pi / 5) - math.pi / 2;
      final innerAngle = outerAngle + math.pi / 5;
      final outer = Offset(
        center.dx + size * math.cos(outerAngle),
        center.dy + size * math.sin(outerAngle),
      );
      final inner = Offset(
        center.dx + size * 0.4 * math.cos(innerAngle),
        center.dy + size * 0.4 * math.sin(innerAngle),
      );
      if (i == 0) {
        path.moveTo(outer.dx, outer.dy);
      } else {
        path.lineTo(outer.dx, outer.dy);
      }
      path.lineTo(inner.dx, inner.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BackgroundPatternPainter old) =>
      old.animValue != animValue || old.isWin != isWin;
}