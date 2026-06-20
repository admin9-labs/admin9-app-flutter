import 'package:flutter/material.dart';

import '../../../../core/theme/app_appearance.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../../domain/models/live_program.dart';

class InteractiveLiveDetailPage extends StatelessWidget {
  const InteractiveLiveDetailPage({super.key, required this.item});

  final InteractiveLiveItem item;

  @override
  Widget build(BuildContext context) {
    final color = Color(item.accentColor);

    return Scaffold(
      key: const Key('interactive-live-detail-page'),
      appBar: AppBar(title: Text(item.source)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageX,
          AppSpacing.pageTop,
          AppSpacing.pageX,
          AppSpacing.pageBottom,
        ),
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color,
                      color.withValues(alpha: 0.58),
                      Colors.black87,
                    ],
                  ),
                ),
                child: Padding(
                  padding: AppInsets.section,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StatusPill(
                        label: item.label,
                        color: Colors.black.withValues(alpha: 0.42),
                        foregroundColor: Colors.white,
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.play_circle_fill_rounded,
                        color: Colors.white,
                        size: 58,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(item.title, style: context.typography.heroTitle),
          const SizedBox(height: AppSpacing.sm),
          Text(item.source, style: context.typography.feedMeta),
          const SizedBox(height: AppSpacing.xxl),
          AppCard(
            key: const Key('interactive-live-summary-card'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('互动摘要', style: context.typography.sectionTitle),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  item.kind == LivePlaybackKind.live
                      ? '当前直播正在进行，进入后可参与实时互动与评论。'
                      : '该直播已生成回看，保留精彩片段和评论互动记录。',
                  style: context.typography.feedSummary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
