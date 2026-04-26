import 'package:dovui/pages/level/widgets/banner_ad_slot.dart';
import 'package:dovui/pages/level/widgets/level_card.dart';
import 'package:flutter/material.dart';

class LevelGrid extends StatelessWidget {
  final List levels;
  final Map statuses;
  final ScrollController scrollController;
  final List<List<int>> chunks;
  final bool Function(int, List, Map) isUnlocked;
  final void Function(int) onLevelTap;

  const LevelGrid({
    super.key,
    required this.levels,
    required this.statuses,
    required this.scrollController,
    required this.chunks,
    required this.isUnlocked,
    required this.onLevelTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        const SliverPadding(padding: EdgeInsets.only(top: 8)),
        for (int ci = 0; ci < chunks.length; ci++) ...[
          // ── Grid các màn ──
          SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final levelIndex = chunks[ci][i];
                final level = levels[levelIndex];
                final String status = statuses[level.id]?.status ?? 'default';
                final unlocked = isUnlocked(levelIndex, levels, statuses);

                return LevelCard(
                  index: levelIndex,
                  status: status,
                  isUnlocked: unlocked,
                  onTap: unlocked ? () => onLevelTap(levelIndex) : null,
                );
              },
              childCount: chunks[ci].length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.88,
            ),
          ),

          // ── Banner sau mỗi chunk, trừ chunk cuối ──
          if (ci < chunks.length - 1)
            const SliverToBoxAdapter(child: BannerAdSlot()),

          const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
        ],
        const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
      ],
    );
  }
}