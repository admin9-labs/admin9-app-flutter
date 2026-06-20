import 'package:flutter/material.dart';

import '../../domain/models/article.dart';
import '../theme/app_appearance.dart';
import '../theme/app_spacing.dart';
import 'app_card.dart';
import 'content_tag_pill.dart';
import 'media_cover.dart';

enum NewsFeedLayout { text, sideImage, largeImage, imageGrid }

class NewsFeedItem extends StatelessWidget {
  const NewsFeedItem({
    super.key,
    required this.article,
    required this.onTap,
    this.layout = NewsFeedLayout.text,
    this.carded = false,
    this.imageGridKey,
    this.tagAccentColor,
    this.cardBackgroundColor,
  });

  final Article article;
  final VoidCallback onTap;
  final NewsFeedLayout layout;
  final bool carded;
  final Key? imageGridKey;
  final Color? tagAccentColor;
  final Color? cardBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final child = switch (layout) {
      NewsFeedLayout.text => _TextArticle(
        article: article,
        tagAccentColor: tagAccentColor,
      ),
      NewsFeedLayout.sideImage => _SideImageArticle(
        article: article,
        tagAccentColor: tagAccentColor,
      ),
      NewsFeedLayout.largeImage => _LargeImageArticle(
        article: article,
        tagAccentColor: tagAccentColor,
      ),
      NewsFeedLayout.imageGrid => _ImageGridArticle(
        article: article,
        imageGridKey: imageGridKey,
        tagAccentColor: tagAccentColor,
      ),
    };

    if (carded) {
      return AppCard(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        onTap: onTap,
        backgroundColor: cardBackgroundColor,
        child: child,
      );
    }

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: child,
      ),
    );
  }
}

class _TextArticle extends StatelessWidget {
  const _TextArticle({required this.article, this.tagAccentColor});

  final Article article;
  final Color? tagAccentColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ArticleTitle(article: article),
        const SizedBox(height: AppSpacing.sm),
        _ArticleMeta(article: article, tagAccentColor: tagAccentColor),
      ],
    );
  }
}

class _SideImageArticle extends StatelessWidget {
  const _SideImageArticle({required this.article, this.tagAccentColor});

  final Article article;
  final Color? tagAccentColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compactWidth = constraints.maxWidth < 300;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(
                height: AppMediaSize.feedSideHeight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ArticleTitle(
                      article: article,
                      maxLines: compactWidth ? 2 : 3,
                    ),
                    const Spacer(),
                    _ArticleMeta(
                      article: article,
                      tagAccentColor: tagAccentColor,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            MediaCover(
              label: article.primaryVisual.label,
              type: article.primaryVisual.type,
              width: AppMediaSize.feedSideWidth,
              height: AppMediaSize.feedSideHeight,
              compact: true,
              showPlay: article.isVideo,
              duration: article.isVideo ? article.duration : null,
              imageUrl: article.primaryVisual.imageUrl,
              borderRadius: AppRadius.input,
            ),
          ],
        );
      },
    );
  }
}

class _LargeImageArticle extends StatelessWidget {
  const _LargeImageArticle({required this.article, this.tagAccentColor});

  final Article article;
  final Color? tagAccentColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ArticleTitle(article: article, maxLines: 2),
        const SizedBox(height: AppSpacing.sm),
        MediaCover(
          label: article.primaryVisual.label,
          type: article.primaryVisual.type,
          height: AppMediaSize.feedLargeHeight,
          showPlay: article.isVideo,
          duration: article.isVideo ? article.duration : null,
          imageUrl: article.primaryVisual.imageUrl,
          borderRadius: AppRadius.input,
        ),
        const SizedBox(height: AppSpacing.sm),
        _ArticleMeta(article: article, tagAccentColor: tagAccentColor),
      ],
    );
  }
}

class _ImageGridArticle extends StatelessWidget {
  const _ImageGridArticle({
    required this.article,
    this.imageGridKey,
    this.tagAccentColor,
  });

  final Article article;
  final Key? imageGridKey;
  final Color? tagAccentColor;

  @override
  Widget build(BuildContext context) {
    final visuals = article.visuals.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ArticleTitle(article: article, maxLines: 2),
        const SizedBox(height: AppSpacing.sm),
        Row(
          key: imageGridKey,
          children: [
            for (var index = 0; index < visuals.length; index++) ...[
              Expanded(
                child: MediaCover(
                  label: visuals[index].label,
                  type: visuals[index].type,
                  height: AppMediaSize.feedGridHeight,
                  compact: true,
                  imageUrl: visuals[index].imageUrl,
                  borderRadius: AppRadius.input,
                ),
              ),
              if (index != visuals.length - 1)
                const SizedBox(width: AppSpacing.sm),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _ArticleMeta(article: article, tagAccentColor: tagAccentColor),
      ],
    );
  }
}

class _ArticleTitle extends StatelessWidget {
  const _ArticleTitle({required this.article, this.maxLines = 3});

  final Article article;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Text(
      article.title,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: context.typography.feedTitle,
    );
  }
}

class _ArticleMeta extends StatelessWidget {
  const _ArticleMeta({required this.article, this.tagAccentColor});

  final Article article;
  final Color? tagAccentColor;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (article.contentTag != null)
          ContentTagPill(tag: article.contentTag!, accentColor: tagAccentColor),
        Text(
          article.time,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.typography.feedMeta,
        ),
      ],
    );
  }
}
