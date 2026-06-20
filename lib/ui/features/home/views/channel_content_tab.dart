import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/top_level_page_scaffold.dart';
import '../../../../domain/models/home_block.dart';
import '../../services/views/services_page.dart';
import 'channel_content_blocks.dart';
import 'channel_visual_theme.dart';

class ChannelContentTab extends StatelessWidget {
  const ChannelContentTab({
    super.key,
    required this.blocks,
    this.now,
    this.emptyTitle,
    this.emptyMessage,
    this.controller,
    this.contentTopPadding = AppSpacing.homeChannelContentTopGap,
    this.immersiveBackground,
    this.contentBackground,
    this.visualTheme = const ChannelVisualTheme(),
  });

  final List<PageBlock> blocks;
  final DateTime? now;
  final String? emptyTitle;
  final String? emptyMessage;
  final ScrollController? controller;
  final double contentTopPadding;
  final ChannelImmersiveBackground? immersiveBackground;
  final ChannelContentBackground? contentBackground;
  final ChannelVisualTheme visualTheme;

  @override
  Widget build(BuildContext context) {
    final effectiveNow = now ?? DateTime.now();
    final renderableBlocks = [...blocks]
      ..removeWhere(
        (block) =>
            !block.enabled ||
            !block.visible ||
            !block.isActiveAt(effectiveNow) ||
            !block.hasRenderablePayload,
      )
      ..sort((a, b) => a.sort.compareTo(b.sort));

    if (renderableBlocks.isEmpty) {
      return _buildEmptyContent();
    }

    final immersiveBackground = this.immersiveBackground;
    if (immersiveBackground != null) {
      return ChannelVisualThemeScope(
        theme: visualTheme,
        child: _buildImmersiveContent(renderableBlocks, immersiveBackground),
      );
    }

    final content = ChannelVisualThemeScope(
      theme: visualTheme,
      child: CustomScrollView(
        key: const Key('channel-content-list'),
        controller: controller,
        slivers: [
          SliverPadding(
            key: const Key('channel-content-padding'),
            padding: EdgeInsets.fromLTRB(
              AppSpacing.pageX,
              contentTopPadding,
              AppSpacing.pageX,
              AppSpacing.bottomNavPagePadding,
            ),
            sliver: SliverList.separated(
              itemCount: renderableBlocks.length,
              separatorBuilder: (_, index) => SizedBox(
                height: _blockGap(
                  renderableBlocks[index],
                  renderableBlocks[index + 1],
                ),
              ),
              itemBuilder: (context, index) =>
                  PageBlockRenderer(block: renderableBlocks[index]),
            ),
          ),
        ],
      ),
    );

    final contentBackground = this.contentBackground;
    if (contentBackground == null) return content;

    return Stack(
      key: const Key('channel-content-background-stack'),
      children: [
        Positioned.fill(child: contentBackground),
        content,
      ],
    );
  }

  Widget _buildEmptyContent() {
    return CustomScrollView(
      key: const Key('channel-content-empty'),
      controller: controller,
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            title: emptyTitle ?? '暂无内容',
            message: emptyMessage ?? '暂无内容',
          ),
        ),
      ],
    );
  }

  Widget _buildImmersiveContent(
    List<PageBlock> renderableBlocks,
    ChannelImmersiveBackground immersiveBackground,
  ) {
    return _ImmersiveChannelContent(
      blocks: renderableBlocks,
      controller: controller,
      contentTopPadding: contentTopPadding,
      immersiveBackground: immersiveBackground,
    );
  }
}

class ChannelImmersiveBackground {
  const ChannelImmersiveBackground({
    required this.surface,
    this.height = AppSpacing.homeImmersiveChannelBackdropHeight,
    this.stretchExtent = AppSpacing.homeImmersiveChannelPullExtent,
  });

  final ResolvedPageSurface surface;
  final double height;
  final double stretchExtent;
}

class ChannelContentBackground extends StatelessWidget {
  const ChannelContentBackground.gradientRelay({
    super.key = const Key('channel-content-gradient-relay'),
    required this.startColor,
    required this.endColor,
    this.height = 220,
  });

  final Color startColor;
  final Color endColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: DecoratedBox(
          key: const Key('channel-content-gradient-relay-fill'),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [startColor, endColor],
            ),
          ),
        ),
      ),
    );
  }
}

class _ImmersiveChannelContent extends StatefulWidget {
  const _ImmersiveChannelContent({
    required this.blocks,
    required this.controller,
    required this.contentTopPadding,
    required this.immersiveBackground,
  });

  final List<PageBlock> blocks;
  final ScrollController? controller;
  final double contentTopPadding;
  final ChannelImmersiveBackground immersiveBackground;

  @override
  State<_ImmersiveChannelContent> createState() =>
      _ImmersiveChannelContentState();
}

class _ImmersiveChannelContentState extends State<_ImmersiveChannelContent> {
  double _stretchOffset = 0;

  @override
  Widget build(BuildContext context) {
    final bg = widget.immersiveBackground;
    final blockCount = widget.blocks.length;

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: CustomScrollView(
        key: const Key('channel-content-list'),
        controller: widget.controller,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ① Immersive backdrop sliver — scrolls naturally with content
          SliverToBoxAdapter(
            key: const Key('home-immersive-channel-backdrop'),
            child: _ImmersiveBackdropView(
              surface: bg.surface,
              height: bg.height,
              stretchOffset: _stretchOffset,
            ),
          ),
          // ② All content blocks as a single sliver list
          SliverPadding(
            key: const Key('channel-content-padding'),
            padding: EdgeInsets.fromLTRB(
              AppSpacing.pageX,
              widget.contentTopPadding,
              AppSpacing.pageX,
              AppSpacing.bottomNavPagePadding,
            ),
            sliver: SliverList.separated(
              itemCount: blockCount,
              separatorBuilder: (_, index) => SizedBox(
                height: _blockGap(
                  widget.blocks[index],
                  widget.blocks[index + 1],
                ),
              ),
              itemBuilder: (context, index) =>
                  PageBlockRenderer(block: widget.blocks[index]),
            ),
          ),
        ],
      ),
    );
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final pixels = notification.metrics.pixels;
      final maxStretch = widget.immersiveBackground.stretchExtent;
      if (pixels < 0) {
        final nextOffset = (-pixels).clamp(0.0, maxStretch);
        if ((nextOffset - _stretchOffset).abs() > 0.5) {
          setState(() => _stretchOffset = nextOffset);
        }
      } else if (_stretchOffset > 0) {
        setState(() => _stretchOffset = 0);
      }
    } else if (notification is ScrollEndNotification) {
      if (_stretchOffset > 0) {
        setState(() => _stretchOffset = 0);
      }
    }
    return false;
  }
}

class _ImmersiveBackdropView extends StatelessWidget {
  const _ImmersiveBackdropView({
    required this.surface,
    required this.height,
    required this.stretchOffset,
  });

  final ResolvedPageSurface surface;
  final double height;
  final double stretchOffset;

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height + stretchOffset;
    return SizedBox(
      key: const Key('home-immersive-channel-backdrop-sized'),
      width: double.infinity,
      height: effectiveHeight,
      child: ClipRect(
        child: PageBackdropView(
          surface: surface,
          height: effectiveHeight,
          debugKeyPrefix: 'home-immersive-channel-backdrop',
        ),
      ),
    );
  }
}

class PageBlockRenderer extends StatelessWidget {
  const PageBlockRenderer({super.key, required this.block});

  final PageBlock block;

  @override
  Widget build(BuildContext context) {
    return switch (block.type) {
      PageBlockType.noticeBar => NoticeBarBlock(
        blockId: block.id,
        config: block.noticeBarConfig,
        items: block.noticeItems,
      ),
      PageBlockType.imageCarousel => ImageCarouselBlock(
        carousel: block.carousel!,
      ),
      PageBlockType.iconNavigation => IconNavigationBlock(
        actions: block.actions,
      ),
      PageBlockType.tileGrid => TileGridBlock(
        title: block.showHeader ? block.displayTitle : null,
        tiles: block.tiles,
      ),
      PageBlockType.mediaShowcase => MediaShowcaseBlock(
        title: block.showHeader ? block.displayTitle : null,
        items: block.mediaItems,
      ),
      PageBlockType.serviceNavigation => const HomeServiceNavigationBlock(),
      PageBlockType.specialEntry => SpecialEntryBlock(
        title: block.showHeader ? block.displayTitle : null,
        entries: block.specialEntries,
      ),
      PageBlockType.specialContentGroup => SpecialContentGroupBlock(
        headerTitle: block.showHeader ? block.displayTitle : null,
        items: block.items,
        surface: block.surface,
      ),
      PageBlockType.contentFeed => ContentFeedBlock(
        headerTitle: block.showHeader ? block.displayTitle : null,
        items: block.items,
        surface: block.surface,
      ),
    };
  }
}

double _blockGap(PageBlock current, PageBlock next) {
  if (current.type == PageBlockType.noticeBar &&
      next.type == PageBlockType.noticeBar) {
    return 2;
  }
  if (current.type == PageBlockType.noticeBar ||
      next.type == PageBlockType.noticeBar) {
    return AppSpacing.sm;
  }
  return AppSpacing.md;
}
