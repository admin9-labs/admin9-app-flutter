import 'package:flutter/material.dart';

import '../../domain/models/article.dart';
import '../theme/app_appearance.dart';
import '../theme/app_spacing.dart';
import 'media_badge.dart';

enum MediaCoverStatus { none, live, replay }

class MediaCover extends StatelessWidget {
  const MediaCover({
    super.key,
    required this.label,
    required this.type,
    this.imageUrl,
    this.width,
    this.height,
    this.aspectRatio,
    this.compact = false,
    this.showPlay = false,
    this.duration,
    this.status = MediaCoverStatus.none,
    this.showLabel = false,
    this.borderRadius = AppRadius.media,
  }) : assert(height != null || aspectRatio != null);

  final String label;
  final ArticleVisualType type;
  final String? imageUrl;
  final double? width;
  final double? height;
  final double? aspectRatio;
  final bool compact;
  final bool showPlay;
  final String? duration;
  final MediaCoverStatus status;
  final bool showLabel;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final cover = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _CoverBackground(label: label, type: type, imageUrl: imageUrl),
          if (showLabel ||
              showPlay ||
              duration != null ||
              status != MediaCoverStatus.none)
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    context.tokens.videoScrim.withValues(alpha: 0.82),
                  ],
                ),
              ),
            ),
          if (showPlay) Center(child: _PlayButton(compact: compact)),
          if (showLabel)
            Positioned(
              left: compact ? AppSpacing.sm : AppSpacing.md,
              right: compact ? AppSpacing.sm : AppSpacing.md,
              bottom: compact ? AppSpacing.sm : AppSpacing.md,
              child: Text(
                label,
                maxLines: compact ? 1 : 2,
                overflow: TextOverflow.ellipsis,
                style:
                    (compact
                            ? context.typography.actionLabel
                            : context.typography.coverTitle)
                        .copyWith(color: Colors.white),
              ),
            ),
          if (duration != null)
            Positioned(
              right: AppSpacing.sm,
              bottom: AppSpacing.sm,
              child: MediaBadge(
                label: duration!,
                icon: showPlay ? Icons.play_arrow_rounded : null,
              ),
            ),
          if (status != MediaCoverStatus.none)
            Positioned(
              left: AppSpacing.sm,
              top: AppSpacing.sm,
              child: MediaBadge(
                label: status == MediaCoverStatus.live ? '直播' : '回放',
                color: status == MediaCoverStatus.live
                    ? context.tokens.danger
                    : Colors.black.withValues(alpha: 0.44),
              ),
            ),
        ],
      ),
    );

    final sized = width == null
        ? SizedBox(height: height, child: cover)
        : SizedBox(width: width, height: height, child: cover);
    if (aspectRatio == null) return sized;
    return AspectRatio(aspectRatio: aspectRatio!, child: cover);
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 32.0 : 44.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.30),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.60)),
      ),
      child: Icon(
        Icons.play_arrow_rounded,
        color: Colors.white,
        size: compact ? AppIconSize.action : 34,
      ),
    );
  }
}

class _CoverBackground extends StatelessWidget {
  const _CoverBackground({
    required this.label,
    required this.type,
    required this.imageUrl,
  });

  final String label;
  final ArticleVisualType type;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final cacheSize = _cacheSize(context, constraints);
          return Image.network(
            imageUrl!,
            key: Key('network-image-$label'),
            fit: BoxFit.cover,
            cacheWidth: cacheSize?.$1,
            cacheHeight: cacheSize?.$2,
            errorBuilder: (_, _, _) => _CoverFallback(label: label, type: type),
          );
        },
      );
    }

    return _CoverFallback(label: label, type: type);
  }

  (int, int)? _cacheSize(BuildContext context, BoxConstraints constraints) {
    if (!constraints.hasBoundedWidth || !constraints.hasBoundedHeight) {
      return null;
    }
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;
    if (width <= 0 || height <= 0) return null;

    final dpr = MediaQuery.devicePixelRatioOf(context);
    return ((width * dpr).ceil(), (height * dpr).ceil());
  }
}

class _CoverFallback extends StatelessWidget {
  const _CoverFallback({required this.label, required this.type});

  final String label;
  final ArticleVisualType type;

  @override
  Widget build(BuildContext context) {
    final colors = _palette(context, type);
    final icon = _icon(type);

    return DecoratedBox(
      key: Key('visual-fallback-$label'),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -AppSpacing.xxl,
            top: -AppSpacing.xxl,
            child: Icon(
              icon,
              size: 118,
              color: Colors.white.withValues(alpha: 0.18),
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _palette(BuildContext context, ArticleVisualType type) {
    final tokens = context.tokens;
    return switch (type) {
      ArticleVisualType.politics => [tokens.brand.primary, tokens.danger],
      ArticleVisualType.city => [tokens.info, tokens.success],
      ArticleVisualType.service => [tokens.success, tokens.info],
      ArticleVisualType.sports => [tokens.info, tokens.success],
      ArticleVisualType.culture => [tokens.brand.primary, tokens.warning],
      ArticleVisualType.live => [tokens.textSecondary, tokens.textTertiary],
      ArticleVisualType.rural => [tokens.success, tokens.warning],
    };
  }

  IconData _icon(ArticleVisualType type) {
    return switch (type) {
      ArticleVisualType.politics => Icons.account_balance_outlined,
      ArticleVisualType.city => Icons.apartment_outlined,
      ArticleVisualType.service => Icons.home_repair_service_outlined,
      ArticleVisualType.sports => Icons.sports_soccer_outlined,
      ArticleVisualType.culture => Icons.theater_comedy_outlined,
      ArticleVisualType.live => Icons.live_tv_outlined,
      ArticleVisualType.rural => Icons.park_outlined,
    };
  }
}
