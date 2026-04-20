import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Gradient card displaying the room code with a copy button.
class RoomCodeCard extends StatefulWidget {
  final String roomId;
  final String password;
  final Animation<double> pulseAnim;

  const RoomCodeCard({
    super.key,
    required this.roomId,
    required this.password,
    required this.pulseAnim,
  });

  @override
  State<RoomCodeCard> createState() => _RoomCodeCardState();
}

class _RoomCodeCardState extends State<RoomCodeCard> {
  bool _codeCopied = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF9B8FFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Mã phòng',
            style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          ScaleTransition(
            scale: widget.pulseAnim,
            child: Text(
              widget.roomId,
              style: const TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 8,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _actionBtn(
                icon: _codeCopied ? Icons.check_rounded : Icons.copy_rounded,
                label: _codeCopied ? 'Đã sao chép' : 'Sao chép',
                onTap: () {
                  Clipboard.setData(ClipboardData(text: widget.roomId));
                  setState(() => _codeCopied = true);
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) setState(() => _codeCopied = false);
                  });
                },
              ),
              if (widget.password.isNotEmpty) ...[
                const SizedBox(width: 12),
                _actionBtn(icon: Icons.lock_rounded, label: '🔒 Có mật khẩu', onTap: null),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn({required IconData icon, required String label, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}