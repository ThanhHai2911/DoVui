import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RoomCodeCard extends StatelessWidget {
  final String roomId;
  final String? password;
  final Animation<double> pulseAnim;

  const RoomCodeCard({
    super.key,
    required this.roomId,
    this.password,
    required this.pulseAnim,
  });

  String _formatCode(String id) {
    final clean = id.replaceAll('-', '').toUpperCase();
    if (clean.length >= 6) {
      return '${clean.substring(0, 3)}${clean.substring(3, 6)}';
    }
    return id.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: pulseAnim,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 14, 14, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MÃ PHÒNG',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.8,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatCode(roomId),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6,
                      color: Color(0xFF7B6EF6),
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: roomId));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã sao chép mã phòng!'),
                    duration: Duration(seconds: 1),
                    backgroundColor: Color(0xFF7B6EF6),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.copy_outlined, color: Colors.white, size: 15),
                    SizedBox(width: 6),
                    Text(
                      'Sao chép',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}