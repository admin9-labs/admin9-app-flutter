import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../paging/content_item_view.dart';

enum AFeedCardLayout { textOnly, trailingImage, threeImages, largeImage }

/// Content layout only. Hosts own image loading, metadata formatting and actions.
class AFeedCard extends StatelessWidget {
  const AFeedCard({
    required this.title,
    required this.semanticsLabel,
    this.images = const [],
    this.metadata = '',
    this.layout,
    this.mediaBadge,
    this.onPress,
    super.key,
  });
  final String title, metadata, semanticsLabel;

  /// Decorative images. Three-image layout displays the first three images.
  final List<Widget> images;

  /// Null selects three images, one trailing image, or text from image count.
  /// Missing images degrade to trailing image or text; explicit text hides images.
  final AFeedCardLayout? layout;

  /// Decorative media marker. Include its meaning in [semanticsLabel].
  final Widget? mediaBadge;
  final VoidCallback? onPress;

  AFeedCardLayout get _layout {
    if (layout == AFeedCardLayout.textOnly || images.isEmpty) {
      return AFeedCardLayout.textOnly;
    }
    final requested =
        layout ??
        (images.length >= 3
            ? AFeedCardLayout.threeImages
            : AFeedCardLayout.trailingImage);
    return requested == AFeedCardLayout.threeImages && images.length < 3
        ? AFeedCardLayout.trailingImage
        : requested;
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.theme.buttonStyles.ghost.md.contentStyle.spacing;
    final titleView = Text(
      title,
      style: context.theme.typography.body.md.copyWith(
        color: context.theme.colors.foreground,
      ),
    );
    final metadataView = Text(
      metadata,
      style: context.theme.typography.body.xs2.copyWith(
        color: context.theme.colors.mutedForeground,
      ),
    );
    final content = switch (_layout) {
      AFeedCardLayout.textOnly => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing,
        children: [
          titleView,
          ?mediaBadge,
          if (metadata.isNotEmpty) metadataView,
        ],
      ),
      AFeedCardLayout.trailingImage => LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth * .3;
          final textWidth = math.max(
            0.0,
            constraints.maxWidth - width - spacing,
          );
          final painter = TextPainter(
            text: TextSpan(text: metadata, style: metadataView.style),
            textScaler: MediaQuery.textScalerOf(context),
            textDirection: Directionality.of(context),
            locale: Localizations.maybeLocaleOf(context),
          )..layout();
          final below = painter.width > textWidth;
          painter.dispose();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: spacing,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: spacing,
                children: [
                  Expanded(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: width / (4 / 3)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        spacing: spacing,
                        children: [
                          titleView,
                          if (!below && metadata.isNotEmpty) metadataView,
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _cover(context, images.first, 4 / 3),
                  ),
                ],
              ),
              if (below && metadata.isNotEmpty) metadataView,
            ],
          );
        },
      ),
      AFeedCardLayout.threeImages => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing,
        children: [
          titleView,
          Row(
            spacing: spacing,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < 3; i++)
                Expanded(
                  child: _cover(context, images[i], 3 / 2, badge: i == 0),
                ),
            ],
          ),
          if (metadata.isNotEmpty) metadataView,
        ],
      ),
      AFeedCardLayout.largeImage => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing,
        children: [
          titleView,
          _cover(context, images.first, 16 / 9),
          if (metadata.isNotEmpty) metadataView,
        ],
      ),
    };
    return ContentItemView(
      semanticsLabel: semanticsLabel,
      onPress: onPress,
      child: FCard(
        child: Padding(
          padding: context.theme.cardStyle.padding,
          child: content,
        ),
      ),
    );
  }

  Widget _cover(
    BuildContext context,
    Widget image,
    double ratio, {
    bool badge = true,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: context.theme.buttonStyles.ghost.md.contentStyle.spacing,
    children: [
      ClipRRect(
        borderRadius: context.theme.style.borderRadius.sm,
        child: AspectRatio(aspectRatio: ratio, child: image),
      ),
      // Keep media metadata outside the image so long durations survive large text.
      if (badge && mediaBadge != null) mediaBadge!,
    ],
  );
}
