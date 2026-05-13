import 'package:dovui/data/models/room_model.dart';
import 'package:flutter/material.dart';
import 'room_avatar_palettes.dart';

// ─── Players Row ──────────────────────────────────────────────────────────────

class RoomPlayersRow extends StatelessWidget {
  final RoomModel room;
  final String currentUserId;
  final Map<String, int> presenceMap;

  const RoomPlayersRow({
    super.key,
    required this.room,
    required this.currentUserId,
    required this.presenceMap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'NGƯỜI CHƠI',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.grey.shade500,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${room.players.length}/8',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {},
              child: const Row(
                children: [
                  Text(
                    'Xem tất cả',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6C63FF),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: Color(0xFF6C63FF),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: room.players.length < 8
                ? room.players.length + 1
                : room.players.length,
            itemBuilder: (context, index) {
              if (index == room.players.length && room.players.length < 8) {
                return const RoomInviteSlot();
              }
              final player = room.players[index];
              final isMe = player.userId == currentUserId;
              final isOnline = presenceMap[player.userId] != null;
              return RoomPlayerAvatar(
                player: player,
                isMe: isMe,
                isOnline: isOnline,
                paletteIndex: index % kAvatarPalettes.length,
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Player Avatar ────────────────────────────────────────────────────────────

class RoomPlayerAvatar extends StatelessWidget {
  final RoomPlayer player;
  final bool isMe;
  final bool isOnline;
  final int paletteIndex;

  const RoomPlayerAvatar({
    super.key,
    required this.player,
    required this.isMe,
    required this.isOnline,
    required this.paletteIndex,
  });

  String get _initials {
    final name = player.displayName.trim();
    if (name.isEmpty) return '?';
    final parts = name.split(' ').where((w) => w.isNotEmpty).toList();
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final palette = kAvatarPalettes[paletteIndex];
    final bgColor = palette[0];
    final textColor = palette[1];

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: bgColor,
                  border: isMe
                      ? Border.all(color: const Color(0xFF6C63FF), width: 2.5)
                      : Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: isMe
                          ? const Color(0xFF6C63FF).withOpacity(0.25)
                          : Colors.black.withOpacity(0.07),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _initials,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
              if (isOnline)
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 7),
          SizedBox(
            width: 68,
            child: Text(
              player.displayName,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isMe ? FontWeight.w700 : FontWeight.w500,
                color: const Color(0xFF1E1B4B),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⭐', style: TextStyle(fontSize: 10)),
              const SizedBox(width: 2),
              Text(
                '${player.score}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E1B4B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Invite Slot ──────────────────────────────────────────────────────────────

class RoomInviteSlot extends StatelessWidget {
  const RoomInviteSlot({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.add_rounded,
              size: 26,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Mời bạn',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}