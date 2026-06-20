import 'article.dart';

enum PageBlockType {
  noticeBar,
  imageCarousel,
  iconNavigation,
  tileGrid,
  mediaShowcase,
  serviceNavigation,
  specialEntry,
  specialContentGroup,
  contentFeed,
}

enum ContentKind { article, special, gallery, video, live, replay, service }

enum ContentItemLayout { text, sideImage, largeImage, imageGrid, mediaFeature }

enum SurfaceStyle { plain, card, separated, fullBleed }

class PageBlock {
  const PageBlock({
    required this.id,
    required this.type,
    required this.adminName,
    required this.sort,
    this.enabled = true,
    this.visible = true,
    this.displayTitle,
    this.channelId,
    this.startAt,
    this.endAt,
    this.showHeader = false,
    this.showMore = false,
    this.moreLabel,
    this.moreTarget,
    this.noticeBarConfig = const NoticeBarConfig(),
    this.noticeItems = const [],
    this.actions = const [],
    this.tiles = const [],
    this.mediaItems = const [],
    this.specialEntries = const [],
    this.items = const [],
    this.carousel,
    this.surface = SurfaceStyle.plain,
  });

  final String id;
  final PageBlockType type;
  final String adminName;
  final int sort;
  final bool enabled;
  final bool visible;
  final String? displayTitle;
  final String? channelId;
  final String? startAt;
  final String? endAt;
  final bool showHeader;
  final bool showMore;
  final String? moreLabel;
  final String? moreTarget;
  final NoticeBarConfig noticeBarConfig;
  final List<NoticeItem> noticeItems;
  final List<PageAction> actions;
  final List<TileGridItem> tiles;
  final List<MediaShowcaseItem> mediaItems;
  final List<SpecialEntryItem> specialEntries;
  final List<ContentItem> items;
  final ImageCarousel? carousel;
  final SurfaceStyle surface;

  bool isActiveAt(DateTime now) {
    final activeFrom = _parsePrototypeDate(startAt);
    final activeUntil = _parsePrototypeDate(endAt);
    if (activeFrom != null && now.isBefore(activeFrom)) return false;
    if (activeUntil != null && now.isAfter(activeUntil)) return false;
    return true;
  }

  bool get hasRenderablePayload {
    return switch (type) {
      PageBlockType.noticeBar => noticeItems.isNotEmpty,
      PageBlockType.imageCarousel => carousel?.items.isNotEmpty ?? false,
      PageBlockType.iconNavigation => actions.isNotEmpty,
      PageBlockType.tileGrid => tiles.isNotEmpty,
      PageBlockType.mediaShowcase => mediaItems.isNotEmpty,
      PageBlockType.serviceNavigation => true,
      PageBlockType.specialEntry => specialEntries.isNotEmpty,
      PageBlockType.specialContentGroup => items.any(
        (item) => item.isRenderable,
      ),
      PageBlockType.contentFeed => items.any((item) => item.isRenderable),
    };
  }
}

DateTime? _parsePrototypeDate(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) return null;
  return DateTime.tryParse(normalized);
}

class NoticeBarConfig {
  const NoticeBarConfig({this.intervalMs = 3000, this.loop = true});

  final int intervalMs;
  final bool loop;
}

class NoticeItem {
  const NoticeItem({
    required this.id,
    required this.title,
    this.url,
    this.sort = 0,
  });

  final String id;
  final String title;
  final String? url;
  final int sort;
}

class PageAction {
  const PageAction({
    required this.id,
    required this.label,
    required this.icon,
    this.badge,
  });

  final String id;
  final String label;
  final PageActionIcon icon;
  final String? badge;
}

enum PageActionIcon {
  politics,
  live,
  report,
  service,
  travel,
  education,
  health,
  village,
  activity,
  weather,
}

enum ImageCarouselVariant { large, medium, small, slim }

class ImageCarousel {
  const ImageCarousel({
    required this.items,
    this.variant = ImageCarouselVariant.large,
    this.indicatorStyle = CarouselIndicatorStyle.number,
    this.indicatorPosition = CarouselIndicatorPosition.bottomRight,
    this.titlePlacement = CarouselTitlePlacement.overlay,
  });

  final List<ImageCarouselItem> items;
  final ImageCarouselVariant variant;
  final CarouselIndicatorStyle indicatorStyle;
  final CarouselIndicatorPosition indicatorPosition;
  final CarouselTitlePlacement titlePlacement;
}

class ImageCarouselItem {
  const ImageCarouselItem({
    required this.id,
    required this.title,
    required this.visual,
    this.subtitle,
  });

  final String id;
  final String title;
  final ArticleVisualAsset visual;
  final String? subtitle;
}

enum CarouselIndicatorStyle { dots, number, line }

enum CarouselIndicatorPosition { bottomCenter, bottomRight, bottomLeft }

enum CarouselTitlePlacement { overlay, below, hidden }

class TileGridItem {
  const TileGridItem({
    required this.id,
    required this.title,
    required this.visual,
    this.subtitle,
    this.badge,
  });

  final String id;
  final String title;
  final ArticleVisualAsset visual;
  final String? subtitle;
  final String? badge;
}

enum MediaKind { video, live, replay }

class MediaShowcaseItem {
  const MediaShowcaseItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.visual,
    this.durationText,
    this.badge,
  });

  final String id;
  final MediaKind kind;
  final String title;
  final ArticleVisualAsset visual;
  final String? durationText;
  final String? badge;
}

class SpecialEntryItem {
  const SpecialEntryItem({
    required this.id,
    required this.specialId,
    required this.title,
    required this.visual,
    this.subtitle,
    this.badge,
    this.targetUrl,
  });

  final String id;
  final String specialId;
  final String title;
  final ArticleVisualAsset visual;
  final String? subtitle;
  final String? badge;
  final String? targetUrl;
}

class ContentItem {
  const ContentItem({
    required this.id,
    required this.title,
    required this.contentKind,
    required this.layout,
    required this.article,
    this.surface = SurfaceStyle.card,
    this.mediaFeature,
  });

  final String id;
  final String title;
  final ContentKind contentKind;
  final ContentItemLayout layout;
  final Article article;
  final SurfaceStyle surface;
  final MediaFeatureContent? mediaFeature;

  bool get isRenderable {
    return switch (layout) {
      ContentItemLayout.mediaFeature => mediaFeature != null,
      _ => true,
    };
  }
}

class MediaFeatureContent {
  const MediaFeatureContent({
    required this.title,
    required this.subtitle,
    this.visual,
    this.actions = const [],
    this.articles = const [],
    this.moreLabel,
  });

  final String title;
  final String subtitle;
  final ArticleVisualAsset? visual;
  final List<PageAction> actions;
  final List<Article> articles;
  final String? moreLabel;
}
