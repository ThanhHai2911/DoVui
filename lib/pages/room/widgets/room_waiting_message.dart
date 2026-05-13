import 'package:flutter/material.dart';

class RoomWaitingMessage extends StatelessWidget {
  const RoomWaitingMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFEEEDFE),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('⏳', style: TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Chờ chủ phòng bắt đầu...',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF534AB7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Bạn đã tham gia phòng thành công',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}