import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../paging/page_indicators.dart';
import 'a_carousel_item.dart';

enum ACarouselCaption { none, overlay, below }

/// Horizontal content paging with identity retention and lifecycle-aware autoplay.
/// Hosts set [active] to false when a carousel is offscreen but still mounted.
class ACarousel extends StatefulWidget {
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
  @override
  State<ACarousel> createState() => _ACarouselState();
}

class _ACarouselState extends State<ACarousel> with WidgetsBindingObserver {
  late final PageController _controller;
  late List<Object> _ids;
  Timer? _timer;
  final _pointers = <int>{};
  int _index = 0, _generation = 0;
  bool _dragging = false, _animating = false, _reconciling = false;
  bool _foreground = true, _visible = true, _reduceMotion = false;
  bool _dependenciesReady = false, _focused = false;
  bool get _loops => widget.loop && widget.items.length > 1;
  int get _firstPage => _loops ? widget.items.length * 10000 : 0;
  bool get _canRotate =>
      mounted &&
      widget.active &&
      widget.autoplay &&
      widget.items.length > 1 &&
      _visible &&
      _foreground &&
      !_reduceMotion &&
      !_focused &&
      _pointers.isEmpty &&
      !_dragging &&
      !_animating &&
      !_reconciling &&
      (_loops || _index < widget.items.length - 1);

  @override
  void initState() {
    super.initState();
    _ids = widget.items.map((item) => item.id).toList(growable: false);
    assert(widget.interval > Duration.zero);
    assert(
      widget.items.map((item) => item.id).toSet().length == widget.items.length,
      'Carousel item identities must be unique.',
    );
    _controller = PageController(initialPage: _firstPage, keepPage: false);
    _foreground =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final visible = TickerMode.valuesOf(context).enabled;
    final reduceMotion =
        MediaQuery.disableAnimationsOf(context) ||
        MediaQuery.accessibleNavigationOf(context) ||
        context.accessibility.motion == .disabled;
    final changed =
        !_dependenciesReady ||
        visible != _visible ||
        reduceMotion != _reduceMotion;
    _visible = visible;
    _reduceMotion = reduceMotion;
    _dependenciesReady = true;
    if (changed) _schedule();
  }

  @override
  void didUpdateWidget(ACarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    assert(widget.interval > Duration.zero);
    assert(
      widget.items.map((item) => item.id).toSet().length == widget.items.length,
      'Carousel item identities must be unique.',
    );
    final before = _ids;
    final after = widget.items.map((item) => item.id).toList(growable: false);
    _ids = after;
    if (!listEquals(before, after) || oldWidget.loop != widget.loop) {
      final previousIndex = _index;
      final selected = before.isEmpty ? null : before[_index];
      _index = after
          .indexWhere((id) => id == selected)
          .clamp(0, after.isEmpty ? 0 : after.length - 1);
      _timer?.cancel();
      if (_reconciling) return;
      _reconciling = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_controller.hasClients && widget.items.isNotEmpty) {
          _controller.jumpToPage(_firstPage + _index);
        }
        _reconciling = false;
        if (widget.items.isNotEmpty &&
            (previousIndex != _index || selected != widget.items[_index].id)) {
          widget.onChanged?.call(_index);
        }
        _schedule();
      });
    } else if (oldWidget.autoplay != widget.autoplay ||
        oldWidget.active != widget.active ||
        oldWidget.interval != widget.interval) {
      _schedule();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (!_foreground) _pointers.clear();
    _schedule();
  }

  void _schedule() {
    _timer?.cancel();
    final generation = ++_generation;
    if (!_canRotate) return;
    _timer = Timer(widget.interval, () async {
      if (!_canRotate || generation != _generation || !_controller.hasClients) {
        return;
      }
      _animating = true;
      try {
        const motion = FTabMotion();
        await _controller.animateToPage(
          _controller.page!.round() + 1,
          duration: motion.duration,
          curve: motion.curve,
        );
      } finally {
        _animating = false;
      }
      if (mounted) _schedule();
    });
  }

  bool _scroll(ScrollNotification notification) {
    if (notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      _dragging = true;
      _schedule();
    } else if (notification is ScrollEndNotification && _dragging) {
      _dragging = false;
      _schedule();
    }
    return false;
  }

  void _turn(int delta) {
    if (!_controller.hasClients) return;
    final target = _controller.page!.round() + delta;
    if (!_loops && (target < 0 || target >= widget.items.length)) return;
    _controller.jumpToPage(target);
    _schedule();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _generation++;
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

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
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();
    final current = widget.items[_index];
    return Focus(
      canRequestFocus: false,
      onFocusChange: (focused) {
        _focused = focused;
        _schedule();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: context.theme.buttonStyles.ghost.md.contentStyle.spacing,
        children: [
          AspectRatio(
            aspectRatio: widget.aspectRatio,
            child: ClipRRect(
              borderRadius: context.theme.style.borderRadius.md,
              child: Semantics(
                value: '${_index + 1}/${widget.items.length}',
                increasedValue:
                    '${(_index + 1) % widget.items.length + 1}/${widget.items.length}',
                decreasedValue:
                    '${(_index - 1) % widget.items.length + 1}/${widget.items.length}',
                onIncrease: _loops || _index < widget.items.length - 1
                    ? () => _turn(1)
                    : null,
                onDecrease: _loops || _index > 0 ? () => _turn(-1) : null,
                child: Listener(
                  onPointerDown: (event) {
                    _pointers.add(event.pointer);
                    _schedule();
                  },
                  onPointerUp: (event) {
                    _pointers.remove(event.pointer);
                    _schedule();
                  },
                  onPointerCancel: (event) {
                    _pointers.remove(event.pointer);
                    _schedule();
                  },
                  child: NotificationListener<ScrollNotification>(
                    onNotification: _scroll,
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: _loops ? null : widget.items.length,
                      onPageChanged: (page) {
                        if (_reconciling || widget.items.isEmpty) return;
                        final index = page % widget.items.length;
                        if (index == _index) return;
                        setState(() => _index = index);
                        widget.onChanged?.call(index);
                        if (!_animating) _schedule();
                      },
                      itemBuilder: (_, page) {
                        final item = widget.items[page % widget.items.length];
                        final title = item.title;
                        final content = Stack(
                          fit: StackFit.expand,
                          children: [
                            item.child,
                            if (widget.caption == ACarouselCaption.overlay &&
                                title != null &&
                                title.isNotEmpty)
                              PositionedDirectional(
                                start: 0,
                                end: 0,
                                bottom: 0,
                                child: ExcludeSemantics(
                                  child: _caption(title, overlay: true),
                                ),
                              ),
                          ],
                        );
                        if (item.onPress == null) {
                          return Semantics(
                            key: ValueKey((item.id, page)),
                            label: item.semanticsLabel,
                            excludeSemantics: true,
                            child: content,
                          );
                        }
                        return FTappable(
                          key: ValueKey((item.id, page)),
                          semanticsLabel: item.semanticsLabel,
                          semanticsButton: item.onPress != null,
                          excludeSemantics: true,
                          onPress: item.onPress,
                          child: content,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (widget.showIndicators)
            PageIndicators(index: _index, count: widget.items.length),
          if (widget.caption == ACarouselCaption.below &&
              current.title != null &&
              current.title!.isNotEmpty)
            _caption(current.title!),
        ],
      ),
    );
  }
}
