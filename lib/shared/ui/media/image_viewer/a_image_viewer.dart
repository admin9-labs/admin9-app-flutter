import 'package:extended_image/extended_image.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import 'a_image_viewer_item.dart';

class AImageViewer extends StatefulWidget {
  const AImageViewer({
    super.key,
    required this.items,
    required this.initialIndex,
    required this.onClose,
  }) : assert(items.length > 0),
       assert(initialIndex >= 0 && initialIndex < items.length);

  final List<AImageViewerItem> items;
  final int initialIndex;
  final VoidCallback onClose;

  @override
  State<AImageViewer> createState() => _AImageViewerState();
}

class _AImageViewerState extends State<AImageViewer>
    with SingleTickerProviderStateMixin {
  late final ExtendedPageController _pageController;
  late final AnimationController _doubleTapController;
  Animation<double>? _doubleTapAnimation;
  VoidCallback? _doubleTapListener;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = ExtendedPageController(initialPage: _currentIndex);
    _doubleTapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
  }

  @override
  void dispose() {
    if (_doubleTapListener case final listener?) {
      _doubleTapAnimation?.removeListener(listener);
    }
    _doubleTapController.dispose();
    _pageController.dispose();
    clearGestureDetailsCache();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: const Color(0xff000000),
    child: ExtendedImageSlidePage(
      slideType: SlideType.wholePage,
      slideAxis: SlideAxis.vertical,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ExtendedImageGesturePageView.builder(
            key: const ValueKey('a-image-viewer-pages'),
            controller: _pageController,
            itemCount: widget.items.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) => _image(widget.items[index]),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FButton.icon(
                    key: const ValueKey('a-image-viewer-close'),
                    variant: .secondary,
                    semanticsLabel: '关闭图片预览',
                    onPress: widget.onClose,
                    child: const Icon(FLucideIcons.x),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xb3000000),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Semantics(
                        liveRegion: true,
                        label:
                            '第 ${_currentIndex + 1} 张，共 ${widget.items.length} 张',
                        child: Text(
                          '${_currentIndex + 1}/${widget.items.length}',
                          key: const ValueKey('a-image-viewer-counter'),
                          style: FTheme.of(context).typography.body.sm
                              .copyWith(color: const Color(0xffffffff)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _image(AImageViewerItem item) {
    final image = switch (item.source) {
      AImageViewerSource.asset => ExtendedImage.asset(
        item.location as String,
        key: ValueKey('a-image-viewer-${item.location}'),
        fit: BoxFit.contain,
        mode: ExtendedImageMode.gesture,
        semanticLabel: item.semanticLabel,
        initGestureConfigHandler: _gestureConfig,
        onDoubleTap: _handleDoubleTap,
        loadStateChanged: _loadState,
      ),
      AImageViewerSource.network => ExtendedImage.network(
        (item.location as Uri).toString(),
        key: ValueKey('a-image-viewer-${item.location}'),
        cache: true,
        fit: BoxFit.contain,
        mode: ExtendedImageMode.gesture,
        semanticLabel: item.semanticLabel,
        initGestureConfigHandler: _gestureConfig,
        onDoubleTap: _handleDoubleTap,
        loadStateChanged: _loadState,
      ),
    };
    return Semantics(
      image: true,
      label: item.semanticLabel,
      excludeSemantics: true,
      child: Center(child: image),
    );
  }

  GestureConfig _gestureConfig(ExtendedImageState state) => GestureConfig(
    minScale: 1,
    initialScale: 1,
    maxScale: 4,
    animationMaxScale: 4.5,
    inPageView: true,
    cacheGesture: true,
  );

  void _handleDoubleTap(ExtendedImageGestureState state) {
    if (_doubleTapListener case final previous?) {
      _doubleTapAnimation?.removeListener(previous);
    }
    _doubleTapController
      ..stop()
      ..reset();
    final begin = state.gestureDetails?.totalScale ?? 1;
    final end = begin > 1 ? 1.0 : 2.5;
    final position = state.pointerDownPosition;
    _doubleTapAnimation = _doubleTapController.drive(
      Tween<double>(begin: begin, end: end),
    );
    void listener() => state.handleDoubleTap(
      scale: _doubleTapAnimation!.value,
      doubleTapPosition: position,
    );
    _doubleTapListener = listener;
    _doubleTapAnimation!.addListener(listener);
    _doubleTapController.forward();
  }

  Widget? _loadState(ExtendedImageState state) =>
      switch (state.extendedImageLoadState) {
        LoadState.loading => const Center(child: FCircularProgress()),
        LoadState.failed => Center(
          child: FButton(
            key: const ValueKey('a-image-viewer-retry'),
            variant: .secondary,
            onPress: state.reLoadImage,
            child: const Text('重试'),
          ),
        ),
        LoadState.completed => null,
      };
}
