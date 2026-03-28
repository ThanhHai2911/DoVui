import 'package:flutter/material.dart';

class HintBar extends StatelessWidget {
  final VoidCallback onMagnifier;
  final VoidCallback onKey;
  final VoidCallback onVideo;

  const HintBar({
    super.key,
    required this.onMagnifier,
    required this.onKey,
    required this.onVideo,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _HintButton(emoji: '💡', color: Colors.amber, onTap: onMagnifier),
        _HintButton(emoji: '🔑', color: Colors.deepPurple, onTap: onKey),
        _HintButton(emoji: '🎬', color: Colors.red, onTap: onVideo),
      ],
    );
  }
}

class _HintButton extends StatelessWidget {
  final String emoji; // ← dùng emoji thay icon
  final Color color;
  final VoidCallback onTap;

  const _HintButton({
    required this.emoji,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.4), width: 1.5),
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 26)),
      ),
    );
  }
}
