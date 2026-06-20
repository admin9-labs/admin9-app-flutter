import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_appearance.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/article_visual.dart';
import '../../../../core/widgets/content_tag_pill.dart';
import '../../../../data/repositories/home_content_repository.dart';
import '../../../../domain/models/article.dart';
import '../../../shared/app_state_controller.dart';
import '../../foundation/views/content_report_page.dart';
import '../../mine/view_models/session_view_model.dart';
import 'author_page.dart';
import 'channel_content_blocks.dart';

class ArticleDetailPage extends StatefulWidget {
  const ArticleDetailPage({super.key, required this.article});

  final Article article;

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  final _commentController = TextEditingController();
  late final List<Article> _sampleComments = [
    Article(
      id: '${widget.article.id}-sample-comment',
      title: '市民留言',
      source: '本地用户',
      time: '10分钟前',
      summary: '这个报道很贴近日常生活，希望继续跟踪。',
      visuals: widget.article.visuals,
      paragraphs: const ['这个报道很贴近日常生活，希望继续跟踪。'],
    ),
  ];

  Article get article => widget.article;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AppStateController>().addHistory(article);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateController>();
    final favorite = appState.isFavoriteArticle(article.id);
    final liked = appState.isLikedArticle(article.id);
    final following = appState.isFollowingSource(article.source);
    final comments = appState.commentsForArticle(article.id);
    final recommendations = context
        .read<HomeContentRepository>()
        .allArticles
        .where((item) => item.id != article.id)
        .take(3)
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(article.isVideo ? '视频详情' : '文章详情'),
        actions: [
          IconButton(
            tooltip: '收藏',
            onPressed: () => _guardLogin(
              context,
              () => appState.toggleFavoriteArticle(article),
            ),
            icon: Icon(favorite ? Icons.bookmark : Icons.bookmark_border),
          ),
          IconButton(
            tooltip: '分享',
            onPressed: () => _toast(context, '分享暂不可用'),
            icon: const Icon(Icons.ios_share),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageX,
          AppSpacing.md,
          AppSpacing.pageX,
          AppSpacing.pageBottom,
        ),
        children: [
          Text(
            article.title,
            style: context.typography.heroTitle.copyWith(height: 1.35),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (article.contentTag != null)
                ContentTagPill(tag: article.contentTag!),
              Text(
                '${article.source} · ${article.time}',
                style: context.typography.feedMeta,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ArticleVisual(
            label: article.primaryVisual.label,
            type: article.primaryVisual.type,
            height: AppMediaSize.heroHeight,
            showPlay: article.isVideo,
            duration: article.isVideo ? article.duration : null,
            imageUrl: article.primaryVisual.imageUrl,
          ),
          if (article.isVideo) ...[
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Row(
                children: [
                  const Icon(Icons.play_circle_fill, size: AppIconSize.empty),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      '视频暂不可播放',
                      style: context.typography.feedTitleCompact,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _guardLogin(
                    context,
                    () => appState.toggleLikeArticle(article),
                  ),
                  icon: Icon(liked ? Icons.thumb_up : Icons.thumb_up_outlined),
                  label: Text(liked ? '已点赞' : '点赞'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _guardLogin(
                    context,
                    () => appState.toggleFollowSource(article.source),
                  ),
                  icon: Icon(
                    following ? Icons.favorite : Icons.favorite_border,
                  ),
                  label: Text(following ? '已关注' : '关注'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => AuthorPage(article: article)),
            ),
            child: Row(
              children: [
                CircleAvatar(child: Text(article.source.characters.first)),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    article.source,
                    style: context.typography.feedTitleCompact,
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(article.summary, style: context.typography.feedSummary),
          const SizedBox(height: AppSpacing.lg),
          for (final paragraph in article.paragraphs) ...[
            Text(paragraph, style: context.typography.bodyText),
            const SizedBox(height: AppSpacing.sectionGap),
          ],
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ContentReportPage(article: article),
                  ),
                ),
                icon: const Icon(Icons.flag_outlined),
                label: const Text('举报'),
              ),
              TextButton.icon(
                onPressed: () => _toast(context, '分享暂不可用'),
                icon: const Icon(Icons.ios_share),
                label: const Text('分享'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          Text('评论', style: context.typography.sectionTitle),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            key: const Key('comment-input'),
            controller: _commentController,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _guardLogin(context, _submitComment),
            decoration: InputDecoration(
              hintText: '说点什么...',
              suffixIcon: TextButton(
                key: const Key('submit-comment'),
                onPressed: () => _guardLogin(context, _submitComment),
                child: const Text('发送'),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final comment in comments) ...[
            AppCard(
              key: Key('comment-card-${comment.id}'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment.content,
                    style: context.typography.feedTitleCompact,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '我 · ${comment.time}',
                          style: context.typography.feedMeta,
                        ),
                      ),
                      TextButton(
                        onPressed: () => appState.toggleCommentLike(comment.id),
                        child: Text(comment.liked ? '已赞' : '点赞'),
                      ),
                      TextButton(
                        onPressed: () => _toast(context, '举报已提交'),
                        child: const Text('举报'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          for (final comment in _sampleComments) ...[
            AppCard(
              child: Text(
                comment.summary,
                style: context.typography.feedTitleCompact,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          const SizedBox(height: AppSpacing.sectionGap),
          Text('相关推荐', style: context.typography.sectionTitle),
          const SizedBox(height: AppSpacing.sm),
          for (final item in recommendations) ...[
            AppCard(
              onTap: () => openArticle(context, item),
              child: Text(
                item.title,
                style: context.typography.feedTitleCompact,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    context.read<AppStateController>().addComment(article, text);
    _commentController.clear();
  }

  void _guardLogin(BuildContext context, VoidCallback action) {
    final session = context.read<SessionViewModel>();
    if (!session.isLoggedIn) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先登录')));
      return;
    }
    action();
  }

  void _toast(BuildContext context, String message) {
    showAppSnackBar(context, message);
  }
}
