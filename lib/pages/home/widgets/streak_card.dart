import 'package:dovui/resources/color_manager.dart';
import 'package:flutter/material.dart';

class StreakCard extends StatefulWidget {
  final int days;
  final String name;
  final int score;

  const StreakCard({
    super.key,
    required this.days,
    required this.name,
    required this.score,
  });

  @override
  State<StreakCard> createState() => _StreakCardState();
}

class _StreakCardState extends State<StreakCard>
    with SingleTickerProviderStateMixin {

  late AnimationController _floatCtrl;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _floatAnim = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    double progress = (widget.days % 365) / 365;

    return TweenAnimationBuilder(
      tween: Tween(begin: 0.95, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: [
              ColorManager.primaryDark,
              ColorManager.primaryDark.withOpacity(0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: ColorManager.primaryDark.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Stack(
          children: [

            /// blob decoration
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// HEADER
                Row(
                  children: [

                    AnimatedBuilder(
                      animation: _floatAnim,
                      builder: (_, child) {
                        return Transform.translate(
                          offset: Offset(0, _floatAnim.value),
                          child: child,
                        );
                      },
                      child: const Text(
                        "🔥",
                        style: TextStyle(fontSize: 28),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        "Đã trải nghiệm ${widget.days} ngày",
                        style: TextStyle(
                          color: ColorManager.cardColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                /// SCORE
                Text(
                  "⭐ Số sao của bạn: ${widget.score}",
                  style: TextStyle(color: ColorManager.textWhite),
                ),

                const SizedBox(height: 18),

                /// PROGRESS
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: TweenAnimationBuilder(
                    tween: Tween(begin: 0.0, end: progress),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (_, value, __) {
                      return LinearProgressIndicator(
                        value: value,
                        minHeight: 8,
                        backgroundColor: ColorManager.backgroundthanh,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          ColorManager.mauthanh,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "${(progress * 100).toStringAsFixed(0)}% hành trình năm",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

