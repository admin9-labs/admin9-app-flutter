import 'package:flutter/material.dart';

import '../../../../core/theme/app_appearance.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../../domain/models/report_item.dart';
import '../../../../domain/models/user_activity.dart';

class ReportDetailPage extends StatelessWidget {
  const ReportDetailPage({super.key, this.item, this.submission})
    : assert(item != null || submission != null);

  final ReportItem? item;
  final ReportSubmission? submission;

  ReportItem get _item => item ?? submission!.item;
  String get _content => submission?.content ?? _item.content ?? '暂无详情';
  String? get _attachmentSummary {
    final attachments = submission?.attachments ?? const [];
    if (attachments.isEmpty) return null;
    final imageCount = attachments
        .where((item) => item.type == ReportAttachmentType.image)
        .length;
    final videoCount = attachments
        .where((item) => item.type == ReportAttachmentType.video)
        .length;
    final parts = [
      if (imageCount > 0) '$imageCount 张照片',
      if (videoCount > 0) '$videoCount 个视频',
    ];
    return '已提交 ${parts.join('、')}';
  }

  @override
  Widget build(BuildContext context) {
    final statusFlow = const ['已提交', '审核中', '已受理', '已回复', '未通过'];
    final attachmentSummary = _attachmentSummary;

    return Scaffold(
      appBar: AppBar(title: const Text('爆料详情')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageX,
          AppSpacing.pageTop,
          AppSpacing.pageX,
          AppSpacing.pageBottom,
        ),
        children: [
          Text(_item.title, style: context.typography.heroTitle),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              StatusPill(label: _item.status),
              Text(
                '${_item.location} · ${_item.time}',
                style: context.typography.feedMeta,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          AppCard(child: Text(_content, style: context.typography.bodyText)),
          if (attachmentSummary != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              attachmentSummary,
              key: const Key('report-attachment-summary'),
              style: context.typography.feedMeta.copyWith(
                color: context.tokens.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sectionGap),
          Text('处理进度', style: context.typography.sectionTitle),
          const SizedBox(height: AppSpacing.md),
          for (final status in statusFlow) ...[
            AppCard(
              child: Row(
                children: [
                  Icon(
                    status == _item.status
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      status,
                      style: context.typography.feedTitleCompact,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}
