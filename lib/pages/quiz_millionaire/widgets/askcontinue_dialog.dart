import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/millionaire_bloc.dart';
import 'millionaire_colors.dart';

/// Dialog hỏi "Tiếp tục hay dừng?" từ câu 5 trở đi
class AskContinueDialog extends StatelessWidget {
  const AskContinueDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MillionaireBloc, MillionaireState>(
      builder: (context, state) {
        final earnedPts  = kPrizeLevels[(state.currentIndex - 1).clamp(0, 14)];
        final nextPts    = kPrizeLevels[state.currentIndex.clamp(0, 14)];
        final isSafe     = kSafeMilestones.contains(state.currentIndex); // mức an toàn
        final safePts    = state.safePts;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF12043A), Color(0xFF050115)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: MillionaireColors.gold, width: 1.5),
              boxShadow: [
                BoxShadow(
                    color: MillionaireColors.gold.withOpacity(0.35),
                    blurRadius: 40)
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: MillionaireColors.gold.withOpacity(0.12),
                    border: Border.all(color: MillionaireColors.gold, width: 1.5),
                  ),
                  child: const Icon(Icons.emoji_events_rounded,
                      color: MillionaireColors.gold, size: 28),
                ),
                const SizedBox(height: 16),

                const Text(
                  'BẠN ĐÃ ĐẠT ĐƯỢC',
                  style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 3,
                      color: Colors.white54),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatPts(earnedPts),
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    color: MillionaireColors.gold,
                    shadows: [
                      Shadow(color: Color(0x80F5C518), blurRadius: 24)
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                const Text('điểm',
                    style: TextStyle(fontSize: 14, color: Colors.white38)),
                const SizedBox(height: 20),
                const Divider(color: Colors.white12),
                const SizedBox(height: 16),

                // Câu tiếp theo đang chờ
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Câu tiếp theo:',
                          style: TextStyle(fontSize: 14, color: Colors.white54)),
                      Text(
                        _formatPts(nextPts),
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                // Điểm an toàn (nếu có)
                if (safePts > 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CFF8C).withOpacity(0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFF4CFF8C).withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Điểm an toàn:',
                            style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF4CFF8C))),
                        Text(
                          _formatPts(safePts),
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4CFF8C)),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    // Dừng lại
                    Expanded(
                      child: _AskBtn(
                        label: 'Dừng lại',
                        sublabel: 'Giữ ${_formatPts(earnedPts)}đ',
                        primary: false,
                        onTap: () {
                          Navigator.pop(context);
                          context
                              .read<MillionaireBloc>()
                              .add(StopAndTakePrize());
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Tiếp tục
                    Expanded(
                      child: _AskBtn(
                        label: 'Tiếp tục',
                        sublabel: 'Lên ${_formatPts(nextPts)}đ',
                        primary: true,
                        onTap: () {
                          Navigator.pop(context);
                          context
                              .read<MillionaireBloc>()
                              .add(ContinuePlaying());
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatPts(int pts) {
    if (pts >= 1000) {
      return '${(pts / 1000).toStringAsFixed(pts % 1000 == 0 ? 0 : 1)}.000';
    }
    return '$pts';
  }
}

class _AskBtn extends StatelessWidget {
  final String label;
  final String sublabel;
  final bool primary;
  final VoidCallback onTap;

  const _AskBtn({
    required this.label,
    required this.sublabel,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: primary
              ? const LinearGradient(
                  colors: [Color(0xFFB8860B), MillionaireColors.gold])
              : null,
          color: primary ? null : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
          border: primary
              ? null
              : Border.all(color: Colors.white24, width: 1),
        ),
        child: Column(
          children: [
            Text(label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: primary ? const Color(0xFF1A0A0A) : Colors.white,
                )),
            const SizedBox(height: 2),
            Text(sublabel,
                style: TextStyle(
                  fontSize: 12,
                  color: primary
                      ? const Color(0xFF1A0A0A).withOpacity(0.6)
                      : Colors.white38,
                )),
          ],
        ),
      ),
    );
  }
}