import 'package:flutter/material.dart';

class FaqTile extends StatelessWidget {
  final IconData icon;
  final String question;
  final String answer;

  const FaqTile({
    super.key,
    required this.icon,
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF6C63FF), size: 18),
          ),
          title: Text(
            question,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF1A1A2E),
            ),
          ),
          iconColor: const Color(0xFF6C63FF),
          collapsedIconColor: const Color(0xFF9E9EBD),
          childrenPadding:
              const EdgeInsets.only(left: 16, right: 16, bottom: 14),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F3FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                answer,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF5A5A7A),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}