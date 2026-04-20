import 'package:flutter/material.dart';

class MissionDialog extends StatelessWidget {
  final bool canCheckIn;
  final bool videoWatched;
  final VoidCallback? onCheckIn;
  final VoidCallback? onWatchVideo;
  final VoidCallback onClose;

  const MissionDialog({
    super.key,
    required this.canCheckIn,
    required this.videoWatched,
    this.onCheckIn,
    this.onWatchVideo,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "🎯 Nhiệm vụ hàng ngày",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1B4B),
              ),
            ),
            const SizedBox(height: 20),
            MissionRow(
              icon: "📅",
              title: "Điểm danh hàng ngày",
              reward: "+10 ⭐",
              color: const Color(0xFF43C6AC),
              done: !canCheckIn,
              onTap: canCheckIn ? onCheckIn : null,
            ),
            const SizedBox(height: 12),
            MissionRow(
              icon: "🎬",
              title: "Xem video nhận thưởng",
              reward: "+10 ⭐",
              color: const Color(0xFF6C63FF),
              done: videoWatched,
              onTap: videoWatched ? null : onWatchVideo,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onClose,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  "Đóng",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MissionRow extends StatelessWidget {
  final String icon;
  final String title;
  final String reward;
  final Color color;
  final bool done;
  final VoidCallback? onTap;

  const MissionRow({
    super.key,
    required this.icon,
    required this.title,
    required this.reward,
    required this.color,
    required this.done,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: done ? 0.4 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E1B4B),
                  ),
                ),
              ),
              done
                  ? const Text(
                      "✅ Hoàn thành",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        reward,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}