import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_appearance.dart';
import '../theme/app_spacing.dart';

class PageSurface {
  const PageSurface({
    this.backgroundColor,
    this.backdrop,
    this.frameBackground,
    this.chromeDarkFactor,
  });

  final Color? backgroundColor;
  final PageBackdrop? backdrop;
  final PageFrameBackground? frameBackground;
  final double? chromeDarkFactor;

  PageSurface copyWith({
    Color? backgroundColor,
    PageBackdrop? backdrop,
    PageFrameBackground? frameBackground,
    double? chromeDarkFactor,
  }) {
    return PageSurface(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backdrop: backdrop ?? this.backdrop,
      frameBackground: frameBackground ?? this.frameBackground,
      chromeDarkFactor: chromeDarkFactor ?? this.chromeDarkFactor,
    );
  }
}

double topLevelBackdropChromeHeight({
  required double topPadding,
  bool reserveToolbarSlot = true,
  bool includePinnedChannels = false,
}) {
  return topPadding +
      (reserveToolbarSlot ? AppSpacing.topLevelToolbarHeight : 0) +
      (includePinnedChannels ? AppSpacing.topLevelPinnedChannelHeight : 0);
}

enum PageBackdropPreset { softBrand }

enum PageBackdropBlendMode { fadeToSurface, fadeToColor, none }

class PageBackdrop {
  const PageBackdrop({
    this.enabled = true,
    this.preset = PageBackdropPreset.softBrand,
    this.assetName,
    this.imageUrl,
    this.darkAssetName,
    this.darkImageUrl,
    this.height = AppSpacing.topLevelBackdropHeight,
    this.strength = 1,
    this.imageOpacity = 1,
    required this.startColor,
    required this.middleColor,
    required this.endColor,
    List<Color>? colors,
    List<double>? stops,
    this.solidColor,
    this.imageAlignment = Alignment.bottomCenter,
    this.blendMode = PageBackdropBlendMode.fadeToSurface,
    this.blendColor,
  }) : colors = colors ?? const [],
       stops = stops ?? const [0, 0.52, 1];

  final bool enabled;
  final PageBackdropPreset preset;
  final String? assetName;
  final String? imageUrl;
  final String? darkAssetName;
  final String? darkImageUrl;
  final double height;
  final double strength;
  final double imageOpacity;
  final Color startColor;
  final Color middleColor;
  final Color endColor;
  final List<Color> colors;
  final List<double> stops;
  final Color? solidColor;
  final AlignmentGeometry imageAlignment;
  final PageBackdropBlendMode blendMode;
  final Color? blendColor;

  bool get hasImage =>
      (assetName != null && assetName!.isNotEmpty) ||
      (imageUrl != null && imageUrl!.isNotEmpty) ||
      hasDarkImage;

  bool get hasDarkImage =>
      (darkAssetName != null && darkAssetName!.isNotEmpty) ||
      (darkImageUrl != null && darkImageUrl!.isNotEmpty);

  static PageBackdrop brand({
    required AppThemeTokens tokens,
    required Color endColor,
    double height = AppSpacing.topLevelBackdropHeight,
    double strength = 1,
    double imageOpacity = 1,
    AlignmentGeometry imageAlignment = Alignment.bottomCenter,
    PageBackdropBlendMode blendMode = PageBackdropBlendMode.fadeToSurface,
    Color? blendColor,
  }) {
    final brand = tokens.brand;
    final dark =
        ThemeData.estimateBrightnessForColor(endColor) == Brightness.dark;
    if (dark) {
      return PageBackdrop(
        preset: PageBackdropPreset.softBrand,
        height: height,
        enabled: false,
        strength: strength,
        imageOpacity: imageOpacity,
        startColor: endColor,
        middleColor: endColor,
        endColor: endColor,
        imageAlignment: imageAlignment,
        blendMode: blendMode,
        blendColor: blendColor,
      );
    }

    return PageBackdrop(
      preset: PageBackdropPreset.softBrand,
      height: height,
      strength: strength,
      imageOpacity: imageOpacity,
      startColor: brand.gradientStart,
      middleColor: brand.gradientMiddle,
      endColor: endColor,
      colors: [brand.gradientStart, brand.gradientMiddle, endColor],
      stops: const [0, 0.35, 1],
      imageAlignment: imageAlignment,
      blendMode: blendMode,
      blendColor: blendColor,
    );
  }

  static PageBackdrop image({
    required AppThemeTokens tokens,
    required Color endColor,
    String? assetName,
    String? imageUrl,
    String? darkAssetName,
    String? darkImageUrl,
    bool? enabled,
    double height = AppSpacing.topLevelBackdropHeight,
    double strength = 1,
    double imageOpacity = 1,
    AlignmentGeometry imageAlignment = Alignment.bottomCenter,
    PageBackdropBlendMode blendMode = PageBackdropBlendMode.fadeToSurface,
    Color? blendColor,
  }) {
    assert(
      (assetName == null || assetName.isEmpty) ||
          (imageUrl == null || imageUrl.isEmpty),
      'Use either assetName or imageUrl for PageBackdrop.image, not both.',
    );
    assert(
      (darkAssetName == null || darkAssetName.isEmpty) ||
          (darkImageUrl == null || darkImageUrl.isEmpty),
      'Use either darkAssetName or darkImageUrl for PageBackdrop.image, not both.',
    );
    final fallback = PageBackdrop.brand(
      tokens: tokens,
      endColor: endColor,
      height: height,
      strength: strength,
      imageAlignment: imageAlignment,
    );

    return PageBackdrop(
      preset: fallback.preset,
      enabled: enabled ?? fallback.enabled,
      assetName: assetName,
      imageUrl: imageUrl,
      darkAssetName: darkAssetName,
      darkImageUrl: darkImageUrl,
      height: fallback.height,
      strength: fallback.strength,
      imageOpacity: imageOpacity,
      startColor: fallback.startColor,
      middleColor: fallback.middleColor,
      endColor: fallback.endColor,
      colors: fallback.colors,
      stops: fallback.stops,
      imageAlignment: imageAlignment,
      blendMode: blendMode,
      blendColor: blendColor,
    );
  }

  static PageBackdrop gradient({
    required Color startColor,
    required Color middleColor,
    required Color endColor,
    List<Color>? colors,
    List<double>? stops,
    double height = AppSpacing.topLevelBackdropHeight,
    double strength = 1,
    PageBackdropBlendMode blendMode = PageBackdropBlendMode.fadeToSurface,
    Color? blendColor,
  }) {
    return PageBackdrop(
      height: height,
      strength: strength,
      startColor: startColor,
      middleColor: middleColor,
      endColor: endColor,
      colors: colors,
      stops: stops,
      blendMode: blendMode,
      blendColor: blendColor,
    );
  }

  static PageBackdrop solid({
    required Color color,
    double height = AppSpacing.topLevelBackdropHeight,
    double strength = 1,
    PageBackdropBlendMode blendMode = PageBackdropBlendMode.none,
    Color? blendColor,
  }) {
    return PageBackdrop(
      height: height,
      strength: strength,
      startColor: color,
      middleColor: color,
      endColor: color,
      solidColor: color,
      blendMode: blendMode,
      blendColor: blendColor,
    );
  }
}

class PageFrameBackground {
  const PageFrameBackground.gradientRelay({
    required this.topStartColor,
    required this.topMiddleColor,
    required this.joinColor,
    required this.contentEndColor,
    this.topHeight,
    this.contentHeight = 220,
    this.strength = 1,
  });

  final Color topStartColor;
  final Color topMiddleColor;
  final Color joinColor;
  final Color contentEndColor;
  final double? topHeight;
  final double contentHeight;
  final double strength;

  PageFrameBackground copyWith({double? strength}) {
    return PageFrameBackground.gradientRelay(
      topStartColor: topStartColor,
      topMiddleColor: topMiddleColor,
      joinColor: joinColor,
      contentEndColor: contentEndColor,
      topHeight: topHeight,
      contentHeight: contentHeight,
      strength: strength ?? this.strength,
    );
  }
}

enum TopLevelPageScaffoldMode { plain, scrollEdgeTitle }

typedef TopLevelBackdropCanvasHeightBuilder =
    double Function(BuildContext context);

enum TopLevelScrollEdgeTitleBehavior { revealOnScroll, visibleAtEdge }

enum TopLevelScrollEdgeTitleAlignment { leading, center }

class TopLevelChromeBackground {
  const TopLevelChromeBackground({
    required this.mode,
    this.solidColor,
    this.initialOpacity = 0,
    this.midOpacity = 0.42,
  });

  const TopLevelChromeBackground.transparent()
    : mode = TopLevelChromeBackgroundMode.transparent,
      solidColor = null,
      initialOpacity = 0,
      midOpacity = 0;

  const TopLevelChromeBackground.transparentToSolid({
    required Color solidColor,
    double initialOpacity = 0,
    double midOpacity = 0.42,
  }) : this(
         mode: TopLevelChromeBackgroundMode.transparentToSolid,
         solidColor: solidColor,
         initialOpacity: initialOpacity,
         midOpacity: midOpacity,
       );

  final TopLevelChromeBackgroundMode mode;
  final Color? solidColor;
  final double initialOpacity;
  final double midOpacity;
}

enum TopLevelChromeBackgroundMode { transparent, transparentToSolid }

class TopLevelPageScaffold extends StatefulWidget {
  const TopLevelPageScaffold({
    super.key,
    required this.title,
    required this.slivers,
    this.surface = const PageSurface(),
    this.mode = TopLevelPageScaffoldMode.plain,
    this.scrollEdgeTitleBehavior =
        TopLevelScrollEdgeTitleBehavior.revealOnScroll,
    this.scrollEdgeTitleAlignment = TopLevelScrollEdgeTitleAlignment.leading,
    this.scrollEdgeTitleBarEnabled = true,
    this.reserveToolbarSlot = false,
    this.actions = const [],
    this.toolbar,
    this.chromeBackground = const TopLevelChromeBackground.transparent(),
    this.backdropCanvasHeightBuilder,
    this.scrollToTopRequest = 0,
    this.onScrollToTop,
    this.controller,
  });

  final String title;
  final List<Widget> slivers;
  final PageSurface surface;
  final TopLevelPageScaffoldMode mode;
  final TopLevelScrollEdgeTitleBehavior scrollEdgeTitleBehavior;
  final TopLevelScrollEdgeTitleAlignment scrollEdgeTitleAlignment;
  final bool scrollEdgeTitleBarEnabled;
  final bool reserveToolbarSlot;
  final List<Widget> actions;
  final Widget? toolbar;
  final TopLevelChromeBackground chromeBackground;
  final TopLevelBackdropCanvasHeightBuilder? backdropCanvasHeightBuilder;
  final int scrollToTopRequest;
  final Future<void> Function()? onScrollToTop;
  final ScrollController? controller;

  static const scrollToTopDuration = Duration(milliseconds: 1000);
  static const scrollToTopCurve = Curves.easeOutCirc;

  @override
  State<TopLevelPageScaffold> createState() => _TopLevelPageScaffoldState();
}

class _TopLevelPageScaffoldState extends State<TopLevelPageScaffold> {
  static const _titleRevealStart = 72.0;
  static const _titleRevealDistance = 56.0;

  late final ScrollController _fallbackController;
  double _scrollEdgeProgress = 0;

  ScrollController get _controller => widget.controller ?? _fallbackController;
  bool get _usesScrollEdgeTitle =>
      widget.mode == TopLevelPageScaffoldMode.scrollEdgeTitle;
  bool get _showsPageToolbarControls =>
      widget.scrollEdgeTitleBarEnabled &&
      (_usesScrollEdgeTitle || widget.toolbar != null);
  bool get _reservesPageToolbarSlot =>
      _showsPageToolbarControls || widget.reserveToolbarSlot;

  @override
  void initState() {
    super.initState();
    _fallbackController = ScrollController();
    _controller.addListener(_handleControllerScroll);
  }

  @override
  void didUpdateWidget(covariant TopLevelPageScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldController = oldWidget.controller ?? _fallbackController;
    final nextController = _controller;
    if (oldController != nextController) {
      oldController.removeListener(_handleControllerScroll);
      nextController.addListener(_handleControllerScroll);
    }
    if (oldWidget.scrollToTopRequest != widget.scrollToTopRequest) {
      unawaited(_handleScrollToTopRequest());
    }
    _handleControllerScroll();
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerScroll);
    _fallbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surface = widget.surface.resolve(context);
    final backdropCanvasHeight = _resolveBackdropCanvasHeight(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      key: Key('top-level-system-overlay-${widget.title}'),
      value: surface.systemOverlayStyle,
      child: ColoredBox(
        key: Key('top-level-background-${widget.title}'),
        color: surface.backgroundColor,
        child: Stack(
          children: [
            _TopLevelFrameBackgroundLayer(
              title: widget.title,
              surface: surface,
              topBackdropHeight: backdropCanvasHeight,
            ),
            _TopLevelBackdropLayer(
              title: widget.title,
              surface: surface,
              height: backdropCanvasHeight,
            ),
            Column(
              children: [
                if (_reservesPageToolbarSlot)
                  _PageToolbarSlot(
                    title: widget.title,
                    showControls: _showsPageToolbarControls,
                    titleBehavior: widget.scrollEdgeTitleBehavior,
                    titleAlignment: widget.scrollEdgeTitleAlignment,
                    actions: widget.actions,
                    toolbar: widget.toolbar,
                    chromeBackground: widget.chromeBackground,
                    progress: _scrollEdgeProgress,
                  ),
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: _handleScrollNotification,
                    child: CustomScrollView(
                      key: Key('top-level-scroll-${widget.title}'),
                      controller: _controller,
                      slivers: [
                        if (!_reservesPageToolbarSlot)
                          _TopSafeAreaSpacerSliver(title: widget.title),
                        ...widget.slivers,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _resolveBackdropCanvasHeight(BuildContext context) {
    final builder = widget.backdropCanvasHeightBuilder;
    if (builder != null) return builder(context);

    return topLevelBackdropChromeHeight(
      topPadding: MediaQuery.paddingOf(context).top,
      reserveToolbarSlot: _reservesPageToolbarSlot,
    );
  }

  void _handleControllerScroll() {
    if (!_showsPageToolbarControls || !_controller.hasClients) {
      _setScrollEdgeProgress(0);
      return;
    }
    _setScrollEdgeProgress(_controller.offset);
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical ||
        !_showsPageToolbarControls) {
      return false;
    }
    _setScrollEdgeProgress(notification.metrics.pixels);
    return false;
  }

  void _setScrollEdgeProgress(double offset) {
    final nextProgress = _showsPageToolbarControls
        ? ((offset - _titleRevealStart) / _titleRevealDistance)
              .clamp(0.0, 1.0)
              .toDouble()
        : 0.0;
    if ((nextProgress - _scrollEdgeProgress).abs() < 0.01) return;
    setState(() => _scrollEdgeProgress = nextProgress);
  }

  Future<void> _handleScrollToTopRequest() async {
    final customHandler = widget.onScrollToTop;
    if (customHandler != null) {
      await customHandler();
      return;
    }
    await _animateControllerToTop(_controller);
  }

  Future<void> _animateControllerToTop(ScrollController controller) {
    if (!controller.hasClients || controller.offset <= 0) {
      return Future<void>.value();
    }
    return controller.animateTo(
      0,
      duration: TopLevelPageScaffold.scrollToTopDuration,
      curve: TopLevelPageScaffold.scrollToTopCurve,
    );
  }
}

class _TopLevelFrameBackgroundLayer extends StatelessWidget {
  const _TopLevelFrameBackgroundLayer({
    required this.title,
    required this.surface,
    required this.topBackdropHeight,
  });

  final String title;
  final ResolvedPageSurface surface;
  final double topBackdropHeight;

  @override
  Widget build(BuildContext context) {
    final frameBackground = surface.frameBackground;
    if (frameBackground == null) return const SizedBox.shrink();

    return Positioned.fill(
      child: IgnorePointer(
        key: Key('top-level-frame-background-$title'),
        child: _PageFrameBackgroundView(
          surface: surface,
          topBackdropHeight: topBackdropHeight,
        ),
      ),
    );
  }
}

class _TopLevelBackdropLayer extends StatelessWidget {
  const _TopLevelBackdropLayer({
    required this.title,
    required this.surface,
    required this.height,
  });

  final String title;
  final ResolvedPageSurface surface;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        key: Key('top-level-scroll-edge-backdrop-$title'),
        child: Align(
          alignment: Alignment.topCenter,
          child: PageBackdropView(
            surface: surface,
            height: height,
            debugKeyPrefix: 'top-level-scroll-edge-backdrop-$title',
          ),
        ),
      ),
    );
  }
}

class _PageToolbarSlot extends StatelessWidget {
  const _PageToolbarSlot({
    required this.title,
    required this.showControls,
    required this.titleBehavior,
    required this.titleAlignment,
    required this.actions,
    required this.toolbar,
    required this.chromeBackground,
    required this.progress,
  });

  final String title;
  final bool showControls;
  final TopLevelScrollEdgeTitleBehavior titleBehavior;
  final TopLevelScrollEdgeTitleAlignment titleAlignment;
  final List<Widget> actions;
  final Widget? toolbar;
  final TopLevelChromeBackground chromeBackground;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final height = topPadding + AppSpacing.topLevelToolbarHeight;
    final trailingInset = actions.isEmpty
        ? AppSpacing.pageX
        : AppSpacing.pageX +
              actions.length * AppSpacing.minTouchTarget +
              AppSpacing.sm;
    final centered = titleAlignment == TopLevelScrollEdgeTitleAlignment.center;
    final backgroundOpacity = _backgroundOpacity(progress);
    final backgroundColor = chromeBackground.solidColor;

    final toolbarStack = Stack(
      children: [
        if (backgroundColor != null && backgroundOpacity > 0)
          Positioned.fill(
            child: ColoredBox(
              key: Key('top-level-toolbar-background-$title'),
              color: backgroundColor.withValues(alpha: backgroundOpacity),
            ),
          ),
        Positioned(
          left: toolbar == null && centered ? trailingInset : AppSpacing.pageX,
          right: toolbar == null && centered ? trailingInset : trailingInset,
          top: topPadding,
          height: AppSpacing.topLevelToolbarHeight,
          child:
              toolbar ??
              _DefaultPageToolbarTitle(
                title: title,
                opacity:
                    titleBehavior ==
                        TopLevelScrollEdgeTitleBehavior.visibleAtEdge
                    ? 1
                    : progress,
                titleAlignment: titleAlignment,
              ),
        ),
        if (actions.isNotEmpty)
          _PageToolbarActions(actions: actions, top: topPadding),
      ],
    );

    return SizedBox(
      key: Key('top-level-toolbar-slot-$title'),
      height: height,
      child: showControls
          ? SizedBox.expand(
              key: Key('top-level-toolbar-$title'),
              child: toolbarStack,
            )
          : const SizedBox.shrink(),
    );
  }

  double _backgroundOpacity(double progress) {
    return switch (chromeBackground.mode) {
      TopLevelChromeBackgroundMode.transparent => 0,
      TopLevelChromeBackgroundMode.transparentToSolid =>
        progress < 0.5
            ? _lerp(
                chromeBackground.initialOpacity,
                chromeBackground.midOpacity,
                progress / 0.5,
              )
            : _lerp(chromeBackground.midOpacity, 1, (progress - 0.5) / 0.5),
    };
  }

  double _lerp(double begin, double end, double t) {
    return begin + (end - begin) * t.clamp(0.0, 1.0);
  }
}

class _DefaultPageToolbarTitle extends StatelessWidget {
  const _DefaultPageToolbarTitle({
    required this.title,
    required this.opacity,
    required this.titleAlignment,
  });

  final String title;
  final double opacity;
  final TopLevelScrollEdgeTitleAlignment titleAlignment;

  @override
  Widget build(BuildContext context) {
    final centered = titleAlignment == TopLevelScrollEdgeTitleAlignment.center;

    return IgnorePointer(
      ignoring: opacity < 0.08,
      child: Opacity(
        key: Key('top-level-title-opacity-$title'),
        opacity: opacity,
        child: Align(
          key: Key('top-level-title-alignment-$title'),
          alignment: centered ? Alignment.center : Alignment.centerLeft,
          child: KeyedSubtree(
            key: Key('top-level-toolbar-title-$title'),
            child: Text(
              title,
              key: Key('top-level-scroll-edge-title-$title'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.typography.sectionTitle.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PageToolbarActions extends StatelessWidget {
  const _PageToolbarActions({required this.actions, required this.top});

  final List<Widget> actions;
  final double top;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: AppSpacing.sm,
      top: top,
      height: AppSpacing.topLevelToolbarHeight,
      child: Center(
        child: Row(mainAxisSize: MainAxisSize.min, children: actions),
      ),
    );
  }
}

class PageBackdropView extends StatelessWidget {
  const PageBackdropView({
    super.key,
    required this.surface,
    this.height,
    this.debugKeyPrefix,
  });

  final ResolvedPageSurface surface;
  final double? height;
  final String? debugKeyPrefix;

  @override
  Widget build(BuildContext context) {
    final backdrop = surface.backdrop;
    final dark = surface.isDarkBackground;
    final child = !backdrop.enabled
        ? _emptyBackdrop()
        : backdrop.hasImage
        ? _ImageBackdrop(
            surface: surface,
            debugKeyPrefix: debugKeyPrefix,
            fallback: dark ? _emptyBackdrop() : _gradientBackdrop(),
          )
        : _gradientBackdrop();

    final children = <Widget>[child];
    if (backdrop.enabled && backdrop.blendMode != PageBackdropBlendMode.none) {
      children.add(_blendMask());
    }

    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        key: _debugKey('page-backdrop-surface'),
        width: double.infinity,
        height: height ?? backdrop.height,
        child: Stack(fit: StackFit.expand, children: children),
      ),
    );
  }

  Widget _emptyBackdrop() {
    return ColoredBox(
      key: _debugKey('page-backdrop-empty'),
      color: surface.backgroundColor,
    );
  }

  Widget _gradientBackdrop() {
    final solidColor = surface.backdrop.solidColor;
    if (solidColor != null) {
      return ColoredBox(
        key: _debugKey('page-backdrop-solid'),
        color: _strengthColor(solidColor),
      );
    }

    return DecoratedBox(
      key: _debugKey('page-backdrop-gradient'),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _gradientColors(surface.backdrop),
          stops: _gradientStops(surface.backdrop),
        ),
      ),
    );
  }

  Widget _blendMask() {
    final targetColor = switch (surface.backdrop.blendMode) {
      PageBackdropBlendMode.fadeToSurface => surface.backgroundColor,
      PageBackdropBlendMode.fadeToColor =>
        surface.backdrop.blendColor ?? surface.backgroundColor,
      PageBackdropBlendMode.none => surface.backgroundColor,
    };

    return DecoratedBox(
      key: _debugKey('page-backdrop-blend-mask'),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [targetColor.withValues(alpha: 0), targetColor],
          stops: const [0, 1],
        ),
      ),
    );
  }

  List<Color> _gradientColors(PageBackdrop backdrop) {
    final colors = backdrop.colors.isEmpty
        ? [backdrop.startColor, backdrop.middleColor, backdrop.endColor]
        : backdrop.colors;
    final strength = backdrop.strength.clamp(0.0, 1.0);
    if (strength == 1) return colors;
    return [
      for (final color in colors)
        Color.lerp(surface.backgroundColor, color, strength)!,
    ];
  }

  Color _strengthColor(Color color) {
    final strength = surface.backdrop.strength.clamp(0.0, 1.0);
    if (strength == 1) return color;
    return Color.lerp(surface.backgroundColor, color, strength)!;
  }

  List<double>? _gradientStops(PageBackdrop backdrop) {
    final colors = _gradientColors(backdrop);
    if (backdrop.stops.length != colors.length) return null;
    return backdrop.stops;
  }

  Key _debugKey(String value) {
    final prefix = debugKeyPrefix;
    if (prefix == null || prefix.isEmpty) return Key(value);
    return Key('$prefix-$value');
  }
}

class PageBackdropSlice extends StatelessWidget {
  const PageBackdropSlice({
    super.key,
    required this.surface,
    required this.sliceTop,
    required this.sliceHeight,
    this.canvasHeight,
    this.debugKeyPrefix,
  });

  final ResolvedPageSurface surface;
  final double sliceTop;
  final double sliceHeight;
  final double? canvasHeight;
  final String? debugKeyPrefix;

  @override
  Widget build(BuildContext context) {
    final effectiveCanvasHeight = canvasHeight ?? surface.backdrop.height;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return SizedBox(
          key: _debugKey('page-backdrop-slice'),
          width: double.infinity,
          height: sliceHeight,
          child: ClipRect(
            child: Transform.translate(
              offset: Offset(0, -sliceTop),
              child: OverflowBox(
                alignment: Alignment.topCenter,
                minWidth: width,
                maxWidth: width,
                minHeight: effectiveCanvasHeight,
                maxHeight: effectiveCanvasHeight,
                child: SizedBox(
                  width: width,
                  height: effectiveCanvasHeight,
                  child: PageBackdropView(
                    surface: surface,
                    height: effectiveCanvasHeight,
                    debugKeyPrefix: debugKeyPrefix,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Key _debugKey(String value) {
    final prefix = debugKeyPrefix;
    if (prefix == null || prefix.isEmpty) return Key(value);
    return Key('$prefix-$value');
  }
}

class _PageFrameBackgroundView extends StatelessWidget {
  const _PageFrameBackgroundView({
    required this.surface,
    required this.topBackdropHeight,
  });

  final ResolvedPageSurface surface;
  final double topBackdropHeight;

  @override
  Widget build(BuildContext context) {
    final background = surface.frameBackground;
    if (background == null) return const SizedBox.shrink();

    final topHeight = (background.topHeight ?? topBackdropHeight)
        .clamp(0.0, double.infinity)
        .toDouble();
    final contentHeight = background.contentHeight
        .clamp(0.0, double.infinity)
        .toDouble();
    final totalHeight = topHeight + contentHeight;

    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        key: const Key('page-frame-gradient-relay'),
        width: double.infinity,
        height: totalHeight,
        child: DecoratedBox(
          key: const Key('page-frame-gradient-relay-fill'),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: _gradientColors(background),
              stops: _gradientStops(topHeight, totalHeight),
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _gradientColors(PageFrameBackground background) {
    final strength = background.strength.clamp(0.0, 1.0);
    final colors = [
      background.topStartColor,
      background.topMiddleColor,
      background.joinColor,
      background.contentEndColor,
    ];
    if (strength == 1) return colors;
    return [
      for (final color in colors)
        Color.lerp(surface.backgroundColor, color, strength)!,
    ];
  }

  List<double> _gradientStops(double topHeight, double totalHeight) {
    if (totalHeight <= 0) return const [0, 0.46, 0.72, 1];

    final joinStop = (topHeight / totalHeight).clamp(0.0, 1.0).toDouble();
    final middleStop = (joinStop * 0.46).clamp(0.0, joinStop).toDouble();
    return [0, middleStop, joinStop, 1];
  }
}

class PageTopSurfaceBackground extends StatelessWidget {
  const PageTopSurfaceBackground({
    super.key,
    required this.surface,
    required this.height,
    this.debugKeyPrefix,
    this.backgroundKey,
    this.showDivider = true,
  });

  final ResolvedPageSurface surface;
  final double height;
  final String? debugKeyPrefix;
  final Key? backgroundKey;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: backgroundKey,
      width: double.infinity,
      height: height,
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageBackdropView(
              surface: surface,
              height: height,
              debugKeyPrefix: debugKeyPrefix,
            ),
            if (showDivider)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 1 / MediaQuery.devicePixelRatioOf(context),
                child: ColoredBox(
                  key: _debugKey('page-top-surface-divider'),
                  color: context.tokens.divider,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Key _debugKey(String value) {
    final prefix = debugKeyPrefix;
    if (prefix == null || prefix.isEmpty) return Key(value);
    return Key('$prefix-$value');
  }
}

class _ImageBackdrop extends StatelessWidget {
  const _ImageBackdrop({
    required this.surface,
    required this.fallback,
    this.debugKeyPrefix,
  });

  final ResolvedPageSurface surface;
  final Widget fallback;
  final String? debugKeyPrefix;

  @override
  Widget build(BuildContext context) {
    final backdrop = surface.backdrop;
    final dark = surface.isDarkBackground;
    final useDarkImage = dark && backdrop.hasDarkImage;
    final assetName = useDarkImage
        ? backdrop.darkAssetName
        : backdrop.assetName;
    final imageUrl = useDarkImage ? backdrop.darkImageUrl : backdrop.imageUrl;
    if ((assetName == null || assetName.isEmpty) &&
        (imageUrl == null || imageUrl.isEmpty)) {
      return fallback;
    }

    final imageOpacity = backdrop.imageOpacity.clamp(0.0, 1.0).toDouble();
    Widget image = assetName != null && assetName.isNotEmpty
        ? Image.asset(
            assetName,
            key: _debugKey('page-backdrop-image-asset'),
            fit: BoxFit.cover,
            alignment: backdrop.imageAlignment,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, _, _) => fallback,
          )
        : Image.network(
            imageUrl!,
            key: _debugKey('page-backdrop-image-network'),
            fit: BoxFit.cover,
            alignment: backdrop.imageAlignment,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, _, _) => fallback,
          );

    if (imageOpacity >= 1) return image;
    return Opacity(
      key: _debugKey('page-backdrop-image-opacity'),
      opacity: imageOpacity,
      child: image,
    );
  }

  Key _debugKey(String value) {
    final prefix = debugKeyPrefix;
    if (prefix == null || prefix.isEmpty) return Key(value);
    return Key('$prefix-$value');
  }
}

class ResolvedPageSurface {
  const ResolvedPageSurface({
    required this.backgroundColor,
    required this.backdrop,
    this.frameBackground,
    this.chromeDarkFactor,
  });

  final Color backgroundColor;
  final PageBackdrop backdrop;
  final PageFrameBackground? frameBackground;
  final double? chromeDarkFactor;

  bool get isDarkBackground =>
      ThemeData.estimateBrightnessForColor(backgroundColor) == Brightness.dark;

  SystemUiOverlayStyle get systemOverlayStyle {
    final iconBrightness = isDarkBackground
        ? Brightness.light
        : Brightness.dark;
    final statusBarBrightness = isDarkBackground
        ? Brightness.dark
        : Brightness.light;

    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: iconBrightness,
      statusBarBrightness: statusBarBrightness,
      systemStatusBarContrastEnforced: false,
    );
  }
}

class _TopSafeAreaSpacerSliver extends StatelessWidget {
  const _TopSafeAreaSpacerSliver({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return SliverToBoxAdapter(
      child: SizedBox(
        key: Key('top-level-safe-area-spacer-$title'),
        height: topPadding,
      ),
    );
  }
}

extension PageSurfaceResolve on PageSurface {
  ResolvedPageSurface resolve(BuildContext context) {
    final tokens = context.tokens;
    final resolvedBackground = backgroundColor ?? tokens.pageBackground;
    final resolvedBackdrop =
        backdrop ??
        PageBackdrop.brand(tokens: tokens, endColor: resolvedBackground);

    return ResolvedPageSurface(
      backgroundColor: resolvedBackground,
      backdrop: resolvedBackdrop,
      frameBackground: frameBackground,
      chromeDarkFactor: chromeDarkFactor,
    );
  }
}
