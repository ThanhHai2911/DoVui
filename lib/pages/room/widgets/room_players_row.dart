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
    '🦊', '🐉', '🐱', '🤖', '🐼', '🦁', '🐸', '🦋',
  ];

  static const List<_EmojiAnimType> _emojiAnimTypes = [
    _EmojiAnimType.run,
    _EmojiAnimType.fly,
    _EmojiAnimType.idle,
    _EmojiAnimType.scan,
    _EmojiAnimType.sway,
    _EmojiAnimType.roar,
    _EmojiAnimType.jump,
    _EmojiAnimType.flap,
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
            final avatarSize = (itemWidth * 0.68).clamp(52.0, 70.0);

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
                    animType: _emojiAnimTypes[index % _emojiAnimTypes.length],
                    isOnline: (presenceMap[players[index].userId] ?? 0) > 0,
                    avatarSize: avatarSize,
                  );
                }
                return _EmptySlot(avatarSize: avatarSize);
              },
            );
          },
        ),
      ],
    );
  }
}

// ─────────────── Enum ───────────────

enum _EmojiAnimType { run, fly, idle, scan, sway, roar, jump, flap }

// ─────────────── Player Card ───────────────

class _PlayerCard extends StatefulWidget {
  final RoomPlayer player;
  final bool isMe;
  final List<Color> palette;
  final String emoji;
  final _EmojiAnimType animType;
  final bool isOnline;
  final double avatarSize;

  const _PlayerCard({
    required this.player,
    required this.isMe,
    required this.palette,
    required this.emoji,
    required this.animType,
    required this.isOnline,
    required this.avatarSize,
  });

  @override
  State<_PlayerCard> createState() => _PlayerCardState();
}

class _PlayerCardState extends State<_PlayerCard>
    with TickerProviderStateMixin {

  // Online dot blink
  late final AnimationController _blinkCtrl;
  late final Animation<double> _blinkOpacity;

  // Crown bounce
  late final AnimationController _crownCtrl;
  late final Animation<double> _crownOffsetY;
  late final Animation<double> _crownRotate;

  // Emoji motion
  late final AnimationController _emojiCtrl;

  @override
  void initState() {
    super.initState();

    // Online dot nhấp nháy
    _blinkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _blinkOpacity = Tween<double>(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(parent: _blinkCtrl, curve: Curves.easeInOut),
    );

    // Crown nảy lên xuống + xoay nhẹ
    _crownCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _crownOffsetY = Tween<double>(begin: 0, end: -4).animate(
      CurvedAnimation(parent: _crownCtrl, curve: Curves.easeInOut),
    );
    _crownRotate = Tween<double>(begin: -0.14, end: 0.14).animate(
      CurvedAnimation(parent: _crownCtrl, curve: Curves.easeInOut),
    );

    // Emoji chuyển động
    _emojiCtrl = AnimationController(
      vsync: this,
      duration: _emojiDuration(widget.animType),
    )..repeat(reverse: _needsReverse(widget.animType));
  }

  Duration _emojiDuration(_EmojiAnimType t) {
    switch (t) {
      case _EmojiAnimType.run:   return const Duration(milliseconds: 1400);
      case _EmojiAnimType.fly:   return const Duration(milliseconds: 2000);
      case _EmojiAnimType.idle:  return const Duration(milliseconds: 3500);
      case _EmojiAnimType.scan:  return const Duration(milliseconds: 1800);
      case _EmojiAnimType.sway:  return const Duration(milliseconds: 1600);
      case _EmojiAnimType.roar:  return const Duration(milliseconds: 2400);
      case _EmojiAnimType.jump:  return const Duration(milliseconds: 1800);
      case _EmojiAnimType.flap:  return const Duration(milliseconds: 450);
    }
  }

  bool _needsReverse(_EmojiAnimType t) {
    switch (t) {
      case _EmojiAnimType.fly:
      case _EmojiAnimType.sway:
      case _EmojiAnimType.scan:
        return true;
      default:
        return false;
    }
  }

  Widget _buildAnimatedEmoji(double fontSize) {
    final child = Text(widget.emoji, style: TextStyle(fontSize: fontSize));
    switch (widget.animType) {

      // 🦊 Chạy sang trái/phải
      case _EmojiAnimType.run:
        return AnimatedBuilder(
          animation: _emojiCtrl,
          builder: (_, __) {
            final v = _emojiCtrl.value;
            double dx = 0, angle = 0;
            bool flipX = false;
            if (v < 0.25) {
              dx = v * 8; angle = v * 0.35;
            } else if (v < 0.5) {
              dx = (0.5 - v) * 8; angle = -(0.5 - v) * 0.35; flipX = true;
            } else if (v < 0.75) {
              dx = -(v - 0.5) * 8; angle = -(v - 0.5) * 0.35; flipX = true;
            } else {
              dx = -(1 - v) * 8; angle = (1 - v) * 0.35;
            }
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..translate(dx, 0.0)
                ..rotateZ(angle)
                ..scale(flipX ? -1.0 : 1.0, 1.0),
              child: child,
            );
          },
        );

      // 🐉 Bay lên xuống + lắc
      case _EmojiAnimType.fly:
        return AnimatedBuilder(
          animation: _emojiCtrl,
          builder: (_, __) => Transform.translate(
            offset: Offset(0, -6 * _emojiCtrl.value),
            child: Transform.rotate(
              angle: 0.06 * (_emojiCtrl.value - 0.5),
              child: child,
            ),
          ),
        );

      // 🐱 Đứng im rồi bất ngờ lắc đầu
      case _EmojiAnimType.idle:
        return AnimatedBuilder(
          animation: _emojiCtrl,
          builder: (_, __) {
            final v = _emojiCtrl.value;
            double angle = 0;
            if (v > 0.75) {
              final sub = (v - 0.75) / 0.25;
              angle = (sub < 0.5 ? sub : 1 - sub) * 0.28;
            }
            return Transform.rotate(angle: angle, child: child);
          },
        );

      // 🤖 Pulse scale nhẹ
      case _EmojiAnimType.scan:
        return AnimatedBuilder(
          animation: _emojiCtrl,
          builder: (_, __) => Transform.scale(
            scale: 1.0 + 0.08 * _emojiCtrl.value,
            child: child,
          ),
        );

      // 🐼 Lắc trái phải
      case _EmojiAnimType.sway:
        return AnimatedBuilder(
          animation: _emojiCtrl,
          builder: (_, __) => Transform.rotate(
            angle: 0.18 * (_emojiCtrl.value * 2 - 1),
            child: child,
          ),
        );

      // 🦁 Scale đột ngột (gầm)
      case _EmojiAnimType.roar:
        return AnimatedBuilder(
          animation: _emojiCtrl,
          builder: (_, __) {
            final v = _emojiCtrl.value;
            double s = 1.0;
            if (v > 0.65 && v < 0.72) {
              s = 1.0 + (v - 0.65) / 0.07 * 0.22;
            } else if (v >= 0.72 && v < 0.80) {
              s = 1.22 - (v - 0.72) / 0.08 * 0.22;
            }
            return Transform.scale(scale: s, child: child);
          },
        );

      // 🐸 Nhảy lên có squash & stretch
      case _EmojiAnimType.jump:
        return AnimatedBuilder(
          animation: _emojiCtrl,
          builder: (_, __) {
            final v = _emojiCtrl.value;
            double dy = 0, sy = 1, sx = 1;
            if (v < 0.4) {
              dy = -8 * (v / 0.4);
              sx = 1 - 0.1 * (v / 0.4);
              sy = 1 + 0.1 * (v / 0.4);
            } else if (v < 0.55) {
              dy = -8 + 10 * ((v - 0.4) / 0.15);
              sx = 1 + 0.1 * ((v - 0.4) / 0.15);
              sy = 1 - 0.1 * ((v - 0.4) / 0.15);
            }
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..translate(0.0, dy)
                ..scale(sx, sy),
              child: child,
            );
          },
        );

      // 🦋 Vỗ cánh
      case _EmojiAnimType.flap:
        return AnimatedBuilder(
          animation: _emojiCtrl,
          builder: (_, __) => Transform.scale(
            scaleX: 0.5 + 0.5 * _emojiCtrl.value,
            child: child,
          ),
        );
    }
  }

  @override
  void dispose() {
    _blinkCtrl.dispose();
    _crownCtrl.dispose();
    _emojiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avatarSize = widget.avatarSize;

    // Item hoàn toàn tĩnh — chỉ nội dung bên trong chuyển động
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Avatar tĩnh
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: widget.palette,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: _buildAnimatedEmoji(avatarSize * 0.42),
                ),
              ),

              // Crown chuyển động
              if (widget.player.isHost)
                AnimatedBuilder(
                  animation: _crownCtrl,
                  builder: (_, __) => Positioned(
                    top: -6 + _crownOffsetY.value,
                    right: -2,
                    child: Transform.rotate(
                      angle: _crownRotate.value,
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
                  ),
                ),

              // Online dot — chỉ dot nhấp nháy, không ảnh hưởng layout
              Positioned(
                bottom: 2,
                right: 2,
                child: widget.isOnline
                    ? FadeTransition(
                        opacity: _blinkOpacity,
                        child: Container(
                          width: 11,
                          height: 11,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF4CD97B),
                            border:
                                Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      )
                    : Container(
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade300,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        Text(
          widget.isMe ? 'Bạn' : widget.player.displayName,
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
            const Text('🏆', style: TextStyle(fontSize: 9)),
            const SizedBox(width: 2),
            Flexible(
              child: Text(
                _formatScore(widget.player.score),
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

// ─────────────── Empty Slot ───────────────

class _EmptySlot extends StatelessWidget {
  final double avatarSize;

  const _EmptySlot({required this.avatarSize});

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