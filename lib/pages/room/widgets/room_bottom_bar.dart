import 'package:flutter/material.dart';

class RoomBottomBar extends StatelessWidget {
  final bool isMicOn;
  final bool isSpeakerOn;
  final bool isHost;
  final bool canStart;
  final bool isReady;
  final VoidCallback onMicToggle;
  final VoidCallback onSpeakerToggle;
  final VoidCallback onMainAction;

  const RoomBottomBar({
    super.key,
    required this.isMicOn,
    required this.isSpeakerOn,
    required this.isHost,
    required this.canStart,
    required this.isReady,
    required this.onMicToggle,
    required this.onSpeakerToggle,
    required this.onMainAction,
  });

  @override
  Widget build(BuildContext context) {
    final String label;
    final List<Color> gradientColors;
    final IconData actionIcon;
    final bool isDisabled;

    if (isHost) {
      isDisabled = !canStart;
      label = canStart ? 'BẮT ĐẦU' : 'Chờ mọi người...';
      gradientColors = canStart
          ? [const Color(0xFF9B6BFF), const Color(0xFFFF6FA3)]
          : [Colors.grey.shade300, Colors.grey.shade300];
      actionIcon = Icons.sports_esports_rounded;
    } else {
      isDisabled = false;
      label = isReady ? 'Đã sẵn sàng' : 'SẴN SÀNG';
      gradientColors = isReady
          ? [const Color(0xFF2ECC71), const Color(0xFF1ABC9C)]
          : [const Color(0xFF7B6EF6), const Color(0xFFFF6FA3)];
      actionIcon =
          isReady ? Icons.check_circle_rounded : Icons.thumb_up_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: [
          _IconBtn(
            icon: isMicOn ? Icons.mic_rounded : Icons.mic_off_rounded,
            isActive: isMicOn,
            onTap: onMicToggle,
          ),
          const SizedBox(width: 4),
          _IconBtn(
            icon: isSpeakerOn
                ? Icons.volume_up_rounded
                : Icons.volume_off_rounded,
            isActive: isSpeakerOn,
            onTap: onSpeakerToggle,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: isDisabled ? null : onMainAction,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: isDisabled
                      ? null
                      : [
                          BoxShadow(
                            color: gradientColors.first.withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(actionIcon, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: isHost && !canStart ? 13 : 16,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _IconBtn({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 52,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFEFEBFF) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          color: isActive ? const Color(0xFF7B6EF6) : Colors.grey.shade400,
          size: 22,
        ),
      ),
    );
  }
}