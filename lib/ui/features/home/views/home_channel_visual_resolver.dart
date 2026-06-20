import 'package:flutter/material.dart';

import '../../../../core/assets/app_assets.dart';
import '../../../../core/theme/app_appearance.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/top_level_page_scaffold.dart';
import '../../../../domain/models/media_channel.dart';
import 'channel_content_tab.dart';
import 'channel_visual_theme.dart';

class HomeChannelVisualResolver {
  const HomeChannelVisualResolver();

  ChannelVisualTheme visualThemeFor(MediaChannelStyle style) {
    return ChannelVisualTheme(
      accentColor: style.accentColor,
      cardSurfaceColor: style.cardSurfaceColor,
    );
  }

  ChannelImmersiveBackground? immersiveBackgroundFor(
    BuildContext context,
    MediaChannelStyle style,
  ) {
    if (style.visualProfile != MediaChannelVisualProfile.campaignImmersive &&
        style.surfaceMode != MediaChannelSurfaceMode.immersive) {
      return null;
    }

    final dark = Theme.of(context).brightness == Brightness.dark;
    final assetName = dark
        ? style.darkImmersiveBackdropAssetName
        : style.immersiveBackdropAssetName;
    final imageUrl = dark
        ? style.darkImmersiveBackdropImageUrl
        : style.immersiveBackdropImageUrl;
    if (!_hasConfiguredImage(assetName) && !_hasConfiguredImage(imageUrl)) {
      return null;
    }

    final backgroundColor = _backgroundFor(
      context,
      style,
      context.tokens.pageBackground,
    );
    final height =
        style.immersiveBackdropHeight ??
        AppSpacing.homeImmersiveChannelBackdropHeight;

    return ChannelImmersiveBackground(
      surface: PageSurface(
        backgroundColor: backgroundColor,
        backdrop: PageBackdrop.image(
          tokens: context.tokens,
          endColor: backgroundColor,
          assetName: assetName,
          imageUrl: imageUrl,
          enabled:
              style.visualProfile == MediaChannelVisualProfile.campaignImmersive
              ? true
              : null,
          height: height,
          imageAlignment: Alignment.topCenter,
          blendMode: pageBackdropBlendModeFor(style),
          blendColor: blendColorFor(style, backgroundColor),
        ),
      ).resolve(context),
      height: height,
      stretchExtent: style.pullEffect == MediaChannelPullEffect.stretchBackdrop
          ? AppSpacing.homeImmersiveChannelPullExtent
          : 0,
    );
  }

  ChannelContentBackground? contentBackgroundFor(
    BuildContext context,
    MediaChannelStyle style,
  ) {
    final config = style.contentBackground;
    if (config.mode != MediaChannelContentBackgroundMode.gradientRelay) {
      return null;
    }
    if (Theme.of(context).brightness == Brightness.dark) return null;

    return ChannelContentBackground.gradientRelay(
      startColor: config.startColor ?? context.tokens.brand.gradientMiddle,
      endColor: config.endColor ?? context.tokens.pageBackground,
      height: config.height ?? 220,
    );
  }

  PageFrameBackground? frameBackgroundFor(
    BuildContext context,
    MediaChannelStyle style, {
    double strength = 1,
  }) {
    if (style.visualProfile != MediaChannelVisualProfile.gradientRelay) {
      return null;
    }
    if (Theme.of(context).brightness == Brightness.dark) return null;
    if (style.contentBackground.mode !=
        MediaChannelContentBackgroundMode.gradientRelay) {
      return null;
    }

    final topBackground = style.topBackground;
    final contentBackground = style.contentBackground;
    final backgroundColor = _backgroundFor(
      context,
      style,
      context.tokens.pageBackground,
    );
    final joinColor =
        contentBackground.startColor ??
        topBackground.endColor ??
        backgroundColor;
    return PageFrameBackground.gradientRelay(
      topStartColor:
          topBackground.startColor ?? context.tokens.brand.gradientStart,
      topMiddleColor:
          topBackground.middleColor ??
          topBackground.endColor ??
          context.tokens.brand.gradientMiddle,
      joinColor: joinColor,
      contentEndColor: contentBackground.endColor ?? backgroundColor,
      topHeight: topBackground.height,
      contentHeight: contentBackground.height ?? 220,
      strength: strength,
    );
  }

  TopLevelChromeBackground chromeBackgroundFor(
    BuildContext context,
    MediaChannelStyle style,
  ) {
    if (style.chromeBehavior != MediaChannelChromeBehavior.transparentToSolid) {
      return const TopLevelChromeBackground.transparent();
    }

    return TopLevelChromeBackground.transparentToSolid(
      solidColor: _backgroundFor(context, style, context.tokens.pageBackground),
      midOpacity: 0.48,
    );
  }

  PageSurface surfaceFor({
    required BuildContext context,
    required MediaChannelStyle style,
    required Color backgroundColor,
    double imageWeight = 1,
  }) {
    final chromeDarkFactor = _chromeDarkFactorFor(backgroundColor);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final chrome = topChromeBackdropFor(context, style);

    if (chrome == null || dark || imageWeight == 0) {
      return PageSurface(
        backgroundColor: backgroundColor,
        chromeDarkFactor: chromeDarkFactor,
        frameBackground: frameBackgroundFor(context, style, strength: 0),
        backdrop: PageBackdrop(
          enabled: false,
          startColor: backgroundColor,
          middleColor: backgroundColor,
          endColor: backgroundColor,
          blendMode: PageBackdropBlendMode.none,
        ),
      );
    }

    final backdrop = chrome.gradient
        ? PageBackdrop.gradient(
            startColor: chrome.startColor ?? backgroundColor,
            middleColor:
                chrome.middleColor ?? chrome.startColor ?? backgroundColor,
            endColor: chrome.endColor ?? backgroundColor,
            colors: chrome.colors,
            stops: chrome.stops,
            height: chrome.height ?? AppSpacing.topLevelBackdropHeight,
            strength: imageWeight,
            blendMode: chrome.blendMode,
            blendColor: chrome.blendColor,
          )
        : chrome.solidColor != null
        ? PageBackdrop.solid(
            color: chrome.solidColor!,
            height: chrome.height ?? AppSpacing.topLevelBackdropHeight,
            strength: imageWeight,
            blendMode: chrome.blendMode,
            blendColor: chrome.blendColor,
          )
        : PageBackdrop.image(
            tokens: context.tokens,
            endColor: backgroundColor,
            assetName: chrome.assetName,
            imageUrl: chrome.imageUrl,
            darkAssetName: chrome.darkAssetName,
            darkImageUrl: chrome.darkImageUrl,
            enabled: true,
            imageOpacity: imageWeight,
            imageAlignment: chrome.imageAlignment,
            blendMode: chrome.blendMode,
            blendColor: chrome.blendColor,
          );

    return PageSurface(
      backgroundColor: backgroundColor,
      chromeDarkFactor: chromeDarkFactor,
      frameBackground: frameBackgroundFor(
        context,
        style,
        strength: imageWeight,
      ),
      backdrop: backdrop,
    );
  }

  HomeTopChromeBackdrop? topChromeBackdropFor(
    BuildContext context,
    MediaChannelStyle style,
  ) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = _backgroundFor(
      context,
      style,
      context.tokens.pageBackground,
    );
    final topBackgroundMode = effectiveTopBackgroundMode(style);

    if (topBackgroundMode == MediaChannelTopBackgroundMode.color) {
      final color = style.topBackground.endColor ?? backgroundColor;
      return HomeTopChromeBackdrop.solid(
        color: color,
        height: style.topBackground.height,
        blendMode: pageBackdropBlendModeFor(style),
        blendColor: blendColorFor(style, backgroundColor),
      );
    }

    if (topBackgroundMode == MediaChannelTopBackgroundMode.gradient) {
      final topBackground = style.topBackground;
      final startColor =
          topBackground.startColor ?? context.tokens.brand.gradientStart;
      final middleColor =
          topBackground.middleColor ??
          topBackground.endColor ??
          context.tokens.brand.gradientMiddle;
      final endColor = topBackground.endColor ?? backgroundColor;

      return HomeTopChromeBackdrop.gradient(
        startColor: startColor,
        middleColor: middleColor,
        endColor: endColor,
        height: topBackground.height,
        colors: [startColor, middleColor, endColor],
        stops: const [0, 0.46, 1],
        blendMode: pageBackdropBlendModeFor(style),
        blendColor: blendColorFor(style, backgroundColor),
      );
    }

    final topSurfaceMode = effectiveTopSurfaceMode(style);
    if (topSurfaceMode == MediaChannelTopSurfaceMode.channelColor) {
      return null;
    }

    final effectiveAssetName = resolveTopChromeBackdropAsset(
      style: style,
      dark: dark,
      brandId: context.tokens.brand.id,
      topSurfaceMode: topSurfaceMode,
    );
    final effectiveImageUrl = resolveTopChromeBackdropUrl(
      style: style,
      dark: dark,
      topSurfaceMode: topSurfaceMode,
    );
    final effectiveDarkAssetName =
        !dark && topSurfaceMode == MediaChannelTopSurfaceMode.customImage
        ? style.darkBackdropAssetName
        : null;
    final effectiveDarkImageUrl =
        !dark && topSurfaceMode == MediaChannelTopSurfaceMode.customImage
        ? style.darkBackdropImageUrl
        : null;

    if (!_hasConfiguredImage(effectiveAssetName) &&
        !_hasConfiguredImage(effectiveImageUrl) &&
        !_hasConfiguredImage(effectiveDarkAssetName) &&
        !_hasConfiguredImage(effectiveDarkImageUrl)) {
      return null;
    }

    return HomeTopChromeBackdrop(
      assetName: effectiveAssetName,
      imageUrl: effectiveImageUrl,
      darkAssetName: effectiveDarkAssetName,
      darkImageUrl: effectiveDarkImageUrl,
      imageAlignment:
          topSurfaceMode == MediaChannelTopSurfaceMode.customImage &&
              style.surfaceMode == MediaChannelSurfaceMode.immersive
          ? Alignment.topCenter
          : Alignment.bottomCenter,
      blendMode: pageBackdropBlendModeFor(style),
      blendColor: blendColorFor(style, backgroundColor),
    );
  }

  MediaChannelTopSurfaceMode effectiveTopSurfaceMode(MediaChannelStyle style) {
    if (style.topSurfaceMode != MediaChannelTopSurfaceMode.brand) {
      return style.topSurfaceMode;
    }
    if (style.surfaceMode == MediaChannelSurfaceMode.immersive ||
        hasTopChromeBackdrop(style)) {
      return MediaChannelTopSurfaceMode.customImage;
    }
    return MediaChannelTopSurfaceMode.brand;
  }

  MediaChannelTopBackgroundMode effectiveTopBackgroundMode(
    MediaChannelStyle style,
  ) {
    if (style.topBackground.mode != MediaChannelTopBackgroundMode.brandImage) {
      return style.topBackground.mode;
    }
    return switch (style.topSurfaceMode) {
      MediaChannelTopSurfaceMode.brand =>
        MediaChannelTopBackgroundMode.brandImage,
      MediaChannelTopSurfaceMode.channelColor =>
        MediaChannelTopBackgroundMode.color,
      MediaChannelTopSurfaceMode.customImage =>
        MediaChannelTopBackgroundMode.customImage,
    };
  }

  PageBackdropBlendMode pageBackdropBlendModeFor(MediaChannelStyle style) {
    return switch (style.backdropBlendMode) {
      MediaChannelBackdropBlendMode.fadeToSurface =>
        PageBackdropBlendMode.fadeToSurface,
      MediaChannelBackdropBlendMode.fadeToColor =>
        PageBackdropBlendMode.fadeToColor,
      MediaChannelBackdropBlendMode.none => PageBackdropBlendMode.none,
    };
  }

  Color? blendColorFor(MediaChannelStyle style, Color backgroundColor) {
    return switch (style.backdropBlendMode) {
      MediaChannelBackdropBlendMode.fadeToColor =>
        style.contentBackground.startColor ??
            style.topBackground.endColor ??
            backgroundColor,
      MediaChannelBackdropBlendMode.fadeToSurface ||
      MediaChannelBackdropBlendMode.none => null,
    };
  }

  bool hasTopChromeBackdrop(MediaChannelStyle style) {
    return _hasConfiguredImage(style.backdropAssetName) ||
        _hasConfiguredImage(style.backdropImageUrl) ||
        _hasConfiguredImage(style.darkBackdropAssetName) ||
        _hasConfiguredImage(style.darkBackdropImageUrl);
  }

  String? resolveTopChromeBackdropAsset({
    required MediaChannelStyle style,
    required bool dark,
    required AppBrandId brandId,
    required MediaChannelTopSurfaceMode topSurfaceMode,
  }) {
    if (topSurfaceMode == MediaChannelTopSurfaceMode.customImage) {
      if (dark) {
        final asset = style.darkBackdropAssetName;
        if (asset != null && asset.isNotEmpty) return asset;
        final immersiveAsset = style.darkImmersiveBackdropAssetName;
        if (immersiveAsset != null && immersiveAsset.isNotEmpty) {
          return immersiveAsset;
        }
        return null;
      }
      final asset = style.backdropAssetName;
      if (asset != null && asset.isNotEmpty) return asset;
      if (style.surfaceMode == MediaChannelSurfaceMode.immersive) {
        final asset = style.immersiveBackdropAssetName;
        if (asset != null && asset.isNotEmpty) return asset;
      }
      return null;
    }
    return AppAssets.topLevelHeaderImage(brandId);
  }

  String? resolveTopChromeBackdropUrl({
    required MediaChannelStyle style,
    required bool dark,
    required MediaChannelTopSurfaceMode topSurfaceMode,
  }) {
    if (topSurfaceMode == MediaChannelTopSurfaceMode.customImage) {
      if (dark) {
        final url = style.darkBackdropImageUrl;
        if (url != null && url.isNotEmpty) return url;
        final immersiveUrl = style.darkImmersiveBackdropImageUrl;
        if (immersiveUrl != null && immersiveUrl.isNotEmpty) {
          return immersiveUrl;
        }
        return null;
      }
      final url = style.backdropImageUrl;
      if (url != null && url.isNotEmpty) return url;
      if (style.surfaceMode == MediaChannelSurfaceMode.immersive) {
        final url = style.immersiveBackdropImageUrl;
        if (url != null && url.isNotEmpty) return url;
      }
      return null;
    }
    return null;
  }

  Color backgroundFor(
    BuildContext context,
    MediaChannelStyle style,
    Color fallback,
  ) {
    return _backgroundFor(context, style, fallback);
  }

  double chromeDarkFactorFor(Color color) => _chromeDarkFactorFor(color);

  Color _backgroundFor(
    BuildContext context,
    MediaChannelStyle style,
    Color fallback,
  ) {
    if (ThemeData.estimateBrightnessForColor(fallback) == Brightness.dark) {
      return fallback;
    }
    return style.backgroundColor ?? fallback;
  }

  double _chromeDarkFactorFor(Color color) {
    return ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? 1
        : 0;
  }

  bool _hasConfiguredImage(String? value) => value != null && value.isNotEmpty;
}

class HomeTopChromeBackdrop {
  const HomeTopChromeBackdrop({
    this.assetName,
    this.imageUrl,
    this.darkAssetName,
    this.darkImageUrl,
    required this.imageAlignment,
    this.blendMode = PageBackdropBlendMode.fadeToSurface,
    this.blendColor,
  }) : gradient = false,
       solidColor = null,
       startColor = null,
       middleColor = null,
       endColor = null,
       colors = null,
       stops = null,
       height = null;

  const HomeTopChromeBackdrop.gradient({
    required Color this.startColor,
    required Color this.middleColor,
    required Color this.endColor,
    this.colors,
    this.stops,
    this.height,
    this.blendMode = PageBackdropBlendMode.fadeToSurface,
    this.blendColor,
  }) : gradient = true,
       solidColor = null,
       assetName = null,
       imageUrl = null,
       darkAssetName = null,
       darkImageUrl = null,
       imageAlignment = Alignment.bottomCenter;

  const HomeTopChromeBackdrop.solid({
    required Color color,
    this.height,
    this.blendMode = PageBackdropBlendMode.none,
    this.blendColor,
  }) : gradient = false,
       solidColor = color,
       assetName = null,
       imageUrl = null,
       darkAssetName = null,
       darkImageUrl = null,
       imageAlignment = Alignment.bottomCenter,
       startColor = null,
       middleColor = null,
       endColor = null,
       colors = null,
       stops = null;

  final bool gradient;
  final Color? solidColor;
  final String? assetName;
  final String? imageUrl;
  final String? darkAssetName;
  final String? darkImageUrl;
  final AlignmentGeometry imageAlignment;
  final Color? startColor;
  final Color? middleColor;
  final Color? endColor;
  final List<Color>? colors;
  final List<double>? stops;
  final double? height;
  final PageBackdropBlendMode blendMode;
  final Color? blendColor;
}
