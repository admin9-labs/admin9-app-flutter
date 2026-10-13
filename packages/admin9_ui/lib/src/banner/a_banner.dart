import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../paging/content_item_view.dart';
import '../paging/content_pager.dart';
import 'a_banner_item.dart';

enum ABannerDisplay { stacked, rotating }

/// Operation banners: all images in a stack, or a vertical automatic rotation.
/// Vertical drags belong to the enclosing scroll view. Reduced motion and
/// accessible navigation expose every item in a stack, retaining all actions.
class ABanner extends StatelessWidget {
  const ABanner({
    required this.items,
    this.display = ABannerDisplay.stacked,
    this.aspectRatio = 4,
    this.interval = const Duration(seconds: 5),
    this.active = true,
    this.onChanged,
    super.key,
  }) : assert(aspectRatio > 0);
  final List<ABannerItem> items;
  final ABannerDisplay display;
  final double aspectRatio;
  final Duration interval;
  final bool active;

  /// Rotation/content changes only; the stacked presentation has no selection.
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    assert(interval > Duration.zero);
    assert(items.map((item) => item.id).toSet().length == items.length);
    if (items.isEmpty) return const SizedBox.shrink();
    final exposeAll =
        MediaQuery.disableAnimationsOf(context) ||
        MediaQuery.accessibleNavigationOf(context) ||
        context.accessibility.motion == .disabled;
    Widget frame(Widget child) => ConstrainedBox(
      constraints: BoxConstraints(minHeight: context.theme.style.sizes.item),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: ClipRRect(
          borderRadius: context.theme.style.borderRadius.md,
          child: child,
        ),
      ),
    );
    if (display == ABannerDisplay.stacked || exposeAll) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: context.theme.buttonStyles.ghost.md.contentStyle.spacing,
        children: [
          for (final item in items)
            frame(
              ContentItemView(
                key: ValueKey(item.id),
                semanticsLabel: item.semanticsLabel,
                onPress: item.onPress,
                child: item.child,
              ),
            ),
        ],
      );
    }
    return ContentPager(
      axis: Axis.vertical,
      swipeEnabled: false,
      autoplay: true,
      loop: true,
      interval: interval,
      active: active,
      onChanged: onChanged,
      items: [
        for (final item in items)
          (
            id: item.id,
            child: item.child,
            semanticsLabel: item.semanticsLabel,
            onPress: item.onPress,
          ),
      ],
      frameBuilder: (_, viewport, _, _) => frame(viewport),
    );
  }
}
