import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ─── Section Label ────────────────────────────────────────────────────────────

class SectionLabel extends StatelessWidget {
  final String label;
  const SectionLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8, color: Colors.grey.shade500),
      ),
    );
  }
}

// ─── Settings Card ────────────────────────────────────────────────────────────

class SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const SettingsCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(children: children),
    );
  }
}

// ─── Divider Line ─────────────────────────────────────────────────────────────

class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(height: 0.5, thickness: 0.5, color: Colors.grey.shade200, indent: 62);
  }
}

// ─── Toggle Row ───────────────────────────────────────────────────────────────

class ToggleRow extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final bool value;
  final Color activeColor;
  final ValueChanged<bool> onChanged;

  const ToggleRow({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _EmojiBox(
            emoji: emoji,
            bgColor: value ? activeColor.withOpacity(0.12) : Colors.grey.withOpacity(0.1),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E1B4B))),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
          CupertinoSwitch(value: value, onChanged: onChanged, activeColor: activeColor),
        ],
      ),
    );
  }
}

// ─── Chevron Row ──────────────────────────────────────────────────────────────

class ChevronRow extends StatelessWidget {
  final String emoji;
  final Color emojiBg;
  final String title;
  final Color? titleColor;
  final String subtitle;
  final Color? chevronColor;
  final VoidCallback onTap;

  const ChevronRow({
    super.key,
    required this.emoji,
    required this.emojiBg,
    required this.title,
    this.titleColor,
    required this.subtitle,
    this.chevronColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            _EmojiBox(emoji: emoji, bgColor: emojiBg),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: titleColor ?? const Color(0xFF1E1B4B)),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: chevronColor ?? Colors.grey.shade400, size: 22),
          ],
        ),
      ),
    );
  }
}

// ─── Confirm Dialog ───────────────────────────────────────────────────────────

class ConfirmActionDialog extends StatelessWidget {
  final String emoji;
  final Color emojiBg;
  final String title;
  final String message;
  final String confirmText;
  final Color confirmColor;
  final VoidCallback onConfirm;

  const ConfirmActionDialog({
    super.key,
    required this.emoji,
    required this.emojiBg,
    required this.title,
    required this.message,
    required this.confirmText,
    required this.confirmColor,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _EmojiBox(emoji: emoji, bgColor: emojiBg, size: 60, radius: 16, fontSize: 28),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B))),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.6),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: confirmColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: onConfirm,
                child: Text(confirmText, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                  foregroundColor: const Color(0xFF1E1B4B),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy bỏ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared Internal ──────────────────────────────────────────────────────────

class _EmojiBox extends StatelessWidget {
  final String emoji;
  final Color bgColor;
  final double size;
  final double radius;
  final double fontSize;

  const _EmojiBox({
    required this.emoji,
    required this.bgColor,
    this.size = 40,
    this.radius = 12,
    this.fontSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(radius)),
      child: Center(child: Text(emoji, style: TextStyle(fontSize: fontSize))),
    );
  }
}