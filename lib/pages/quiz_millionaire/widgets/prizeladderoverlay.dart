import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/millionaire_bloc.dart';

// ── Constants ────────────────────────────────────────────
// kPrizeLevels và kSafeMilestones lấy từ millionaire_bloc.dart
const double _kRowH = 44.0;
const double _kCurrentRowH = 56.0;

// ── Color palette (ALTP) ─────────────────────────────────
const _kDeepPurple    = Color(0xFF1A1045);
const _kMidPurple     = Color(0xFF2D1B6E);
const _kGold          = Color(0xFFFFD700);
const _kGoldDark      = Color(0xFFB8860B);
const _kGoldBg        = Color(0xFFFFFBE6);
const _kGoldBorder    = Color(0xFFE8C800);
const _kSafeGreen     = Color(0xFF22C55E);
const _kSafeGreenDark = Color(0xFF22A05C);
const _kSafeGreenBg   = Color(0xFFF6FFF9);
const _kBorderLight   = Color(0xFFF0EAD8);
const _kNumDefault    = Color(0xFFBBBBBB);
const _kPrizeDefault  = Color(0xFF444444);
const _kPassedOpacity = 0.38;

// ════════════════════════════════════════════════════════
class PrizeLadderOverlay extends StatefulWidget {
  const PrizeLadderOverlay({super.key});

  @override
  State<PrizeLadderOverlay> createState() => _PrizeLadderOverlayState();
}

class _PrizeLadderOverlayState extends State<PrizeLadderOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  Timer? _autoClose;
  late ScrollController _scrollCtrl;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrent());

    _autoClose = Timer(const Duration(milliseconds: 2800), () {
      if (mounted) context.read<MillionaireBloc>().add(PrizeLadderDismissed());
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _autoClose?.cancel();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToCurrent() {
    final s = context.read<MillionaireBloc>().state;
    final justAnswered = (s.currentIndex - 1).clamp(0, kPrizeLevels.length - 1);
    // Danh sách hiển thị ngược (câu 15 trên cùng), nên offset = vị trí từ trên xuống
    final offset = (kPrizeLevels.length - 1 - justAnswered) * _kRowH;
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        offset.clamp(0.0, _scrollCtrl.position.maxScrollExtent),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MillionaireBloc, MillionaireState>(
      builder: (context, state) {
        final justAnswered = (state.currentIndex - 1).clamp(0, kPrizeLevels.length - 1);
        return FadeTransition(
          opacity: _fadeAnim,
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE8E0C8)),
                  boxShadow: [
                    BoxShadow(
                      color: _kGold.withOpacity(0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Header(),
                      Flexible(
                        child: ListView.builder(
                          controller: _scrollCtrl,
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: kPrizeLevels.length,
                          itemBuilder: (_, i) {
                            final levelIdx = kPrizeLevels.length - 1 - i;
                            return _LadderRow(
                              levelIdx: levelIdx,
                              justAnswered: justAnswered,
                            );
                          },
                        ),
                      ),
                      _Footer(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Header ───────────────────────────────────────────────
class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kDeepPurple, _kMidPurple, _kDeepPurple],
          stops: [0.0, 0.6, 1.0],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _DiamondWidget(),
              const SizedBox(width: 12),
              const Text(
                'BẢNG THƯỞNG',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: _kGold,
                  letterSpacing: 6,
                ),
              ),
              const SizedBox(width: 12),
              _DiamondWidget(),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'AI LÀ VUA ĐIỂM',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 3,
              color: _kGold.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Footer ───────────────────────────────────────────────
class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kDeepPurple, _kMidPurple, _kDeepPurple],
          stops: [0.0, 0.6, 1.0],
        ),
      ),
      child: Column(
        children: [
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(color: _kGold, label: 'Câu hiện tại'),
              const SizedBox(width: 16),
              _LegendItem(color: _kSafeGreen, label: 'Mốc an toàn'),
            ],
          ),
          const SizedBox(height: 8),
          // Countdown bar
          _CountdownBar(duration: const Duration(milliseconds: 2800)),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6, height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withOpacity(0.6),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

// ── Ladder row ───────────────────────────────────────────
class _LadderRow extends StatelessWidget {
  final int levelIdx;
  final int justAnswered;

  const _LadderRow({required this.levelIdx, required this.justAnswered});

  @override
  Widget build(BuildContext context) {
    final pts    = kPrizeLevels[levelIdx];
    final qNum   = levelIdx + 1;
    final isCurrent    = levelIdx == justAnswered;
    final isPassed     = levelIdx < justAnswered;
    final isSafe       = kSafeMilestones.contains(qNum);
    final isSafeActive = isSafe && !isPassed && !isCurrent;

    // ── Row colors ──────────────────────────────────────
    Color rowBg;
    Color numColor;
    Color prizeColor;
    Border? border;

    if (isCurrent) {
      rowBg       = _kGoldBg;
      numColor    = _kGoldDark;
      prizeColor  = _kGoldDark;
      border      = const Border(
        top:    BorderSide(color: _kGoldBorder),
        bottom: BorderSide(color: _kGoldBorder),
      );
    } else if (isSafeActive) {
      rowBg      = _kSafeGreenBg;
      numColor   = _kSafeGreenDark;
      prizeColor = _kSafeGreenDark;
      border     = const Border(
        bottom: BorderSide(color: _kBorderLight, width: 0.5),
      );
    } else {
      rowBg      = Colors.white;
      numColor   = isPassed ? _kNumDefault.withOpacity(_kPassedOpacity) : _kNumDefault;
      prizeColor = isPassed ? _kPrizeDefault.withOpacity(_kPassedOpacity) : _kPrizeDefault;
      border     = const Border(
        bottom: BorderSide(color: _kBorderLight, width: 0.5),
      );
    }

    final double rowHeight = isCurrent ? _kCurrentRowH : _kRowH;

    return Opacity(
      opacity: isPassed ? _kPassedOpacity : 1.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        height: rowHeight,
        decoration: BoxDecoration(color: rowBg, border: border),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            // Question number
            SizedBox(
              width: 28,
              child: Text(
                '$qNum',
                style: TextStyle(
                  fontSize: isCurrent ? 15 : 12,
                  fontWeight: FontWeight.w700,
                  color: numColor,
                ),
              ),
            ),

            // Safe milestone dot
            SizedBox(
              width: 18,
              child: isSafeActive
                  ? Container(
                      width: 7, height: 7,
                      decoration: BoxDecoration(
                        color: _kSafeGreen,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _kSafeGreen.withOpacity(0.5),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                    )
                  : null,
            ),

            // Prize amount (centered)
            Expanded(
              child: Center(
                child: Text(
                  _formatPts(pts),
                  style: TextStyle(
                    fontSize: isCurrent ? 22 : 14,
                    fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w700,
                    color: prizeColor,
                    letterSpacing: isCurrent ? 1.0 : 0.5,
                  ),
                ),
              ),
            ),

            // Right icon
            SizedBox(
              width: 24,
              child: isCurrent
                  ? const Icon(Icons.star_rounded, color: _kGold, size: 20)
                  : isPassed
                      ? Icon(Icons.check_circle_rounded,
                          color: _kNumDefault.withOpacity(0.5), size: 15)
                      : null,
            ),
          ],
        ),
      ),
    );
  }

  String _formatPts(int pts) {
    // kPrizeLevels max = 3000 điểm
    if (pts >= 1000) {
      final thousands  = pts ~/ 1000;
      final remainder  = pts % 1000;
      if (remainder == 0) return '$thousands Sao';
      return '$thousands.${remainder.toString().padLeft(3, '0')} Sao';
    }
    return '$pts Sao';
  }
}

// ── Countdown bar ────────────────────────────────────────
class _CountdownBar extends StatefulWidget {
  final Duration duration;
  const _CountdownBar({required this.duration});

  @override
  State<_CountdownBar> createState() => _CountdownBarState();
}

class _CountdownBarState extends State<_CountdownBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: LinearProgressIndicator(
          value: 1 - _ctrl.value,
          minHeight: 2,
          backgroundColor: Colors.white.withOpacity(0.15),
          valueColor: const AlwaysStoppedAnimation(_kGold),
        ),
      ),
    );
  }
}

// ── Diamond widget ───────────────────────────────────────
class _DiamondWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(10, 10),
      painter: _DiamondPainter(color: _kGold),
    );
  }
}

class _DiamondPainter extends CustomPainter {
  final Color color;
  const _DiamondPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(0, size.height / 2)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}