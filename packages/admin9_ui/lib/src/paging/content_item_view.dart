import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// One accessible unit; nested interactive children are deliberately excluded.
class ContentItemView extends StatelessWidget {
  const ContentItemView({
    required this.child,
    required this.semanticsLabel,
    this.onPress,
    super.key,
  });
  final Widget child;
  final String semanticsLabel;
  final VoidCallback? onPress;
  @override
  Widget build(BuildContext context) => onPress == null
      ? Semantics(label: semanticsLabel, excludeSemantics: true, child: child)
      : FTappable(
          semanticsLabel: semanticsLabel,
          semanticsButton: true,
          excludeSemantics: true,
          onPress: onPress,
          child: child,
        );
}
