import 'package:dovui/data/models/room_model.dart';
import 'package:flutter/material.dart';

/// Leaderboard table shown in the room waiting lobby.
class LeaderboardWidget extends StatelessWidget {
  final List<RoomPlayer> players;
  final String currentUserId;

  const LeaderboardWidget({
    super.key,
    required this.players,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = [...players]..sort((a, b) => b.score.compareTo(a.score));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '🏆 Bảng xếp hạng',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B)),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEEEDFE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${players.length}/8',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF534AB7)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              _buildTableHeader(),
              ...sorted.asMap().entries.map((e) {
                final rank = e.key;
                final player = e.value;
                return _PlayerRow(
                  rank: rank,
                  player: player,
                  isMe: player.userId == currentUserId,
                  isLast: rank == sorted.length - 1 && players.length >= 4,
                );
              }),
              ...List.generate(
                (4 - players.length).clamp(0, 4),
                (i) => _EmptySlot(isLast: i == (4 - players.length - 1).clamp(0, 3)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F7FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 28),
          const SizedBox(width: 10),
          const SizedBox(width: 38),
          const SizedBox(width: 10),
          const Expanded(
            child: Text('Người chơi',
                style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E), fontWeight: FontWeight.w600)),
          ),
          Text('Điểm', style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  final int rank;
  final RoomPlayer player;
  final bool isMe;
  final bool isLast;

  const _PlayerRow({
    required this.rank,
    required this.player,
    required this.isMe,
    required this.isLast,
  });

  static const _avatarColors = [
    [Color(0xFFEEEDFE), Color(0xFF534AB7)],
    [Color(0xFFE1F5EE), Color(0xFF085041)],
    [Color(0xFFFAEEDA), Color(0xFF633806)],
    [Color(0xFFFBEAF0), Color(0xFF72243E)],
    [Color(0xFFE6F1FB), Color(0xFF0C447C)],
  ];

  @override
  Widget build(BuildContext context) {
    final rankEmojis = ['🥇', '🥈', '🥉'];
    final rankLabel = rank < 3 ? rankEmojis[rank] : '${rank + 1}';
    final initials = player.displayName.isNotEmpty
        ? player.displayName.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase()
        : '?';
    final colors = _avatarColors[rank % _avatarColors.length];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFFF8F7FF) : Colors.white,
        borderRadius: isLast ? const BorderRadius.vertical(bottom: Radius.circular(20)) : null,
        border: Border(
          top: BorderSide(color: Colors.grey.shade100),
          left: isMe ? const BorderSide(color: Color(0xFF6C63FF), width: 3) : BorderSide.none,
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 28, child: Text(rankLabel, style: const TextStyle(fontSize: 16), textAlign: TextAlign.center)),
          const SizedBox(width: 10),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: colors[0], shape: BoxShape.circle),
            child: Center(
              child: Text(initials, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colors[1])),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    isMe ? '${player.displayName} (Tôi)' : player.displayName,
                    style: TextStyle(
                        fontSize: 14, fontWeight: isMe ? FontWeight.bold : FontWeight.w500, color: const Color(0xFF1E1B4B)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (player.isHost) ...[
                  const SizedBox(width: 4),
                  const Text('👑', style: TextStyle(fontSize: 10)),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: rank == 0
                  ? const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA000)])
                  : null,
              color: rank == 0 ? null : const Color(0xFFF0EFFF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${player.score} ⭐',
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: rank == 0 ? Colors.white : const Color(0xFF534AB7)),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  final bool isLast;
  const _EmptySlot({required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
        borderRadius: isLast ? const BorderRadius.vertical(bottom: Radius.circular(20)) : null,
      ),
      child: Row(
        children: [
          const SizedBox(width: 28),
          const SizedBox(width: 10),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Icon(Icons.add_rounded, size: 18, color: Colors.grey.shade400),
          ),
          const SizedBox(width: 10),
          Text('Đang chờ người chơi...', style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
        ],
      ),
    );
  }
}