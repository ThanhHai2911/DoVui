import 'package:flutter/material.dart';

/// Dialog shown when the current player finishes the quiz while waiting for others.
class CompletionDialog extends StatefulWidget {
  final int score;
  final String playerName;
  final VoidCallback onClose;

  const CompletionDialog({
    super.key,
    required this.score,
    required this.playerName,
    required this.onClose,
  });

  @override
  State<CompletionDialog> createState() => _CompletionDialogState();
}

class _CompletionDialogState extends State<CompletionDialog>
    with TickerProviderStateMixin {
  late AnimationController _enterCtrl;
  late AnimationController _starCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _shimmerCtrl;

  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _starScaleAnim;
  late Animation<double> _pulseAnim;
  late Animation<double> _shimmerAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _enterCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _starCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _shimmerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat();

    _scaleAnim = CurvedAnimation(parent: _enterCtrl, curve: Curves.elasticOut)
        .drive(Tween(begin: 0.5, end: 1.0));
    _fadeAnim = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut)
        .drive(Tween(begin: 0.0, end: 1.0));
    _slideAnim = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut)
        .drive(Tween(begin: const Offset(0, 0.3), end: Offset.zero));
    _starScaleAnim = CurvedAnimation(parent: _starCtrl, curve: Curves.elasticOut)
        .drive(Tween(begin: 0.0, end: 1.0));
    _pulseAnim = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut)
        .drive(Tween(begin: 1.0, end: 1.08));
    _shimmerAnim = _shimmerCtrl;

    _enterCtrl.forward();
    Future.delayed(const Duration(milliseconds: 300), () => _starCtrl.forward());
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _starCtrl.dispose();
    _pulseCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: 320,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.25),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                _buildScoreSection(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                  child: _buildStarRating(widget.score),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7C6FFF), Color(0xFFB09FFE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SlideTransition(
            position: _slideAnim,
            child: Column(
              children: [
                ScaleTransition(
                  scale: _pulseAnim,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      boxShadow: [
                        BoxShadow(color: Colors.white.withOpacity(0.3), blurRadius: 20, spreadRadius: 4),
                      ],
                    ),
                    child: const Center(child: Text('🏆', style: TextStyle(fontSize: 38))),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Hoàn thành!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
                ),
                const SizedBox(height: 4),
                Text(
                  'Xuất sắc lắm, ${widget.playerName.split(' ').last}!',
                  style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.85), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: GestureDetector(
            onTap: widget.onClose,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.25)),
              child: const Icon(Icons.close_rounded, size: 18, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
      child: Column(
        children: [
          Text(
            'Điểm số của bạn',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w500, letterSpacing: 0.5),
          ),
          const SizedBox(height: 16),
          ScaleTransition(
            scale: _starScaleAnim,
            child: AnimatedBuilder(
              animation: _shimmerAnim,
              builder: (context, child) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: const [Color(0xFFFFF8E1), Color(0xFFFFF3CD), Color(0xFFFFF8E1)],
                    stops: [0.0, _shimmerAnim.value, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFD54F), width: 2),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFFFD54F).withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 10),
                    Text(
                      '${widget.score}',
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Color(0xFFE65100), height: 1),
                    ),
                    const SizedBox(width: 4),
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text('điểm', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFBF360C))),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: const Color(0xFFF0EFFF), borderRadius: BorderRadius.circular(14)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: const Color(0xFF6C63FF)),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Chờ người chơi khác...',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF534AB7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating(int score) {
    final filled = (score / 2).round().clamp(0, 5);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        return AnimatedBuilder(
          animation: _starCtrl,
          builder: (context, _) {
            final delay = i * 0.12;
            final progress = ((_starCtrl.value - delay) / (1 - delay)).clamp(0.0, 1.0);
            final curve = Curves.elasticOut.transform(progress.clamp(0.0, 1.0));
            return Transform.scale(
              scale: curve,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Text(
                  i < filled ? '⭐' : '☆',
                  style: TextStyle(fontSize: 24, color: i < filled ? null : Colors.grey.shade300),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}