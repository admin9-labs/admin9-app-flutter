import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../paging/content_pager.dart';
import '../paging/page_indicators.dart';
import 'a_carousel_item.dart';

enum ACarouselCaption { none, overlay, below }

/// Horizontal content paging with identity retention and lifecycle-aware autoplay.
/// Hosts set [active] to false when a carousel is offscreen but still mounted.
class ACarousel extends StatelessWidget {
  const ACarousel({
    required this.items,
    this.aspectRatio = 5 / 3,
    this.caption = ACarouselCaption.overlay,
    this.autoplay = false,
    this.loop = false,
    this.interval = const Duration(seconds: 5),
    this.showIndicators = true,
    this.active = true,
    this.onChanged,
    super.key,
  }) : assert(aspectRatio > 0);

  /// Caller-owned visual content with unique, stable item IDs.
  final List<ACarouselItem> items;
  final double aspectRatio;
  final ACarouselCaption caption;
  final bool autoplay, loop, showIndicators, active;
  final Duration interval;

  /// Reports a new index after user/automatic paging or content reconciliation.
  /// Content updates also notify when the selected ID changes at the same index.
  /// Initial construction and empty content do not notify.
  final ValueChanged<int>? onChanged;
  Widget _caption(String title, {bool overlay = false}) => Builder(
    builder: (context) => ColoredBox(
      color: context.theme.colors.card,
      child: Padding(
        padding: context.theme.cardStyle.padding,
        child: Text(
          title,
          maxLines: overlay ? 1 : null,
          overflow: overlay ? TextOverflow.ellipsis : null,
          style: context.theme.typography.body.md.copyWith(
            color: context.theme.colors.foreground,
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => ContentPager(
    autoplay: autoplay,
    loop: loop,
    interval: interval,
    active: active,
    onChanged: onChanged,
    items: [
      for (final item in items)
        (
          id: item.id,
          semanticsLabel: item.semanticsLabel,
          onPress: item.onPress,
          child: Stack(
            fit: StackFit.expand,
            children: [
              item.child,
              if (caption == ACarouselCaption.overlay &&
                  item.title != null &&
                  item.title!.isNotEmpty)
                PositionedDirectional(
                  start: 0,
                  end: 0,
                  bottom: 0,
                  child: ExcludeSemantics(
                    child: _caption(item.title!, overlay: true),
                  ),
                ),
            ],
          ),
        ),
    ],
    frameBuilder: (context, viewport, index, _) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: context.theme.buttonStyles.ghost.md.contentStyle.spacing,
      children: [
        AspectRatio(
          aspectRatio: aspectRatio,
          child: ClipRRect(
            borderRadius: context.theme.style.borderRadius.md,
            child: viewport,
          ),
        ),
        if (showIndicators) PageIndicators(index: index, count: items.length),
        if (caption == ACarouselCaption.below &&
            items[index].title != null &&
            items[index].title!.isNotEmpty)
          _caption(items[index].title!),
      ],
    ),
  );
}
