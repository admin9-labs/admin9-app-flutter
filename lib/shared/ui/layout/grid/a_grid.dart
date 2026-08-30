import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import 'a_grid_item.dart';
import 'a_grid_style.dart';

/// A finite, non-scrolling Admin9 grid for page-level actions and content.
class AGrid extends StatelessWidget {
  const AGrid({
    super.key,
    required this.children,
    this.columns = 2,
    this.horizontalGap,
    this.verticalGap,
    this.childAspectRatio,
    this.padding,
    this.style,
  }) : assert(columns > 0),
       assert(horizontalGap == null || horizontalGap >= 0),
       assert(verticalGap == null || verticalGap >= 0),
       assert(childAspectRatio == null || childAspectRatio > 0);

  /// The grid items. Wrapping an item would hide the layout metadata AGrid
  /// needs to preserve its content and touch geometry.
  final List<AGridItem> children;

  /// The maximum number of columns. Fewer columns are used when needed to
  /// preserve [AGridStyle.minimumTouchSize].
  final int columns;
  final double? horizontalGap;
  final double? verticalGap;
  final double? childAspectRatio;
  final EdgeInsetsGeometry? padding;
  final AGridStyle? style;

  /// Resolves the nearest grid override, then falls back to the Forui theme.
  static AGridStyle styleOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_AGridStyleScope>()?.style ??
      context.theme.style.aGrid;

  @override
  Widget build(BuildContext context) {
    final inheritedTheme = context.theme;
    final resolved = style ?? inheritedTheme.style.aGrid;
    final gridPadding = padding ?? resolved.gridPadding;
    final crossAxisSpacing = horizontalGap ?? resolved.horizontalGap;
    final mainAxisSpacing = verticalGap ?? resolved.verticalGap;
    final requestedAspectRatio = childAspectRatio ?? resolved.childAspectRatio;
    final minimumTouchSize = resolved.minimumTouchSize;
    final grid = LayoutBuilder(
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
        final titleStyle = resolved.titleTextStyle.resolve({});
        final descriptionStyle = resolved.descriptionTextStyle.resolve({});
        final textScaler = MediaQuery.textScalerOf(context);
        final locale = Localizations.maybeLocaleOf(context);
        final titleLineHeight = _textLineHeight(
          style: titleStyle,
          direction: direction,
          textScaler: textScaler,
          locale: locale,
        );
        final descriptionLineHeight = _textLineHeight(
          style: descriptionStyle,
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
        final horizontalFits =
            cellWidth - resolvedItemPadding.horizontal >=
            minimumTouchSize * 2 + resolved.visualSpacing;
        final minimumCellHeight = children.fold<double>(
          minimumTouchSize + titleLineHeight + resolvedItemPadding.vertical,
          (height, child) {
            final labelHeight =
                titleLineHeight +
                (child.description == null
                    ? 0
                    : resolved.textSpacing + descriptionLineHeight);
            final visualHeight =
                minimumTouchSize + (child.badge == null ? 0 : 4);
            final vertical =
                child.layout == AGridItemLayout.vertical || !horizontalFits;
            final contentHeight = vertical
                ? visualHeight + resolved.visualSpacing + labelHeight
                : math.max(visualHeight, labelHeight);
            return math.max(
              height,
              contentHeight + resolvedItemPadding.vertical + 4,
            );
          },
        );
        final effectiveAspectRatio = math.min(
          requestedAspectRatio,
          cellWidth / minimumCellHeight,
        );

        return DecoratedBox(
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
        );
      },
    );

    return style == null
        ? grid
        : _AGridStyleScope(style: resolved, child: grid);
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

class _AGridStyleScope extends InheritedWidget {
  const _AGridStyleScope({required this.style, required super.child});

  final AGridStyle style;

  @override
  bool updateShouldNotify(_AGridStyleScope oldWidget) =>
      style != oldWidget.style;
}
