import 'package:flutter/material.dart';

import '../../../../core/theme/app_appearance.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../domain/models/user_activity.dart';

class FeedbackDetailPage extends StatelessWidget {
  const FeedbackDetailPage({super.key, required this.record});

  final FeedbackRecord record;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('反馈详情')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageX,
          AppSpacing.pageTop,
          AppSpacing.pageX,
          AppSpacing.pageBottom,
        ),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.content,
                  style: context.typography.feedTitleCompact,
                ),
                const SizedBox(height: 8),
                Text(
                  '${record.status} · ${record.time}',
                  style: context.typography.feedMeta,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          AppCard(
            child: Text(
              record.reply ?? '暂无回复',
              style: context.typography.bodyText,
            ),
          ),
        ],
      ),
    );
  }
}
