import 'package:dovui/data/models/room_model.dart';
import 'package:flutter/material.dart';

/// Top bar shown during active gameplay in the room lobby.
class PlayingHeader extends StatelessWidget {
  final RoomModel room;
  final String currentUserId;

  const PlayingHeader({
    super.key,
    required this.room,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = [...room.players]..sort((a, b) => b.score.compareTo(a.score));
    final remaining = room.players.where((p) => !p.isFinished).length;
    final allDone = room.players.every((p) => p.isFinished);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          _RoomIdBadge(roomId: room.roomId),
          const SizedBox(width: 10),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: sorted.map((p) {
                  final isMe = p.userId == currentUserId;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _PlayerScoreChip(player: p, isMe: isMe),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _StatusBadge(allDone: allDone, remaining: remaining),
        ],
      ),
    );
  }
}

class _RoomIdBadge extends StatelessWidget {
  final String roomId;
  const _RoomIdBadge({required this.roomId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF6C63FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        roomId,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 13),
      ),
    );
  }
}

class _PlayerScoreChip extends StatelessWidget {
  final RoomPlayer player;
  final bool isMe;

  const _PlayerScoreChip({required this.player, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: player.isFinished
            ? const Color(0xFFE8F5E9)
            : isMe
                ? const Color(0xFFEEEDFE)
                : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: isMe ? Border.all(color: const Color(0xFF6C63FF)) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (player.isFinished)
            const Text('✓ ', style: TextStyle(fontSize: 10, color: Color(0xFF2E7D32))),
          Text(
            '${player.displayName.split(' ').last}: ${player.score}⭐',
            style: TextStyle(
              fontSize: 11,
              fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
              color: isMe ? const Color(0xFF534AB7) : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool allDone;
  final int remaining;

  const _StatusBadge({required this.allDone, required this.remaining});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: allDone ? const Color(0xFFE8F5E9) : const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        allDone ? '✅ Xong!' : '⏳ $remaining còn lại',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: allDone ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
        ),
      ),
    );
  }
}