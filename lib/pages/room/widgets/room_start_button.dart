import 'package:dovui/data/models/room_model.dart';
import 'package:flutter/material.dart';

class RoomStartButton extends StatelessWidget {
  final RoomModel room;
  final VoidCallback onStart;

  const RoomStartButton({
    super.key,
    required this.room,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final canStart = room.players.length >= 2;

    return GestureDetector(
      onTap: canStart ? onStart : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: canStart
              ? const LinearGradient(
                  colors: [Color(0xFF7B6EF6), Color(0xFFFF6FA3)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: canStart ? null : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(18),
          boxShadow: canStart
              ? [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (canStart) ...[
              const Text('🚀', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
            ],
            Text(
              canStart ? 'BẮT ĐẦU CHƠI' : 'Cần ít nhất 2 người trong phòng',
              style: TextStyle(
                fontSize: canStart ? 16 : 13,
                fontWeight: FontWeight.w800,
                letterSpacing: canStart ? 0.8 : 0,
                color: canStart ? Colors.white : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}