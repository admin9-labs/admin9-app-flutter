import 'dart:math' as math;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import 'a_grid_item.dart';
import 'a_grid_style.dart';
import '../paging/page_indicators.dart';

enum AGridSurface { transparent, muted, outlined }

/// An Admin9 action grid with expanded rows or finite horizontal paging.
class AGrid extends StatelessWidget {
  const AGrid({
    super.key,
    required this.children,
    this.columns = 4,
    this.horizontalGap,
    this.verticalGap,
    this.childAspectRatio,
    this.padding,
    this.style,
    this.surface = AGridSurface.transparent,
    this.rowsPerPage,
    this.showIndicators = true,
  }) : assert(columns > 0),
       assert(rowsPerPage == null || rowsPerPage > 0),
       assert(horizontalGap == null || horizontalGap >= 0),
       assert(verticalGap == null || verticalGap >= 0),
       assert(childAspectRatio == null || childAspectRatio > 0);

  final List<AGridItem> children;

  /// The maximum number of columns. Narrow constraints reduce this value.
  final int columns;
  final double? horizontalGap;
  final double? verticalGap;
  final double? childAspectRatio;
  final EdgeInsetsGeometry? padding;
  final AGridStyle? style;
  final AGridSurface surface;

  /// Null expands all rows; a positive value enables horizontal paging.
  final int? rowsPerPage;
  final bool showIndicators;

  static AGridStyle styleOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_AGridScope>()?.style ??
      context.theme.style.aGrid;

  static AGridSurface surfaceOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_AGridScope>()?.surface ??
      AGridSurface.transparent;

  @override
  Widget build(BuildContext context) {
    final resolved = style ?? context.theme.style.aGrid;
    final gridPadding = padding ?? resolved.gridPadding;
    final crossAxisSpacing = horizontalGap ?? resolved.horizontalGap;
    final mainAxisSpacing = verticalGap ?? resolved.verticalGap;
    final requestedAspectRatio = childAspectRatio ?? resolved.childAspectRatio;
    final minimumTouchSize = resolved.minimumTouchSize;
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth) {
          throw FlutterError('AGrid requires a bounded width.');
        }
        if (minimumTouchSize < 44) {
          throw FlutterError(
            'AGridStyle.minimumTouchSize must be at least 44.',
          );
        }

        final direction = Directionality.of(context);
        final resolvedPadding = gridPadding.resolve(direction);
        final resolvedItemPadding = resolved.itemPadding.resolve(direction);
        final textScaler = MediaQuery.textScalerOf(context);
        final locale = Localizations.maybeLocaleOf(context);
        final labelLineHeight = _textLineHeight(
          style: resolved.labelTextStyle.resolve({}),
          direction: direction,
          textScaler: textScaler,
          locale: locale,
        );
        var minimumCellWidth =
            minimumTouchSize + resolvedItemPadding.horizontal;
        if (textScaler.scale(resolved.labelTextStyle.resolve({}).fontSize!) >
            FTypeface().xs.fontSize!) {
          for (final item in children) {
            if (item.labelText == null) continue;
            final painter = TextPainter(
              text: TextSpan(
                text: item.labelText,
                style: resolved.labelTextStyle.resolve({}),
              ),
              textDirection: direction,
              textScaler: textScaler,
              locale: locale,
              maxLines: 1,
            )..layout();
            minimumCellWidth = math.max(
              minimumCellWidth,
              math.min(
                constraints.maxWidth,
                painter.width / item.labelMaxLines +
                    resolvedItemPadding.horizontal,
              ),
            );
            painter.dispose();
          }
        }
        final availableWidth =
            constraints.maxWidth - resolvedPadding.left - resolvedPadding.right;
        if (availableWidth < minimumTouchSize) {
          throw FlutterError(
            'AGrid needs at least $minimumTouchSize logical pixels of '
            'content width.',
          );
        }

        final fittingColumns = math.max(
          1,
          ((availableWidth + crossAxisSpacing) /
                  (minimumCellWidth + crossAxisSpacing))
              .floor(),
        );
        final effectiveColumns = math.min(columns, fittingColumns);
        final cellWidth =
            (availableWidth - (effectiveColumns - 1) * crossAxisSpacing) /
            effectiveColumns;
        var labelHeight = labelLineHeight;
        for (final item in children) {
          if (item.labelText == null) continue;
          final painter =
              TextPainter(
                text: TextSpan(
                  text: item.labelText,
                  style: resolved.labelTextStyle.resolve({}),
                ),
                textDirection: direction,
                textScaler: textScaler,
                locale: locale,
                maxLines: item.labelMaxLines,
                ellipsis: '\u2026',
              )..layout(
                maxWidth: math.max(
                  1,
                  cellWidth - resolvedItemPadding.horizontal,
                ),
              );
          labelHeight = math.max(labelHeight, painter.height);
          painter.dispose();
        }
        final minimumCellHeight = math.max(
          minimumTouchSize,
          resolvedItemPadding.vertical +
              resolved.iconSlotSize +
              resolved.iconLabelSpacing +
              labelHeight,
        );
        final effectiveAspectRatio = math.min(
          requestedAspectRatio,
          cellWidth / minimumCellHeight,
        );

        Widget grid(List<AGridItem> items) => GridView.count(
          primary: false,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: gridPadding,
          crossAxisCount: effectiveColumns,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          childAspectRatio: effectiveAspectRatio,
          children: items,
        );
        final rows = rowsPerPage;
        final capacity = rows == null
            ? children.length
            : rows * effectiveColumns;
        return _AGridScope(
          style: resolved,
          surface: surface,
          child: DecoratedBox(
            decoration: resolved.gridDecoration,
            child: rows == null || children.length <= capacity
                ? grid(children)
                : _AGridPager(
                    key: PageStorageKey(
                      _GridPageScope(
                        key,
                        effectiveColumns,
                        rows,
                        children
                            .map(
                              (item) =>
                                  item.key ?? item.labelText ?? item.label,
                            )
                            .toList(growable: false),
                      ),
                    ),
                    items: children,
                    capacity: capacity,
                    height:
                        rows * cellWidth / effectiveAspectRatio +
                        (rows - 1) * mainAxisSpacing +
                        resolvedPadding.vertical,
                    grid: grid,
                    showIndicators: showIndicators,
                  ),
          ),
        );
      },
    );
  }
}

double _textLineHeight({
  required TextStyle style,
  required TextDirection direction,
  required TextScaler textScaler,
  required Locale? locale,
}) {
  final painter = TextPainter(
    text: TextSpan(text: '示例', style: style),
    textDirection: direction,
    textScaler: textScaler,
    locale: locale,
    maxLines: 1,
  )..layout();
  final height = painter.height;
  painter.dispose();
  return height;
}

// Retain actual identity equality; printed keys and labels are not unique IDs.
class _GridPageScope {
  const _GridPageScope(this.host, this.columns, this.rows, this.identities);
  final Key? host;
  final int columns, rows;
  final List<Object?> identities;

  @override
  bool operator ==(Object other) =>
      other is _GridPageScope &&
      host == other.host &&
      columns == other.columns &&
      rows == other.rows &&
      listEquals(identities, other.identities);

  @override
  int get hashCode =>
      Object.hash(host, columns, rows, Object.hashAll(identities));
}

class _AGridScope extends InheritedWidget {
  const _AGridScope({
    required this.style,
    required this.surface,
    required super.child,
  });

  final AGridStyle style;
  final AGridSurface surface;

  @override
  bool updateShouldNotify(_AGridScope oldWidget) =>
      style != oldWidget.style || surface != oldWidget.surface;
}

class _AGridPager extends StatefulWidget {
  const _AGridPager({
    required this.items,
    required this.capacity,
    required this.height,
    required this.grid,
    required this.showIndicators,
    super.key,
  });
  final List<AGridItem> items;
  final int capacity;
  final double height;
  final Widget Function(List<AGridItem>) grid;
  final bool showIndicators;
  @override
  State<_AGridPager> createState() => _AGridPagerState();
}

class _AGridPagerState extends State<_AGridPager> {
  PageController? _controller;
  int _index = 0;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) return;
    final count = (widget.items.length / widget.capacity).ceil();
    _index =
        ((PageStorage.maybeOf(context)
                        ?.readState(context, identifier: widget.key)
                    as int?) ??
                0)
            .clamp(0, count - 1);
    _controller = PageController(initialPage: _index, keepPage: false);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    spacing: context.theme.buttonStyles.ghost.md.contentStyle.spacing,
    children: [
      SizedBox(
        height: widget.height,
        child: PageView.builder(
          controller: _controller,
          itemCount: (widget.items.length / widget.capacity).ceil(),
          onPageChanged: (index) => setState(() {
            _index = index;
            PageStorage.maybeOf(context)
                ?.writeState(context, index, identifier: widget.key);
          }),
          itemBuilder: (_, index) => Align(
            alignment: AlignmentDirectional.topStart,
            child: widget.grid(
              widget.items
                  .skip(index * widget.capacity)
                  .take(widget.capacity)
                  .toList(),
            ),
          ),
        ),
      ),
      if (widget.showIndicators)
        PageIndicators(
          index: _index,
          count: (widget.items.length / widget.capacity).ceil(),
        ),
    ],
  );
}
