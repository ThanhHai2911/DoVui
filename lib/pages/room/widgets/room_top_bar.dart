import 'package:dovui/data/models/room_model.dart';
import 'package:flutter/material.dart';

class RoomTopBar extends StatelessWidget {
  final RoomModel room;
  final bool isHost;
  final VoidCallback onLeave;

  const RoomTopBar({
    super.key,
    required this.room,
    required this.isHost,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: onLeave,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 127, 124, 124).withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Color(0xFF333333),
                size: 24,
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'PHÒNG CHƠI',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      room.categoryName.isNotEmpty
                          ? room.categoryName
                          : 'Phòng chơi',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}