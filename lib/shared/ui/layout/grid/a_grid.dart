import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import 'a_grid_item.dart';
import 'a_grid_style.dart';

enum AGridSurface { transparent, muted, outlined }

/// A finite, non-scrolling Admin9 grid for icon actions.
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
  }) : assert(columns > 0),
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
        final minimumCellWidth =
            minimumTouchSize + resolvedItemPadding.horizontal;
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
        final minimumCellHeight = math.max(
          minimumTouchSize,
          resolvedItemPadding.vertical +
              resolved.iconSlotSize +
              resolved.iconLabelSpacing +
              labelLineHeight,
        );
        final effectiveAspectRatio = math.min(
          requestedAspectRatio,
          cellWidth / minimumCellHeight,
        );

        return _AGridScope(
          style: resolved,
          surface: surface,
          child: DecoratedBox(
            decoration: resolved.gridDecoration,
            child: GridView.count(
              primary: false,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: gridPadding,
              crossAxisCount: effectiveColumns,
              crossAxisSpacing: crossAxisSpacing,
              mainAxisSpacing: mainAxisSpacing,
              childAspectRatio: effectiveAspectRatio,
              children: children,
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
  return painter.height;
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
