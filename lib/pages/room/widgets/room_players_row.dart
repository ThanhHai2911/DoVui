import 'package:dovui/data/models/room_model.dart';
import 'package:flutter/material.dart';

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

  static const List<List<Color>> _palettes = [
    [Color(0xFF9B6BFF), Color(0xFFD4AAFF)],
    [Color(0xFF22C8F0), Color(0xFF80E8FF)],
    [Color(0xFFFF6FA3), Color(0xFFFFB3CC)],
    [Color(0xFF4CD97B), Color(0xFFA8F0C2)],
    [Color(0xFFFF9F43), Color(0xFFFFD4A0)],
    [Color(0xFF5BC8FF), Color(0xFFB3E8FF)],
    [Color(0xFFFF8C69), Color(0xFFFFBFA0)],
    [Color(0xFFB06EFF), Color(0xFFDDB3FF)],
  ];

  static const List<String> _avatarEmojis = [
    '🦊',
    '🐉',
    '🐱',
    '🤖',
    '🐼',
    '🦁',
    '🐸',
    '🦋',
  ];

  @override
  Widget build(BuildContext context) {
    final players = room.players;
    const maxSlots = 8;

    final screenWidth = MediaQuery.of(context).size.width;

    double childAspectRatio = 0.72;

    if (screenWidth < 360) {
      childAspectRatio = 0.70;
    } else if (screenWidth > 600) {
      childAspectRatio = 0.95;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Người chơi ${players.length}/$maxSlots',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFEFEBFF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'CHƠI CÙNG BẠN BÈ',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: Color(0xFF7B6EF6),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = (constraints.maxWidth - 24) / 4;

            double avatarSize = itemWidth * 0.68;

            avatarSize = avatarSize.clamp(52, 70);

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: maxSlots,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 8,
                childAspectRatio: childAspectRatio,
              ),
              itemBuilder: (context, index) {
                if (index < players.length) {
                  return _PlayerCard(
                    player: players[index],
                    isMe: players[index].userId == currentUserId,
                    palette: _palettes[index % _palettes.length],
                    emoji: _avatarEmojis[index % _avatarEmojis.length],
                    isOnline:
                        (presenceMap[players[index].userId] ?? 0) > 0,
                    avatarSize: avatarSize,
                  );
                }

                return _EmptySlot(
                  avatarSize: avatarSize,
                );
              },
            );
          },
        ),
      ],
    );
  }
}

// ───────────────── Player Card ─────────────────

class _PlayerCard extends StatelessWidget {
  final RoomPlayer player;
  final bool isMe;
  final List<Color> palette;
  final String emoji;
  final bool isOnline;
  final double avatarSize;

  const _PlayerCard({
    required this.player,
    required this.isMe,
    required this.palette,
    required this.emoji,
    required this.isOnline,
    required this.avatarSize,
  });

  @override
  Widget build(BuildContext context) {
    final innerSize = avatarSize - 8;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: palette,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

              Text(
                emoji,
                style: TextStyle(
                  fontSize: avatarSize * 0.42,
                ),
              ),

              if (player.isHost)
                Positioned(
                  top: -6,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFB300),
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '👑',
                      style: TextStyle(fontSize: 8),
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        Text(
          isMe ? 'Bạn' : player.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),

        const SizedBox(height: 2),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🏆',
              style: TextStyle(fontSize: 9),
            ),
            const SizedBox(width: 2),
            Flexible(
              child: Text(
                _formatScore(player.score),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFF9F43),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatScore(int score) {
    if (score >= 1000) {
      return '${(score / 1000).toStringAsFixed(score % 1000 == 0 ? 0 : 1)}K';
    }
    return score.toString();
  }
}

// ───────────────── Empty Slot ─────────────────

class _EmptySlot extends StatelessWidget {
  final double avatarSize;

  const _EmptySlot({
    required this.avatarSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: Colors.grey.shade200,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.add_rounded,
              color: Colors.grey.shade400,
              size: avatarSize * 0.35,
            ),
          ),
        ),

        const SizedBox(height: 6),

        Text(
          'Mời bạn',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
          ),
        ),

        Text(
          '+ Trống',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade400,
          ),
        ),
      ],
    );
  }
}