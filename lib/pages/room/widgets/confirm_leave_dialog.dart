import 'package:flutter/material.dart';

/// Animated confirmation dialog for leaving/dissolving a room.
class ConfirmLeaveDialog extends StatefulWidget {
  final bool isHost;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ConfirmLeaveDialog({
    super.key,
    required this.isHost,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<ConfirmLeaveDialog> createState() => _ConfirmLeaveDialogState();
}

class _ConfirmLeaveDialogState extends State<ConfirmLeaveDialog>
    with TickerProviderStateMixin {
  late AnimationController _enterCtrl;
  late AnimationController _shakeCtrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _shakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _enterCtrl, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut),
    );
    _shakeAnim = Tween<Offset>(begin: const Offset(-0.02, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));

    _enterCtrl.forward();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _shakeCtrl.dispose();
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
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: SlideTransition(
            position: _shakeAnim,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE24B4A).withOpacity(0.15),
                    blurRadius: 40,
                    offset: const Offset(0, 16),
                    spreadRadius: 8,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  _buildWarningBox(),
                  _buildActions(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.isHost
              ? [const Color(0xFFE24B4A), const Color(0xFFE67B7B)]
              : [const Color(0xFFF59E0B), const Color(0xFFF5B840)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            ),
            child: Center(
              child: Text(widget.isHost ? '👑' : '👋', style: const TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Rời phòng?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBox() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.isHost ? const Color(0xFFFFF3F3) : const Color(0xFFFFF8F0),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isHost
                ? const Color(0xFFE24B4A).withOpacity(0.2)
                : const Color(0xFFF59E0B).withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.isHost ? '⚠️' : 'ℹ️', style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.isHost
                    ? 'Bạn là chủ phòng. Thoát sẽ xóa phòng và dữ liệu tất cả người chơi!'
                    : 'Bạn sẽ mất toàn bộ điểm số và thông tin trong phòng này.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: widget.isHost ? const Color(0xFFB71C1C) : const Color(0xFFB8860B),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: widget.onCancel,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  foregroundColor: const Color(0xFF757575),
                ),
                child: const Text('Huỷ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: widget.onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isHost ? const Color(0xFFE24B4A) : const Color(0xFFF59E0B),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  widget.isHost ? 'Thoát phòng' : 'Rời khỏi',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}