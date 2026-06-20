import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_appearance.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/article_visual.dart';
import '../../../../core/widgets/in_app_web_page.dart';
import '../../../../core/widgets/media_badge.dart';
import '../../../../core/widgets/news_feed_item.dart';
import '../../../../core/widgets/quick_action_grid.dart';
import '../../../../domain/models/article.dart';
import '../../../../domain/models/home_block.dart';
import '../../../../data/repositories/home_content_repository.dart';
import '../../../../data/repositories/live_repository.dart';
import '../../../../data/repositories/service_repository.dart';
import '../../live/views/live_detail_page.dart';
import '../../report/views/report_form_page.dart';
import '../../services/views/services_page.dart';
import 'article_detail_page.dart';
import 'channel_visual_theme.dart';

class NoticeBarBlock extends StatefulWidget {
  const NoticeBarBlock({
    super.key,
    required this.items,
    this.config = const NoticeBarConfig(),
    this.blockId,
  });

  final List<NoticeItem> items;
  final NoticeBarConfig config;
  final String? blockId;

  @override
  State<NoticeBarBlock> createState() => _NoticeBarBlockState();
}

class _NoticeBarBlockState extends State<NoticeBarBlock> {
  static const _bullet = '\u2022';

  late final PageController _controller;
  Timer? _timer;
  var _index = 0;

  List<NoticeItem> get _sortedItems {
    final items = [...widget.items]
      ..sort((a, b) {
        final sortCompare = a.sort.compareTo(b.sort);
        return sortCompare == 0 ? a.id.compareTo(b.id) : sortCompare;
      });
    return items;
  }

  Duration get _interval {
    return Duration(milliseconds: widget.config.intervalMs);
  }

  bool get _shouldLoop {
    return widget.config.loop && _sortedItems.length > 1;
  }

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleNextTick());
  }

  @override
  void didUpdateWidget(covariant NoticeBarBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_index >= _sortedItems.length) {
      _index = 0;
      if (_controller.hasClients) {
        _controller.jumpToPage(0);
      }
    }
    if (oldWidget.config.intervalMs != widget.config.intervalMs ||
        oldWidget.config.loop != widget.config.loop ||
        oldWidget.items.length != widget.items.length) {
      _timer?.cancel();
      WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleNextTick());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _scheduleNextTick() {
    _timer?.cancel();
    if (!_shouldLoop || !mounted) return;

    _timer = Timer(_interval, () async {
      if (!_shouldLoop || !mounted || !_controller.hasClients) return;
      final nextIndex = (_index + 1) % _sortedItems.length;
      await _controller.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
      if (!mounted) return;
      setState(() => _index = nextIndex);
      _scheduleNextTick();
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = _sortedItems;
    if (items.isEmpty) return const SizedBox.shrink();

    final tokens = context.tokens;
    final typography = context.typography;

    return DecoratedBox(
      key: Key('notice-bar-block-${widget.blockId ?? 'default'}'),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: SizedBox(
        height: 30,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _bullet,
              style: typography.feedTitle.copyWith(
                color: tokens.textPrimary,
                fontSize: 17 * tokens.fontScale,
                height: 1.1,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: PageView.builder(
                key: Key('notice-bar-ticker-${widget.blockId ?? 'default'}'),
                controller: _controller,
                scrollDirection: Axis.vertical,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                onPageChanged: (index) => setState(() => _index = index),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item.title,
                      key: Key('notice-item-${item.id}'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.feedTitle.copyWith(
                        color: tokens.textPrimary,
                        fontSize: 17 * tokens.fontScale,
                        fontWeight: FontWeight.w400,
                        height: 1.28,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SpecialEntryBlock extends StatelessWidget {
  const SpecialEntryBlock({
    super.key,
    this.title,
    required this.entries,
    this.webPageBuilder,
  });

  final String? title;
  final List<SpecialEntryItem> entries;
  final Widget Function(String title, String url)? webPageBuilder;

  @override
  Widget build(BuildContext context) {
    final normalizedTitle = title?.trim();

    return SpecialEntryCarousel(
      key: const Key('special-entry-block'),
      title: normalizedTitle,
      entries: entries,
      webPageBuilder: webPageBuilder,
    );
  }
}

class SpecialEntryCarousel extends StatefulWidget {
  const SpecialEntryCarousel({
    super.key,
    this.title,
    required this.entries,
    this.webPageBuilder,
  });

  final String? title;
  final List<SpecialEntryItem> entries;
  final Widget Function(String title, String url)? webPageBuilder;

  @override
  State<SpecialEntryCarousel> createState() => _SpecialEntryCarouselState();
}

class _SpecialEntryCarouselState extends State<SpecialEntryCarousel> {
  static const _carouselHeight = 72.0;
  static const _pageDuration = Duration(milliseconds: 280);
  static const _autoInterval = Duration(seconds: 3);

  Timer? _timer;
  Offset? _pointerStart;
  var _pointerSwipeHandled = false;
  var _index = 0;
  var _slideDirection = 1;

  List<SpecialEntryItem> get _items {
    return widget.entries.take(5).toList(growable: false);
  }

  bool get _shouldAutoplay => _items.length > 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleNextTick());
  }

  @override
  void didUpdateWidget(covariant SpecialEntryCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_index >= _items.length) {
      _index = 0;
    }
    if (oldWidget.entries.length != widget.entries.length) {
      _timer?.cancel();
      WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleNextTick());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _showIndex(int nextIndex, {required int direction}) {
    _timer?.cancel();
    if (nextIndex == _index) {
      _scheduleNextTick();
      return;
    }

    setState(() {
      _slideDirection = direction;
      _index = nextIndex;
    });
    _scheduleNextTick();
  }

  void _showRelative(int direction) {
    if (_items.length < 2) return;
    final nextIndex = (_index + direction) % _items.length;
    _showIndex(
      nextIndex < 0 ? _items.length - 1 : nextIndex,
      direction: direction,
    );
  }

  void _scheduleNextTick() {
    _timer?.cancel();
    if (!mounted || !_shouldAutoplay) return;

    _timer = Timer(_autoInterval, () {
      if (!mounted || !_shouldAutoplay) return;
      _showRelative(1);
    });
  }

  void _handleTap(BuildContext context) {
    final items = _items;
    final entry = items.isEmpty
        ? null
        : items[_index < items.length ? _index : 0];
    final targetUrl = entry?.targetUrl;
    if (entry == null) return;
    if (targetUrl != null && targetUrl.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              widget.webPageBuilder?.call(entry.title, targetUrl) ??
              InAppWebPage(title: entry.title, url: targetUrl),
        ),
      );
      return;
    }
    _openLegacySpecialEntry(context, entry);
  }

  void _handlePointerDown(PointerDownEvent event) {
    _pointerStart = event.position;
    _pointerSwipeHandled = false;
  }

  void _handlePointerMove(PointerMoveEvent event) {
    final start = _pointerStart;
    if (start == null || _pointerSwipeHandled || _items.length < 2) return;

    final delta = event.position - start;
    final verticalDistance = delta.dy.abs();
    if (verticalDistance < 32 || verticalDistance <= delta.dx.abs()) return;

    _pointerSwipeHandled = true;
    _showRelative(delta.dy < 0 ? 1 : -1);
  }

  void _handlePointerUp(PointerUpEvent event) {
    final start = _pointerStart;
    _pointerStart = null;
    if (_pointerSwipeHandled) {
      _pointerSwipeHandled = false;
      return;
    }
    if (start == null || _items.length < 2) return;

    final delta = event.position - start;
    final verticalDistance = delta.dy.abs();
    if (verticalDistance < 24 || verticalDistance <= delta.dx.abs()) return;

    _showRelative(delta.dy < 0 ? 1 : -1);
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    _pointerStart = null;
    _pointerSwipeHandled = false;
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    if (items.isEmpty) {
      return const SizedBox.shrink(key: Key('special-entry-empty'));
    }

    final title = widget.title;
    final entry = items[_index < items.length ? _index : 0];
    final semanticLabel =
        '专题入口：${entry.title}，第 ${_index + 1} 个，共 ${items.length} 个，双击打开';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null && title.isNotEmpty) ...[
          Text(title, style: context.typography.sectionTitle),
          const SizedBox(height: AppSpacing.md),
        ],
        SizedBox(
          key: const Key('special-entry-carousel'),
          height: _carouselHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.input),
            child: Listener(
              onPointerDown: _handlePointerDown,
              onPointerMove: _handlePointerMove,
              onPointerUp: _handlePointerUp,
              onPointerCancel: _handlePointerCancel,
              child: Semantics(
                button: true,
                label: semanticLabel,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _handleTap(context),
                  child: AnimatedSwitcher(
                    key: const Key('special-entry-animated-switcher'),
                    duration: _pageDuration,
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeOutCubic,
                    transitionBuilder: (child, animation) {
                      final position = Tween<Offset>(
                        begin: Offset(0, _slideDirection >= 0 ? 1 : -1),
                        end: Offset.zero,
                      ).animate(animation);
                      return SlideTransition(position: position, child: child);
                    },
                    child: _SpecialEntrySlide(
                      key: ValueKey(entry.id),
                      entry: entry,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SpecialEntrySlide extends StatelessWidget {
  const _SpecialEntrySlide({super.key, required this.entry});

  final SpecialEntryItem entry;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ArticleVisual(
          label: entry.visual.label,
          type: entry.visual.type,
          height: 72,
          imageUrl: entry.visual.imageUrl,
          showLabel: false,
          showPlay: false,
        ),
      ],
    );
  }
}

void _openLegacySpecialEntry(BuildContext context, SpecialEntryItem entry) {
  final article = const HomeContentRepository().articleById(
    entry.id == 'correct-performance'
        ? 'politics-service-meeting'
        : 'city-update',
  );
  if (article != null) openArticle(context, article);
}

class ImageCarouselBlock extends StatefulWidget {
  const ImageCarouselBlock({super.key, required this.carousel});

  final ImageCarousel carousel;

  @override
  State<ImageCarouselBlock> createState() => _ImageCarouselBlockState();
}

class _ImageCarouselBlockState extends State<ImageCarouselBlock> {
  final _controller = PageController();
  var _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.carousel.items;

    return SizedBox(
      key: const Key('carousel-block'),
      height: AppMediaSize.carouselHeight,
      child: Stack(
        children: [
          PageView.builder(
            key: const Key('carousel-page-view'),
            controller: _controller,
            itemCount: items.length,
            onPageChanged: (index) => setState(() => _index = index),
            itemBuilder: (context, index) {
              final item = items[index];
              return InkWell(
                onTap: () {
                  final article = const HomeContentRepository().articleById(
                    item.id,
                  );
                  if (article != null) openArticle(context, article);
                },
                child: _CarouselItem(
                  item: item,
                  titlePlacement: widget.carousel.titlePlacement,
                ),
              );
            },
          ),
          Positioned(
            right: _indicatorRight(widget.carousel.indicatorPosition),
            left: _indicatorLeft(widget.carousel.indicatorPosition),
            bottom: 12,
            child: Align(
              alignment: _indicatorAlignment(widget.carousel.indicatorPosition),
              child: _CarouselIndicator(
                style: widget.carousel.indicatorStyle,
                current: _index,
                total: items.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double? _indicatorRight(CarouselIndicatorPosition position) {
    return position == CarouselIndicatorPosition.bottomRight ? 12 : null;
  }

  double? _indicatorLeft(CarouselIndicatorPosition position) {
    return position == CarouselIndicatorPosition.bottomLeft ? 12 : null;
  }

  Alignment _indicatorAlignment(CarouselIndicatorPosition position) {
    return switch (position) {
      CarouselIndicatorPosition.bottomCenter => Alignment.bottomCenter,
      CarouselIndicatorPosition.bottomRight => Alignment.bottomRight,
      CarouselIndicatorPosition.bottomLeft => Alignment.bottomLeft,
    };
  }
}

class _CarouselItem extends StatelessWidget {
  const _CarouselItem({required this.item, required this.titlePlacement});

  final ImageCarouselItem item;
  final CarouselTitlePlacement titlePlacement;

  @override
  Widget build(BuildContext context) {
    final showOverlayTitle = titlePlacement == CarouselTitlePlacement.overlay;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.input),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ArticleVisual(
            label: item.visual.label,
            type: item.visual.type,
            height: AppMediaSize.carouselHeight,
            imageUrl: item.visual.imageUrl,
            showLabel: false,
          ),
          if (showOverlayTitle)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.72),
                    ],
                  ),
                ),
              ),
            ),
          if (showOverlayTitle)
            Positioned(
              left: AppSpacing.lg,
              right: 68,
              bottom: AppSpacing.md,
              child: Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.typography.coverTitle.copyWith(
                  color: Colors.white,
                  fontSize: 20 * context.tokens.fontScale,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CarouselIndicator extends StatelessWidget {
  const _CarouselIndicator({
    required this.style,
    required this.current,
    required this.total,
  });

  final CarouselIndicatorStyle style;
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return switch (style) {
      CarouselIndicatorStyle.number => DecoratedBox(
        key: const Key('carousel-number-indicator'),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.42),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Padding(
          padding: AppInsets.chip,
          child: Text(
            '${current + 1}/$total',
            style: TextStyle(
              color: Colors.white,
              fontSize: context.typography.label.fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      CarouselIndicatorStyle.dots => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < total; i++)
            Container(
              width: i == current ? 14 : 5,
              height: 5,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: i == current ? 0.95 : 0.55,
                ),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
        ],
      ),
      CarouselIndicatorStyle.line => Container(
        width: 38,
        height: 4,
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.38),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: FractionallySizedBox(
          widthFactor: total == 0 ? 0 : (current + 1) / total,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
        ),
      ),
    };
  }
}

class IconNavigationBlock extends StatelessWidget {
  const IconNavigationBlock({super.key, required this.actions});

  final List<PageAction> actions;

  @override
  Widget build(BuildContext context) {
    return QuickActionSection(
      title: null,
      cardPadding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      cardRadius: AppRadius.input,
      showCardBorder: false,
      gridKey: const Key('quick-action-grid-icon-navigation'),
      items: _pageActionQuickItems(context, actions),
      maxColumns: 5,
      maxItems: 5,
      shrinkToItemCount: true,
    );
  }
}

class TileGridBlock extends StatelessWidget {
  const TileGridBlock({super.key, this.title, required this.tiles});

  final String? title;
  final List<TileGridItem> tiles;

  @override
  Widget build(BuildContext context) {
    final normalizedTitle = title?.trim();

    return AppCard(
      key: const Key('tile-grid-block'),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      radius: AppRadius.input,
      showBorder: false,
      backgroundColor: _channelCardSurfaceColor(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (normalizedTitle != null && normalizedTitle.isNotEmpty) ...[
            AppSectionHeader(title: normalizedTitle, dense: true),
            const SizedBox(height: AppSpacing.md),
          ],
          GridView.builder(
            key: const Key('tile-grid-fixed-template'),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tiles.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _tileGridColumnCount(tiles.length),
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: _tileGridAspectRatio(tiles.length),
            ),
            itemBuilder: (context, index) => _TileGridEntry(tile: tiles[index]),
          ),
        ],
      ),
    );
  }
}

int _tileGridColumnCount(int itemCount) {
  if (itemCount <= 0) return 1;
  if (itemCount == 2 || itemCount == 4) return 2;
  return 3;
}

double _tileGridAspectRatio(int itemCount) {
  return _tileGridColumnCount(itemCount) == 2 ? 1.42 : 1.18;
}

class _TileGridEntry extends StatelessWidget {
  const _TileGridEntry({required this.tile});

  final TileGridItem tile;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openTile(context, tile.id),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.media),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ArticleVisual(
              label: tile.visual.label,
              type: tile.visual.type,
              height: 96,
              compact: true,
              imageUrl: tile.visual.imageUrl,
              showLabel: false,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.48),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: Text(
                tile.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.typography.actionLabel.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (tile.badge != null)
              Positioned(
                right: 6,
                top: 6,
                child: MediaBadge(
                  label: tile.badge!,
                  color: context.tokens.danger,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class MediaShowcaseBlock extends StatelessWidget {
  const MediaShowcaseBlock({super.key, this.title, required this.items});

  final String? title;
  final List<MediaShowcaseItem> items;

  @override
  Widget build(BuildContext context) {
    final normalizedTitle = title?.trim();
    if (items.isEmpty) {
      return const SizedBox.shrink(key: Key('media-showcase-empty'));
    }

    final mainItem = items.first;
    final secondaryItems = items.skip(1).toList();

    return AppCard(
      key: const Key('media-showcase-block'),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      radius: AppRadius.input,
      showBorder: false,
      backgroundColor: _channelCardSurfaceColor(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (normalizedTitle != null && normalizedTitle.isNotEmpty) ...[
            AppSectionHeader(title: normalizedTitle, dense: true),
            const SizedBox(height: AppSpacing.md),
          ],
          InkWell(
            onTap: () => _openMedia(context, mainItem.id),
            child: ArticleVisual(
              label: mainItem.visual.label,
              type: mainItem.visual.type,
              height: 168,
              showPlay: true,
              duration: mainItem.durationText,
              imageUrl: mainItem.visual.imageUrl,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          MediaBadge(
            label: _mediaShowcaseLabel(mainItem),
            color: _channelAccentColor(context) ?? context.tokens.brand.primary,
            foregroundColor: Colors.white,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            mainItem.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.typography.feedTitle.copyWith(
              fontSize: 18 * context.tokens.fontScale,
            ),
          ),
          if (secondaryItems.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                for (var i = 0; i < secondaryItems.length; i++) ...[
                  Expanded(child: _MediaThumb(item: secondaryItems[i])),
                  if (i != secondaryItems.length - 1)
                    const SizedBox(width: AppSpacing.sm),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MediaThumb extends StatelessWidget {
  const _MediaThumb({required this.item});

  final MediaShowcaseItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openMedia(context, item.id),
      child: Row(
        children: [
          Stack(
            children: [
              ArticleVisual(
                label: item.visual.label,
                type: item.visual.type,
                height: 58,
                width: 84,
                compact: true,
                showPlay: true,
                duration: item.durationText,
                imageUrl: item.visual.imageUrl,
                showLabel: false,
              ),
              Positioned(
                left: 5,
                top: 5,
                child: MediaBadge(
                  label: _mediaShowcaseLabel(item),
                  color: context.tokens.videoScrim,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.typography.feedTitleCompact,
            ),
          ),
        ],
      ),
    );
  }
}

String _mediaShowcaseLabel(MediaShowcaseItem item) {
  final badge = item.badge?.trim();
  if (badge != null && badge.isNotEmpty) return badge;

  return switch (item.kind) {
    MediaKind.video => '视频',
    MediaKind.live => '直播',
    MediaKind.replay => '回放',
  };
}

class ContentFeedBlock extends StatelessWidget {
  const ContentFeedBlock({
    super.key,
    this.headerTitle,
    required this.items,
    this.surface = SurfaceStyle.plain,
  });

  final String? headerTitle;
  final List<ContentItem> items;
  final SurfaceStyle surface;

  @override
  Widget build(BuildContext context) {
    final normalizedTitle = headerTitle?.trim();
    final renderableItems = items.where((item) => item.isRenderable).toList();

    final content = Column(
      key: const Key('content-feed-block'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (normalizedTitle != null && normalizedTitle.isNotEmpty) ...[
          Text(normalizedTitle, style: context.typography.sectionTitle),
          const SizedBox(height: AppSpacing.md),
        ],
        for (final item in renderableItems) ...[
          ContentFeedItemRenderer(item: item),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );

    return _SurfaceShell(surface: surface, child: content);
  }
}

class SpecialContentGroupBlock extends ContentFeedBlock {
  const SpecialContentGroupBlock({
    super.key,
    super.headerTitle,
    required super.items,
    super.surface,
  });
}

class ContentFeedItemRenderer extends StatelessWidget {
  const ContentFeedItemRenderer({super.key, required this.item});

  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    return switch (item.layout) {
      ContentItemLayout.text => _TextContentItem(item: item),
      ContentItemLayout.sideImage => _SideImageContentItem(item: item),
      ContentItemLayout.largeImage => _LargeImageContentItem(item: item),
      ContentItemLayout.imageGrid => _ImageGridContentItem(item: item),
      ContentItemLayout.mediaFeature =>
        item.mediaFeature == null
            ? SizedBox.shrink(
                key: Key('content-mediaFeature-missing-${item.id}'),
              )
            : _MediaFeatureContentItem(item: item),
    };
  }
}

class _TextContentItem extends StatelessWidget {
  const _TextContentItem({required this.item});

  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    final article = item.article;

    return _NewsFeedItemSurface(
      item: item,
      child: NewsFeedItem(
        article: article,
        layout: NewsFeedLayout.text,
        carded: false,
        onTap: () => openArticle(context, article),
        tagAccentColor: _channelAccentColor(context),
        cardBackgroundColor: _channelCardSurfaceColor(context),
      ),
    );
  }
}

class _MediaFeatureContentItem extends StatelessWidget {
  const _MediaFeatureContentItem({required this.item});

  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    final mediaFeature = item.mediaFeature!;
    final tokens = context.tokens;
    final typography = context.typography;
    final visual = mediaFeature.visual;

    return _SurfaceShell(
      widgetKey: Key('content-mediaFeature-${item.id}'),
      surface: item.surface,
      clip: false,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: visual == null ? 74 : 156,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  right: visual == null ? 0 : 156,
                  top: visual == null ? 0 : 48,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mediaFeature.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: typography.heroTitle.copyWith(
                          fontSize: 25 * tokens.fontScale,
                          fontWeight: FontWeight.w800,
                          height: 1.12,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        mediaFeature.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: typography.feedMeta.copyWith(
                          fontSize: 17 * tokens.fontScale,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (visual != null)
                  Positioned(
                    right: 0,
                    top: -18,
                    child: _MediaFeaturePortrait(visual: visual),
                  ),
              ],
            ),
          ),
          if (mediaFeature.actions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            QuickActionSection(
              title: null,
              surface: QuickActionSectionSurface.inline,
              gridKey: const Key('quick-action-grid-media-feature'),
              items: _pageActionQuickItems(context, mediaFeature.actions),
              maxColumns: 3,
              shrinkToItemCount: true,
            ),
          ],
          if (mediaFeature.articles.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            for (var i = 0; i < mediaFeature.articles.length; i++) ...[
              _MediaFeatureArticleRow(article: mediaFeature.articles[i]),
              if (i != mediaFeature.articles.length - 1)
                const SizedBox(height: AppSpacing.xl),
            ],
          ],
          if (mediaFeature.moreLabel != null) ...[
            const SizedBox(height: AppSpacing.lg),
            FilledButton.tonal(
              key: const Key('content-mediaFeature-more'),
              onPressed: () => openArticle(context, item.article),
              style: FilledButton.styleFrom(
                backgroundColor: tokens.softFill,
                foregroundColor: tokens.textPrimary,
                minimumSize: const Size(116, 42),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                textStyle: context.typography.buttonLabel,
              ),
              child: Text(mediaFeature.moreLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _MediaFeaturePortrait extends StatelessWidget {
  const _MediaFeaturePortrait({required this.visual});

  final ArticleVisualAsset visual;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 128,
      height: 168,
      padding: const EdgeInsets.all(AppSpacing.xxs),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.input),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 22,
            spreadRadius: -6,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ArticleVisual(
        label: visual.label,
        type: visual.type,
        height: 160,
        compact: true,
        imageUrl: visual.imageUrl,
        showLabel: false,
      ),
    );
  }
}

class _MediaFeatureArticleRow extends StatelessWidget {
  const _MediaFeatureArticleRow({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;

    return InkWell(
      key: Key('mediaFeature-article-${article.id}'),
      borderRadius: BorderRadius.circular(AppRadius.media),
      onTap: () => openArticle(context, article),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SizedBox(
              height: 94,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: typography.feedTitleCompact,
                  ),
                  const Spacer(),
                  Text(
                    article.time,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typography.feedMeta,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          ArticleVisual(
            label: article.primaryVisual.label,
            type: article.primaryVisual.type,
            height: 82,
            width: 116,
            compact: true,
            showPlay: article.isVideo,
            duration: article.isVideo ? article.duration : null,
            imageUrl: article.primaryVisual.imageUrl,
            showLabel: false,
          ),
        ],
      ),
    );
  }
}

class _SideImageContentItem extends StatelessWidget {
  const _SideImageContentItem({required this.item});

  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    final article = item.article;

    return _NewsFeedItemSurface(
      item: item,
      child: NewsFeedItem(
        article: article,
        layout: NewsFeedLayout.sideImage,
        carded: false,
        onTap: () => openArticle(context, article),
        tagAccentColor: _channelAccentColor(context),
        cardBackgroundColor: _channelCardSurfaceColor(context),
      ),
    );
  }
}

class _LargeImageContentItem extends StatelessWidget {
  const _LargeImageContentItem({required this.item});

  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    final article = item.article;

    return _NewsFeedItemSurface(
      item: item,
      child: NewsFeedItem(
        article: article,
        layout: NewsFeedLayout.largeImage,
        carded: false,
        onTap: () => openArticle(context, article),
        tagAccentColor: _channelAccentColor(context),
        cardBackgroundColor: _channelCardSurfaceColor(context),
      ),
    );
  }
}

class _ImageGridContentItem extends StatelessWidget {
  const _ImageGridContentItem({required this.item});

  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    final article = item.article;

    return _NewsFeedItemSurface(
      item: item,
      child: NewsFeedItem(
        article: article,
        layout: NewsFeedLayout.imageGrid,
        imageGridKey: Key('content-item-${item.id}-multi-images'),
        carded: false,
        onTap: () => openArticle(context, article),
        tagAccentColor: _channelAccentColor(context),
        cardBackgroundColor: _channelCardSurfaceColor(context),
      ),
    );
  }
}

class _NewsFeedItemSurface extends StatelessWidget {
  const _NewsFeedItemSurface({required this.item, required this.child});

  final ContentItem item;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: Key('content-item-${item.id}'),
      child: switch (item.surface) {
        SurfaceStyle.card ||
        SurfaceStyle.plain ||
        SurfaceStyle.fullBleed => AppCard(
          padding: EdgeInsets.zero,
          radius: AppRadius.input,
          showBorder: false,
          backgroundColor: _channelCardSurfaceColor(context),
          child: child,
        ),
        SurfaceStyle.separated => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            child,
            Divider(height: 1, color: context.tokens.divider),
          ],
        ),
      },
    );
  }
}

class _SurfaceShell extends StatelessWidget {
  const _SurfaceShell({
    required this.surface,
    required this.child,
    this.widgetKey,
    this.padding = EdgeInsets.zero,
    this.clip = true,
  });

  final SurfaceStyle surface;
  final Widget child;
  final Key? widgetKey;
  final EdgeInsetsGeometry padding;
  final bool clip;

  @override
  Widget build(BuildContext context) {
    return switch (surface) {
      SurfaceStyle.card => AppCard(
        key: widgetKey,
        padding: padding,
        radius: AppRadius.input,
        showBorder: false,
        backgroundColor: _channelCardSurfaceColor(context),
        clipBehavior: clip ? Clip.antiAlias : Clip.none,
        child: child,
      ),
      SurfaceStyle.plain => _PlainSurface(
        widgetKey: widgetKey,
        padding: padding,
        child: child,
      ),
      SurfaceStyle.separated => Column(
        key: widgetKey,
        children: [
          _PlainSurface(padding: padding, child: child),
          Divider(height: 1, color: context.tokens.divider),
        ],
      ),
      SurfaceStyle.fullBleed => _PlainSurface(
        widgetKey: widgetKey,
        padding: EdgeInsets.zero,
        child: child,
      ),
    };
  }
}

class _PlainSurface extends StatelessWidget {
  const _PlainSurface({
    required this.child,
    this.widgetKey,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final Key? widgetKey;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(key: widgetKey, padding: padding, child: child);
  }
}

Color? _channelAccentColor(BuildContext context) {
  return ChannelVisualThemeScope.of(context).accentColor;
}

Color? _channelCardSurfaceColor(BuildContext context) {
  return ChannelVisualThemeScope.of(context).cardSurfaceColor;
}

List<QuickActionItem> _pageActionQuickItems(
  BuildContext context,
  Iterable<PageAction> actions,
) {
  return [
    for (final action in actions)
      QuickActionItem(
        key: Key('page-action-${action.id}'),
        icon: _pageActionIcon(action.icon),
        label: action.label,
        color: _pageActionColor(context, action.icon),
        badge: action.badge,
        onTap: () => _openAction(context, action.id),
      ),
  ];
}

Color _pageActionColor(BuildContext context, PageActionIcon icon) {
  return switch (icon) {
    PageActionIcon.politics => const Color(0xffcf3b2e),
    PageActionIcon.live => const Color(0xffe64a67),
    PageActionIcon.report => const Color(0xfff29b38),
    PageActionIcon.service => const Color(0xff327bd6),
    PageActionIcon.travel => const Color(0xff36a878),
    PageActionIcon.education => const Color(0xff7666d8),
    PageActionIcon.health => const Color(0xff2fa09a),
    PageActionIcon.village => const Color(0xff6c9c36),
    PageActionIcon.activity => const Color(0xffd66b36),
    PageActionIcon.weather => const Color(0xff3c95dc),
  };
}

IconData _pageActionIcon(PageActionIcon icon) {
  return switch (icon) {
    PageActionIcon.politics => Icons.account_balance_outlined,
    PageActionIcon.live => Icons.live_tv_outlined,
    PageActionIcon.report => Icons.campaign_outlined,
    PageActionIcon.service => Icons.apps_outlined,
    PageActionIcon.travel => Icons.landscape_outlined,
    PageActionIcon.education => Icons.school_outlined,
    PageActionIcon.health => Icons.local_hospital_outlined,
    PageActionIcon.village => Icons.park_outlined,
    PageActionIcon.activity => Icons.event_available_outlined,
    PageActionIcon.weather => Icons.wb_sunny_outlined,
  };
}

void openArticle(BuildContext context, Article article) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => ArticleDetailPage(article: article)),
  );
}

void _openAction(BuildContext context, String id) {
  switch (id) {
    case 'live':
      _openMedia(context, 'morning-live');
    case 'report':
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const ReportFormPage()));
    case 'service':
      final service = const ServiceRepository().defaultRecentItems.first;
      openServiceEntry(context, service);
    default:
      final article = const HomeContentRepository().articleById(
        id == 'politics' ? 'politics-service-meeting' : 'culture-walk',
      );
      if (article != null) openArticle(context, article);
  }
}

void _openTile(BuildContext context, String id) {
  final repository = const ServiceRepository();
  final service = repository.findById(id) ?? repository.findById('$id-service');
  if (service != null) {
    openServiceEntry(context, service);
    return;
  }
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text('服务暂不可用')));
}

void _openMedia(BuildContext context, String id) {
  final programs = const LiveRepository().programs;
  final program = programs.firstWhere(
    (item) =>
        id.contains(item.id) ||
        (id.contains('rural') && item.id == 'rural-program') ||
        (id.contains('city-service') && item.id == 'city-service'),
    orElse: () => programs.first,
  );
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => LiveDetailPage(program: program)));
}
