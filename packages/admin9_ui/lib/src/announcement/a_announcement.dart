import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../paging/content_item_view.dart';
import '../paging/content_pager.dart';
import 'a_announcement_item.dart';

/// Wrapping announcement copy with optional vertical automatic rotation.
/// Static Forui alerts remain FAlert. Reduced motion/accessibility show all copy.
class AAnnouncement extends StatelessWidget {
  const AAnnouncement({
    required this.items,
    this.autoplay = false,
    this.interval = const Duration(seconds: 5),
    this.active = true,
    this.onChanged,
    super.key,
  });
  final List<AAnnouncementItem> items;
  final bool autoplay, active;
  final Duration interval;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    assert(interval > Duration.zero);
    assert(items.map((item) => item.id).toSet().length == items.length);
    if (items.isEmpty) return const SizedBox.shrink();
    final style = context.theme.typography.body.md.copyWith(
      color: context.theme.colors.foreground,
    );
    final spacing = context.theme.buttonStyles.ghost.md.contentStyle.spacing;
    final iconSize = context.theme.style.iconStyle.size!;
    final exposeAll =
        MediaQuery.disableAnimationsOf(context) ||
        MediaQuery.accessibleNavigationOf(context) ||
        context.accessibility.motion == .disabled;
    final pages = [
      for (final item in items)
        (
          id: item.id,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(item.title, style: style),
          ),
          semanticsLabel: item.semanticsLabel ?? item.title,
          onPress: item.onPress,
        ),
    ];
    return FCard(
      child: Padding(
        padding: context.theme.cardStyle.padding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: spacing,
          children: [
            ExcludeSemantics(
              child: Icon(FLucideIcons.megaphone, size: iconSize),
            ),
            Expanded(
              child: exposeAll
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: spacing,
                      children: [
                        for (final item in pages)
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: context.theme.style.sizes.item,
                            ),
                            child: ContentItemView(
                              key: ValueKey(item.id),
                              semanticsLabel: item.semanticsLabel,
                              onPress: item.onPress,
                              child: item.child,
                            ),
                          ),
                      ],
                    )
                  : ContentPager(
                      items: pages,
                      axis: Axis.vertical,
                      swipeEnabled: false,
                      autoplay: autoplay,
                      loop: true,
                      active: active,
                      interval: interval,
                      onChanged: onChanged,
                      frameBuilder: (context, viewport, _, turn) => Row(
                        spacing: spacing,
                        children: [
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                var height = context.theme.style.sizes.item;
                                for (final item in items) {
                                  final painter = TextPainter(
                                    text: TextSpan(
                                      text: item.title,
                                      style: style,
                                    ),
                                    textScaler: MediaQuery.textScalerOf(
                                      context,
                                    ),
                                    textDirection: Directionality.of(context),
                                    locale: Localizations.maybeLocaleOf(
                                      context,
                                    ),
                                  )..layout(maxWidth: constraints.maxWidth);
                                  height = math.max(height, painter.height);
                                  painter.dispose();
                                }
                                return SizedBox(
                                  height: height,
                                  child: viewport,
                                );
                              },
                            ),
                          ),
                          if (items.length > 1)
                            FButton.icon(
                              variant: .ghost,
                              semanticsLabel:
                                  (FLocalizations.of(context) ??
                                          FDefaultLocalizations())
                                      .paginationNextSemanticsLabel,
                              onPress: () => turn(1),
                              child: const Icon(FLucideIcons.chevronDown),
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
