import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Internal shared presentation for finite page indicators.
class PageIndicators extends StatelessWidget {
  const PageIndicators({required this.index, required this.count, super.key});
  final int index, count;
  @override
  Widget build(BuildContext context) {
    if (count <= 1) return const SizedBox.shrink();
    final gap = context.theme.buttonStyles.ghost.md.contentStyle.spacing;
    final visible = math.min(count, 5);
    final start = (index - visible ~/ 2).clamp(0, count - visible);
    return ExcludeSemantics(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: gap / 2,
        children: [
          for (var i = start; i < start + visible; i++)
            AnimatedContainer(
              duration: context.accessibility.motion == .disabled
                  ? Duration.zero
                  : const FTabMotion().duration,
              width: i == index ? gap * 3 : gap,
              height: gap,
              decoration: BoxDecoration(
                color: i == index
                    ? context.theme.colors.primary
                    : context.theme.colors.mutedForeground,
                borderRadius: context.theme.style.borderRadius.pill,
              ),
            ),
        ],
      ),
    );
  }
}
