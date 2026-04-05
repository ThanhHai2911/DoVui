import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/millionaire_bloc.dart';
import 'millionaire_colors.dart';

/// Full-screen overlay hiển thị bảng điểm dọc,
/// highlight câu vừa trả lời đúng, tự động đóng sau 2.5s
class PrizeLadderOverlay extends StatefulWidget {
  const PrizeLadderOverlay({super.key});

  @override
  State<PrizeLadderOverlay> createState() => _PrizeLadderOverlayState();
}

class _PrizeLadderOverlayState extends State<PrizeLadderOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _slideIn;
  Timer? _autoClose;
  late ScrollController _scrollCtrl;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController();

    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _slideIn = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();

    // Scroll đến câu hiện tại sau khi build xong
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrent());

    // Tự động đóng sau 2.5s
    _autoClose = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        context.read<MillionaireBloc>().add(PrizeLadderDismissed());
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _autoClose?.cancel();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToCurrent() {
    final state = context.read<MillionaireBloc>().state;
    // câu vừa trả lời đúng = currentIndex - 1 (đã tăng)
    final justAnswered = (state.currentIndex - 1).clamp(0, 14);
    // Scroll lên vị trí của câu đó (từ dưới lên, đảo index)
    final itemH = 52.0;
    final offset = (14 - justAnswered) * itemH;
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        offset.clamp(0, _scrollCtrl.position.maxScrollExtent),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MillionaireBloc, MillionaireState>(
      builder: (context, state) {
        // câu vừa trả lời đúng
        final justAnswered = (state.currentIndex - 1).clamp(0, 14);

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(_slideIn),
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF020014), Color(0xFF0A0530)],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _kGreen,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: _kGreen, blurRadius: 8)],
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'BẢNG ĐIỂM',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 4,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _kGreen,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: _kGreen, blurRadius: 8)],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Ladder list (từ 15 xuống 1)
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        itemCount: 15,
                        itemBuilder: (_, i) {
                          // Hiển thị từ 15 → 1
                          final levelIdx = 14 - i;
                          final isJustAnswered = levelIdx == justAnswered;
                          final isPassed =
                              levelIdx < justAnswered;
                          final isSafe =
                              kSafeMilestones.contains(levelIdx + 1);

                          return _LadderRow(
                            levelIdx: levelIdx,
                            isHighlighted: isJustAnswered,
                            isPassed: isPassed,
                            isSafe: isSafe,
                          );
                        },
                      ),
                    ),

                    // Tiến độ tự đóng
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 12, 40, 20),
                      child: _CountdownBar(duration: const Duration(milliseconds: 2500)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Single row ──────────────────────────────────────────
class _LadderRow extends StatelessWidget {
  final int levelIdx;
  final bool isHighlighted;
  final bool isPassed;
  final bool isSafe;

  const _LadderRow({
    required this.levelIdx,
    required this.isHighlighted,
    required this.isPassed,
    required this.isSafe,
  });

  @override
  Widget build(BuildContext context) {
    final pts     = kPrizeLevels[levelIdx];
    final qNum    = levelIdx + 1;
    final ptsText = _formatPts(pts);

    Color rowBg, numColor, ptsColor;
    Border? border;

    if (isHighlighted) {
      rowBg    = _kGreen.withOpacity(0.2);
      numColor = _kGreen;
      ptsColor = _kGreen;
      border   = Border.all(color: _kGreen, width: 1.5);
    } else if (isSafe && !isPassed) {
      rowBg    = Colors.transparent;
      numColor = _kGreen.withOpacity(0.7);
      ptsColor = _kGreen.withOpacity(0.7);
      border   = null;
    } else if (isPassed) {
      rowBg    = Colors.transparent;
      numColor = Colors.white24;
      ptsColor = Colors.white24;
      border   = null;
    } else {
      rowBg    = Colors.transparent;
      numColor = Colors.white54;
      ptsColor = Colors.white70;
      border   = null;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: rowBg,
        borderRadius: BorderRadius.circular(8),
        border: border,
        boxShadow: isHighlighted
            ? [BoxShadow(color: _kGreen.withOpacity(0.4), blurRadius: 16)]
            : null,
      ),
      child: Row(
        children: [
          // Số thứ tự
          SizedBox(
            width: 32,
            child: Text(
              '$qNum',
              style: TextStyle(
                fontSize: isHighlighted ? 18 : 15,
                fontWeight: FontWeight.bold,
                color: numColor,
              ),
            ),
          ),
          // Safe indicator
          if (isSafe && !isPassed)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _kGreen,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: _kGreen, blurRadius: 6)],
                ),
              ),
            )
          else
            const SizedBox(width: 16),
          // Điểm
          Expanded(
            child: Text(
              ptsText,
              style: TextStyle(
                fontSize: isHighlighted ? 22 : 16,
                fontWeight: isHighlighted ? FontWeight.w900 : FontWeight.w600,
                color: ptsColor,
                letterSpacing: 1,
              ),
            ),
          ),
          // Check icon nếu đã qua
          if (isPassed)
            const Icon(Icons.check_circle_rounded,
                color: Colors.white24, size: 16)
          else if (isHighlighted)
            const Icon(Icons.star_rounded, color: _kGreen, size: 20),
        ],
      ),
    );
  }

  String _formatPts(int pts) {
    if (pts >= 1000) {
      return '${(pts / 1000).toStringAsFixed(pts % 1000 == 0 ? 0 : 1)}.000';
    }
    return '$pts';
  }
}

// ── Countdown progress bar ──────────────────────────────
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
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: 1 - _ctrl.value,
          minHeight: 3,
          backgroundColor: Colors.white12,
          valueColor: AlwaysStoppedAnimation<Color>(
              _kGreen.withOpacity(0.7)),
        ),
      ),
    );
  }
}

const Color _kGreen = Color(0xFF4CFF8C);