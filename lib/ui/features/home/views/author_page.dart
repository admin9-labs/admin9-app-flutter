import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_appearance.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../domain/models/article.dart';
import '../../../shared/app_state_controller.dart';

class AuthorPage extends StatelessWidget {
  const AuthorPage({super.key, required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateController>();
    final following = appState.isFollowingSource(article.source);

    return Scaffold(
      appBar: AppBar(title: const Text('媒体号主页')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageX,
          AppSpacing.pageTop,
          AppSpacing.pageX,
          AppSpacing.pageBottom,
        ),
        children: [
          AppCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: Text(
                    article.source.characters.first,
                    style: context.typography.heroTitle.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.source,
                        style: context.typography.sectionTitle,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text('媒体号主页', style: context.typography.feedMeta),
                    ],
                  ),
                ),
                FilledButton.tonal(
                  onPressed: () => appState.toggleFollowSource(article.source),
                  child: Text(following ? '已关注' : '关注'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          Text('代表内容', style: context.typography.sectionTitle),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(article.title, style: context.typography.feedTitleCompact),
                const SizedBox(height: AppSpacing.sm),
                Text(article.summary, style: context.typography.feedMeta),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
