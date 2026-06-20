import 'dart:ui';

class MediaChannel {
  const MediaChannel({
    required this.id,
    required this.label,
    this.fixed = false,
    this.style = const MediaChannelStyle(),
    this.content = const MediaChannelContent.nativeBlocks(),
  });

  final String id;
  final String label;
  final bool fixed;
  final MediaChannelStyle style;
  final MediaChannelContent content;
}

class MediaChannelContent {
  const MediaChannelContent.nativeBlocks()
    : type = MediaChannelContentType.nativeBlocks,
      h5Url = null;

  const MediaChannelContent.h5({required String url})
    : type = MediaChannelContentType.h5,
      h5Url = url;

  final MediaChannelContentType type;
  final String? h5Url;
}

class MediaChannelStyle {
  /// Configurable visual frame for a first-level media channel.
  ///
  /// Profile fields describe reusable recipes, not channel identities:
  /// - [MediaChannelVisualProfile.standard]: brand top image + plain surface.
  /// - [MediaChannelVisualProfile.gradientRelay]: top gradient continues into
  ///   a content gradient without enabling an immersive image.
  /// - [MediaChannelVisualProfile.campaignImmersive]: activity-style backdrop
  ///   with optional transparent chrome and pull stretch.
  ///
  /// The newer background/profile fields are the primary configuration path.
  /// Legacy surface fields remain as compatibility inputs while local static
  /// channel data is migrated toward backend-mappable style tokens.
  const MediaChannelStyle({
    this.visualProfile = MediaChannelVisualProfile.standard,
    this.chromeBehavior = MediaChannelChromeBehavior.solid,
    this.topBackground = const MediaChannelTopBackground(),
    this.backdropBlendMode = MediaChannelBackdropBlendMode.fadeToSurface,
    this.contentBackground = const MediaChannelContentBackground(),
    this.pullEffect = MediaChannelPullEffect.none,
    this.surfaceMode = MediaChannelSurfaceMode.normal,
    this.topSurfaceMode = MediaChannelTopSurfaceMode.brand,
    this.backgroundColor,
    this.accentColor,
    this.cardSurfaceColor,
    this.backdropAssetName,
    this.backdropImageUrl,
    this.darkBackdropAssetName,
    this.darkBackdropImageUrl,
    this.immersiveBackdropAssetName,
    this.immersiveBackdropImageUrl,
    this.darkImmersiveBackdropAssetName,
    this.darkImmersiveBackdropImageUrl,
    this.immersiveContentTopInset,
    this.immersiveBackdropHeight,
  });

  final MediaChannelVisualProfile visualProfile;
  final MediaChannelChromeBehavior chromeBehavior;
  final MediaChannelTopBackground topBackground;
  final MediaChannelBackdropBlendMode backdropBlendMode;
  final MediaChannelContentBackground contentBackground;
  final MediaChannelPullEffect pullEffect;
  final MediaChannelSurfaceMode surfaceMode;
  final MediaChannelTopSurfaceMode topSurfaceMode;
  final Color? backgroundColor;
  final Color? accentColor;
  final Color? cardSurfaceColor;
  final String? backdropAssetName;
  final String? backdropImageUrl;
  final String? darkBackdropAssetName;
  final String? darkBackdropImageUrl;
  final String? immersiveBackdropAssetName;
  final String? immersiveBackdropImageUrl;
  final String? darkImmersiveBackdropAssetName;
  final String? darkImmersiveBackdropImageUrl;
  final double? immersiveContentTopInset;
  final double? immersiveBackdropHeight;
}

class MediaChannelTopBackground {
  const MediaChannelTopBackground({
    this.mode = MediaChannelTopBackgroundMode.brandImage,
    this.startColor,
    this.middleColor,
    this.endColor,
    this.height,
  });

  final MediaChannelTopBackgroundMode mode;
  final Color? startColor;
  final Color? middleColor;
  final Color? endColor;
  final double? height;
}

class MediaChannelContentBackground {
  const MediaChannelContentBackground({
    this.mode = MediaChannelContentBackgroundMode.none,
    this.startColor,
    this.endColor,
    this.height,
  });

  final MediaChannelContentBackgroundMode mode;
  final Color? startColor;
  final Color? endColor;
  final double? height;
}

enum MediaChannelVisualProfile { standard, gradientRelay, campaignImmersive }

enum MediaChannelChromeBehavior { solid, transparentToSolid }

enum MediaChannelTopBackgroundMode { brandImage, gradient, color, customImage }

enum MediaChannelBackdropBlendMode { fadeToSurface, fadeToColor, none }

enum MediaChannelContentBackgroundMode { none, gradientRelay }

enum MediaChannelPullEffect { none, stretchBackdrop }

enum MediaChannelSurfaceMode { normal, immersive }

enum MediaChannelTopSurfaceMode { brand, channelColor, customImage }

enum MediaChannelContentType { nativeBlocks, h5 }
