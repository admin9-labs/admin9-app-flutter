import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import 'a_grid.dart';
import 'a_grid_badge.dart';

/// An interactive Admin9 icon action.
class AGridItem extends StatelessWidget {
  const AGridItem({
    super.key,
    required this.icon,
    required this.label,
    this.badge,
    this.enabled = true,
    this.selected = false,
    this.onPress,
    this.semanticsLabel,
    this.semanticsHint,
  });

  final Widget icon;
  final Widget label;
  final AGridBadge? badge;
  final bool enabled;
  final bool selected;
  final VoidCallback? onPress;
  final String? semanticsLabel;
  final String? semanticsHint;

  @override
  Widget build(BuildContext context) {
    final style = AGrid.styleOf(context);
    final badge = this.badge;
    final visibleBadge = badge != null && badge.visible ? badge : null;
    final mergedSemanticsLabel = [
      semanticsLabel,
      visibleBadge?.semanticsLabel,
    ].whereType<String>().where((label) => label.isNotEmpty).join('，');
    final itemDecoration = switch (AGrid.surfaceOf(context)) {
      AGridSurface.transparent => style.transparentItemDecoration,
      AGridSurface.muted => style.mutedItemDecoration,
      AGridSurface.outlined => style.outlinedItemDecoration,
    };
    return FTappable(
      selected: selected,
      semanticsLabel: mergedSemanticsLabel.isEmpty
          ? null
          : mergedSemanticsLabel,
      semanticsHint: semanticsHint,
      semanticsButton: true,
      excludeSemantics: semanticsLabel?.isNotEmpty ?? false,
      focusedOutlineStyle: style.focusedOutlineStyle,
      onPress: enabled ? onPress : null,
      builder: (context, variants, _) => AnimatedContainer(
        duration: context.accessibility.motion == .disabled
            ? Duration.zero
            : const Duration(milliseconds: 120),
        constraints: BoxConstraints(
          minWidth: style.minimumTouchSize,
          minHeight: style.minimumTouchSize,
        ),
        decoration: itemDecoration.resolve(variants),
        padding: style.itemPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox.square(
              dimension: style.iconSlotSize,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  IconTheme(
                    data: style.iconStyle.resolve(variants),
                    child: icon,
                  ),
                  if (visibleBadge case final badge?)
                    PositionedDirectional(
                      top: style.badgeTopOffset,
                      end: style.badgeEndOffset,
                      child: ExcludeSemantics(
                        child: Opacity(
                          opacity: variants.contains(FTappableVariant.disabled)
                              ? style.badgeDisabledOpacity
                              : 1,
                          child: badge,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: style.iconLabelSpacing),
            Flexible(
              child: DefaultTextStyle(
                style: style.labelTextStyle.resolve(variants),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                child: label,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
