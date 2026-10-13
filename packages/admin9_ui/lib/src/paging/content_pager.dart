import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';

import 'content_item_view.dart';

/// Internal presentation content shared by the three rotation consumers.
typedef ContentItem = ({
  Object id,
  Widget child,
  String semanticsLabel,
  VoidCallback? onPress,
});

/// Owns selection, paging and paused autoplay, without owning viewport geometry.
class ContentPager extends StatefulWidget {
  const ContentPager({
    required this.items,
    required this.frameBuilder,
    this.axis = Axis.horizontal,
    this.swipeEnabled = true,
    this.autoplay = false,
    this.loop = false,
    this.active = true,
    this.interval = const Duration(seconds: 5),
    this.onChanged,
    super.key,
  });
  final List<ContentItem> items;
  final Widget Function(BuildContext, Widget, int, void Function(int))
  frameBuilder;
  final Axis axis;
  final bool swipeEnabled, autoplay, loop, active;
  final Duration interval;
  final ValueChanged<int>? onChanged;
  @override
  State<ContentPager> createState() => _ContentPagerState();
}

class _ContentPagerState extends State<ContentPager>
    with WidgetsBindingObserver {
  late final PageController _controller;
  final _focusNode = FocusNode(skipTraversal: true);
  late List<Object> _ids;
  Timer? _timer;
  final _pointers = <int>{};
  int _index = 0, _generation = 0;
  bool _dragging = false, _animating = false, _reconciling = false;
  bool _foreground = true, _visible = true, _reduceMotion = false;
  bool _dependenciesReady = false, _focused = false;
  bool get _loops => widget.loop && widget.items.length > 1;
  int get _firstPage => _loops ? widget.items.length * 10000 : 0;
  bool get _paused =>
      !widget.active ||
      !widget.autoplay ||
      !_visible ||
      !_foreground ||
      _reduceMotion ||
      _focused ||
      _pointers.isNotEmpty ||
      _dragging;
  bool get _canRotate =>
      mounted &&
      widget.items.length > 1 &&
      !_paused &&
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
      'Rotating content identities must be unique.',
    );
    _controller = PageController(initialPage: _firstPage, keepPage: false);
    _foreground =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    WidgetsBinding.instance.addObserver(this);
    _focusNode.addListener(_focusChanged);
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
  void didUpdateWidget(ContentPager oldWidget) {
    super.didUpdateWidget(oldWidget);
    assert(widget.interval > Duration.zero);
    assert(
      widget.items.map((item) => item.id).toSet().length == widget.items.length,
      'Rotating content identities must be unique.',
    );
    final before = _ids;
    final after = widget.items.map((item) => item.id).toList(growable: false);
    _ids = after;
    if (!listEquals(before, after) ||
        oldWidget.loop != widget.loop ||
        oldWidget.axis != widget.axis) {
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
    if (_animating && _paused) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _animating && _paused && _controller.hasClients) {
          _controller.jumpToPage(_controller.page!.round());
        }
      });
    }
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

  void _focusChanged() {
    final focused = _focusNode.hasFocus;
    setState(() {});
    if (_focused == focused) return;
    _focused = focused;
    _schedule();
  }

  KeyEventResult _key(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final keyboard = HardwareKeyboard.instance;
    if (keyboard.isControlPressed ||
        keyboard.isAltPressed ||
        keyboard.isMetaPressed ||
        keyboard.isShiftPressed) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    final forward = widget.axis == Axis.vertical
        ? LogicalKeyboardKey.arrowDown
        : Directionality.of(context) == TextDirection.ltr
        ? LogicalKeyboardKey.arrowRight
        : LogicalKeyboardKey.arrowLeft;
    final backward = widget.axis == Axis.vertical
        ? LogicalKeyboardKey.arrowUp
        : Directionality.of(context) == TextDirection.ltr
        ? LogicalKeyboardKey.arrowLeft
        : LogicalKeyboardKey.arrowRight;
    if (key == forward || key == backward) {
      // Keep keyboard ownership when paging disposes the focused item.
      _focusNode.requestFocus();
      _turn(key == forward ? 1 : -1);
      return KeyEventResult.handled;
    }
    if (node.hasPrimaryFocus &&
        (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space)) {
      if (event is KeyDownEvent) widget.items[_index].onPress?.call();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _generation++;
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();
    final viewport = Semantics(
      value: '${_index + 1}/${widget.items.length}',
      increasedValue:
          '${(_index + 1) % widget.items.length + 1}/${widget.items.length}',
      decreasedValue:
          '${(_index - 1) % widget.items.length + 1}/${widget.items.length}',
      onIncrease: _loops || _index < widget.items.length - 1
          ? () => _turn(1)
          : null,
      onDecrease: _loops || _index > 0 ? () => _turn(-1) : null,
      child: NotificationListener<ScrollNotification>(
        onNotification: _scroll,
        child: PageView.builder(
          controller: _controller,
          scrollDirection: widget.axis,
          physics: widget.swipeEnabled
              ? null
              : const NeverScrollableScrollPhysics(),
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
            return ContentItemView(
              key: ValueKey((item.id, page)),
              semanticsLabel: item.semanticsLabel,
              onPress: item.onPress,
              child: item.child,
            );
          },
        ),
      ),
    );
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _key,
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
        child: FFocusedOutline(
          focused: _focusNode.hasPrimaryFocus,
          child: widget.frameBuilder(context, viewport, _index, _turn),
        ),
      ),
    );
  }
}
