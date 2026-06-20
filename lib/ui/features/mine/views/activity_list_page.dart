import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/theme/app_appearance.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_info_list_item.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../data/repositories/foundation_repository.dart';
import '../../../../domain/models/foundation_models.dart';
import '../../../shared/app_state_controller.dart';
import '../../home/views/channel_content_blocks.dart';
import '../../live/views/live_detail_page.dart';
import '../../report/views/report_detail_page.dart';
import 'feedback_detail_page.dart';

enum ActivityListKind {
  favorites,
  history,
  comments,
  follows,
  reports,
  reservations,
  feedbacks,
  systemMessages,
  interactionMessages,
}

class ActivityListPage extends StatelessWidget {
  const ActivityListPage({super.key, required this.kind});

  final ActivityListKind kind;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateController>();
    final repository = context.read<FoundationRepository>();
    final entries = _entries(context, appState, repository);

    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: SafeArea(
        top: false,
        child: entries.isEmpty
            ? EmptyState(
                key: Key('activity-empty-${kind.name}'),
                title: '暂无$_title',
                icon: _icon,
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageX,
                  AppSpacing.pageTop,
                  AppSpacing.pageX,
                  AppSpacing.pageBottom,
                ),
                itemBuilder: (context, index) => entries[index],
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemCount: entries.length,
              ),
      ),
    );
  }

  String get _title {
    return switch (kind) {
      ActivityListKind.favorites => '我的收藏',
      ActivityListKind.history => '浏览历史',
      ActivityListKind.comments => '我的评论',
      ActivityListKind.follows => '我的关注',
      ActivityListKind.reports => '我的爆料',
      ActivityListKind.reservations => '我的预约',
      ActivityListKind.feedbacks => '反馈记录',
      ActivityListKind.systemMessages => '系统消息',
      ActivityListKind.interactionMessages => '互动消息',
    };
  }

  IconData get _icon {
    return switch (kind) {
      ActivityListKind.favorites => Icons.star_border,
      ActivityListKind.history => Icons.history,
      ActivityListKind.comments => Icons.comment_outlined,
      ActivityListKind.follows => Icons.favorite_border,
      ActivityListKind.reports => Icons.campaign_outlined,
      ActivityListKind.reservations => Icons.notifications_active_outlined,
      ActivityListKind.feedbacks => Icons.feedback_outlined,
      ActivityListKind.systemMessages => Icons.mark_email_unread_outlined,
      ActivityListKind.interactionMessages => Icons.forum_outlined,
    };
  }

  List<Widget> _entries(
    BuildContext context,
    AppStateController appState,
    FoundationRepository repository,
  ) {
    return switch (kind) {
      ActivityListKind.favorites => [
        for (final article in appState.favoriteArticles)
          _activityCard(
            key: Key('favorite-${article.id}'),
            title: article.title,
            subtitle: '${article.source} · ${article.time}',
            icon: Icons.star,
            onTap: () => openArticle(context, article),
          ),
      ],
      ActivityListKind.history => [
        for (final article in appState.history)
          _activityCard(
            key: Key('history-${article.id}'),
            title: article.title,
            subtitle: '${article.source} · ${article.time}',
            icon: Icons.history,
            onTap: () => openArticle(context, article),
          ),
      ],
      ActivityListKind.comments => [
        for (final comment in appState.comments)
          _activityCard(
            key: Key('comment-${comment.id}'),
            title: comment.content,
            subtitle: comment.article.title,
            icon: Icons.comment_outlined,
            onTap: () => openArticle(context, comment.article),
          ),
      ],
      ActivityListKind.follows => [
        for (final source in appState.followedSources)
          _activityCard(
            key: Key('follow-$source'),
            title: source,
            subtitle: '已关注媒体号',
            icon: Icons.favorite,
            onTap: () => AppNavigator.push(
              context,
              _SimpleDetailPage(title: source, body: '$source 媒体号主页'),
            ),
          ),
      ],
      ActivityListKind.reports => [
        for (final report in appState.reports)
          _activityCard(
            key: Key('my-report-${report.item.id}'),
            title: report.item.title,
            subtitle: '${report.item.location} · ${report.item.status}',
            icon: Icons.campaign_outlined,
            onTap: () => AppNavigator.push(
              context,
              ReportDetailPage(submission: report),
            ),
          ),
      ],
      ActivityListKind.reservations => [
        for (final reservation in appState.reservations)
          _activityCard(
            key: Key('reservation-${reservation.program.id}'),
            title: reservation.program.title,
            subtitle: '${reservation.program.time} · ${reservation.time}',
            icon: Icons.notifications_active_outlined,
            onTap: () => AppNavigator.push(
              context,
              LiveDetailPage(program: reservation.program),
            ),
          ),
      ],
      ActivityListKind.feedbacks => [
        for (final feedback in appState.feedbacks)
          _activityCard(
            key: Key('feedback-record-${feedback.id}'),
            title: feedback.content,
            subtitle: '${feedback.status} · ${feedback.time}',
            icon: Icons.feedback_outlined,
            onTap: () => AppNavigator.push(
              context,
              FeedbackDetailPage(record: feedback),
            ),
          ),
      ],
      ActivityListKind.systemMessages => _messageEntries(
        context,
        appState,
        repository.messages
            .where((item) => item.category == MessageCategory.system)
            .toList(),
      ),
      ActivityListKind.interactionMessages => _messageEntries(
        context,
        appState,
        repository.messages
            .where((item) => item.category != MessageCategory.system)
            .toList(),
      ),
    };
  }

  List<Widget> _messageEntries(
    BuildContext context,
    AppStateController appState,
    List<FoundationMessage> messages,
  ) {
    return [
      for (final message in messages)
        _activityCard(
          key: Key('message-${message.id}'),
          title: message.title,
          subtitle: appState.isMessageRead(message.id)
              ? '${message.time} · 已读'
              : '${message.time} · 未读',
          icon: Icons.mark_email_unread_outlined,
          unread: message.unread && !appState.isMessageRead(message.id),
          onTap: () {
            appState.markMessageRead(message.id);
            AppNavigator.push(
              context,
              _SimpleDetailPage(
                title: message.title,
                body: '消息时间：${message.time}',
              ),
            );
          },
        ),
    ];
  }
}

Widget _activityCard({
  required Key key,
  required String title,
  required String subtitle,
  required IconData icon,
  required VoidCallback onTap,
  bool unread = false,
}) {
  return AppInfoListCard(
    key: key,
    icon: icon,
    title: title,
    subtitle: subtitle,
    unread: unread,
    onTap: onTap,
  );
}

class _SimpleDetailPage extends StatelessWidget {
  const _SimpleDetailPage({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.pageX),
        child: Text(body, style: context.typography.bodyText),
      ),
    );
  }
}
