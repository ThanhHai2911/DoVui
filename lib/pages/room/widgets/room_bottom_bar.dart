import 'package:flutter/material.dart';

// ─── Bottom Bar ───────────────────────────────────────────────────────────────

class RoomBottomBar extends StatelessWidget {
  final bool isMicOn;
  final bool isSpeakerOn;
  final bool isChatOpen;
  final VoidCallback onMicToggle;
  final VoidCallback onSpeakerToggle;
  final VoidCallback onChatToggle;
  final VoidCallback onLeave;

  const RoomBottomBar({
    super.key,
    required this.isMicOn,
    required this.isSpeakerOn,
    required this.isChatOpen,
    required this.onMicToggle,
    required this.onSpeakerToggle,
    required this.onChatToggle,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.90),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Row(
  children: [
    Expanded(
      child: RoomBottomBarItem(
        child: isMicOn
            ? const Text('🎤', style: TextStyle(fontSize: 26))
            : Stack(
                alignment: Alignment.center,
                children: [
                  const Text('🎤', style: TextStyle(fontSize: 26)),
                  Transform.rotate(
                    angle: 0.8,
                    child: Container(
                      width: 32,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
        title: 'Mic',
        color: isMicOn ? Colors.green : Colors.grey,
        onTap: onMicToggle,
      ),
    ),
    const SizedBox(width: 6),
    Expanded(
      child: RoomBottomBarItem(
        child: Text(
          isSpeakerOn ? '🔊' : '🔇',
          style: const TextStyle(fontSize: 24),
        ),
        title: 'Loa',
        color: isSpeakerOn ? Colors.blue : Colors.grey,
        onTap: onSpeakerToggle,
      ),
    ),
    const SizedBox(width: 6),
    Expanded(
      child: RoomBottomBarItem(
        child: const Text('💬', style: TextStyle(fontSize: 24)),
        title: 'Chat',
        color: Colors.deepPurple,
        onTap: onChatToggle,
      ),
    ),
    const SizedBox(width: 6),
    Expanded(
      child: RoomBottomBarItem(
        child: const Text('🚪', style: TextStyle(fontSize: 24)),
        title: 'Rời phòng',
        color: Colors.red,
        onTap: onLeave,
      ),
    ),
  ],
),
    );
  }
}

// ─── Bottom Bar Item ──────────────────────────────────────────────────────────

class RoomBottomBarItem extends StatelessWidget {
  final Widget? child;
  final IconData? icon;
  final String title;
  final String? subTitle;
  final int? badge;
  final Color color;
  final VoidCallback? onTap;

  const RoomBottomBarItem({
    super.key,
    this.child,
    this.icon,
    required this.title,
    this.subTitle,
    this.badge,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                child ?? Icon(icon, color: color, size: 28),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                if (subTitle != null)
                  Text(
                    subTitle!,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ),
          if (badge != null)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badge.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}