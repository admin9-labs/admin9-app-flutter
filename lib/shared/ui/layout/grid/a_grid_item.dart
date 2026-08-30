import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import 'a_grid.dart';
import 'a_grid_style.dart';

enum AGridItemLayout { vertical, horizontalStart, horizontalEnd }

/// An interactive Admin9 grid item with directional content layouts.
class AGridItem extends StatelessWidget {
  const AGridItem({
    super.key,
    required this.visual,
    required this.title,
    this.description,
    this.badge,
    this.layout = AGridItemLayout.vertical,
    this.enabled = true,
    this.selected = false,
    this.onPress,
    this.semanticsLabel,
    this.semanticsHint,
    this.badgeSemanticsLabel,
  });

  final Widget visual;
  final Widget title;
  final Widget? description;
  final Widget? badge;
  final AGridItemLayout layout;
  final bool enabled;
  final bool selected;
  final VoidCallback? onPress;
  final String? semanticsLabel;
  final String? semanticsHint;
  final String? badgeSemanticsLabel;

  @override
  Widget build(BuildContext context) {
    final style = AGrid.styleOf(context);
    final excludesChildSemantics = semanticsLabel?.isNotEmpty ?? false;
    final mergedSemanticsLabel = [
      semanticsLabel,
      badgeSemanticsLabel,
    ].whereType<String>().where((label) => label.isNotEmpty).join('，');
    return FTappable(
      selected: selected,
      semanticsLabel: mergedSemanticsLabel.isEmpty
          ? null
          : mergedSemanticsLabel,
      semanticsHint: semanticsHint,
      semanticsButton: true,
      excludeSemantics: excludesChildSemantics,
      focusedOutlineStyle: style.focusedOutlineStyle,
      onPress: enabled ? onPress : null,
      builder: (context, variants, child) => AnimatedContainer(
        duration: context.accessibility.motion == .disabled
            ? Duration.zero
            : const Duration(milliseconds: 120),
        constraints: BoxConstraints(
          minWidth: style.minimumTouchSize,
          minHeight: style.minimumTouchSize,
        ),
        decoration: style.itemDecoration.resolve(variants),
        padding: style.itemPadding,
        child: _content(context, style, variants),
      ),
    );
  }

  Widget _content(
    BuildContext context,
    AGridStyle style,
    Set<FTappableVariant> variants,
  ) {
    final labels = _GridItemLabels(
      titleStyle: style.titleTextStyle.resolve(variants),
      descriptionStyle: style.descriptionTextStyle.resolve(variants),
      spacing: style.textSpacing,
      title: title,
      description: description,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 80;
        final visual = _GridItemVisual(
          decoration: style.visualDecoration.resolve(variants),
          iconStyle: style.iconStyle.resolve(variants),
          padding: compact ? EdgeInsets.zero : style.visualPadding,
          extent: style.minimumTouchSize,
          badge: badge,
          excludeBadgeSemantics: badgeSemanticsLabel?.isNotEmpty ?? false,
          child: this.visual,
        );
        final spacing = compact ? 6.0 : style.visualSpacing;
        Widget vertical() => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: spacing,
          children: [
            visual,
            Flexible(child: labels),
          ],
        );
        final horizontalFits =
            constraints.maxWidth >=
            style.minimumTouchSize * 2 + style.visualSpacing;
        if (!horizontalFits || layout == AGridItemLayout.vertical) {
          return vertical();
        }

        return switch (layout) {
          AGridItemLayout.vertical => vertical(),
          AGridItemLayout.horizontalStart => Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: spacing,
            children: [
              visual,
              Expanded(child: labels),
            ],
          ),
          AGridItemLayout.horizontalEnd => Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: spacing,
            children: [
              Expanded(child: labels),
              visual,
            ],
          ),
        };
      },
    );
  }
}

class _GridItemVisual extends StatelessWidget {
  const _GridItemVisual({
    required this.decoration,
    required this.iconStyle,
    required this.padding,
    required this.extent,
    required this.child,
    required this.excludeBadgeSemantics,
    this.badge,
  });

  final Decoration decoration;
  final IconThemeData iconStyle;
  final EdgeInsetsGeometry padding;
  final double extent;
  final Widget child;
  final bool excludeBadgeSemantics;
  final Widget? badge;

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      Padding(
        padding: EdgeInsetsDirectional.only(
          top: badge == null ? 0 : 4,
          end: badge == null ? 0 : 4,
        ),
        child: SizedBox.square(
          dimension: extent,
          child: DecoratedBox(
            key: const ValueKey('agrid-visual-surface'),
            decoration: decoration,
            child: Padding(
              padding: padding,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 1, minHeight: 1),
                  child: IconTheme(data: iconStyle, child: child),
                ),
              ),
            ),
          ),
        ),
      ),
      if (badge case final badge?)
        PositionedDirectional(
          top: 0,
          end: 0,
          child: excludeBadgeSemantics ? ExcludeSemantics(child: badge) : badge,
        ),
    ],
  );
}

class _GridItemLabels extends StatelessWidget {
  const _GridItemLabels({
    required this.titleStyle,
    required this.descriptionStyle,
    required this.spacing,
    required this.title,
    this.description,
  });

  final TextStyle titleStyle;
  final TextStyle descriptionStyle;
  final double spacing;
  final Widget title;
  final Widget? description;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final description = this.description;
      final textScaler = MediaQuery.textScalerOf(context);
      final direction = Directionality.of(context);
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
      final showDescription =
          description != null &&
          constraints.maxHeight >=
              titleLineHeight + spacing + descriptionLineHeight + 1;
      final titleLines =
          !showDescription && constraints.maxHeight >= titleLineHeight * 2
          ? 2
          : 1;
      final descriptionLines =
          showDescription &&
              constraints.maxHeight >=
                  titleLineHeight + spacing + descriptionLineHeight * 2 + 1
          ? 2
          : 1;

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing,
        children: [
          DefaultTextStyle(
            style: titleStyle,
            maxLines: titleLines,
            overflow: TextOverflow.ellipsis,
            child: title,
          ),
          if (showDescription)
            Flexible(
              child: DefaultTextStyle(
                style: descriptionStyle,
                maxLines: descriptionLines,
                overflow: TextOverflow.ellipsis,
                child: description,
              ),
            ),
        ],
      );
    },
  );
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
