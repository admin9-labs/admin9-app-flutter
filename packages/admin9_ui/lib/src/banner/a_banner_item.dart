import 'package:flutter/widgets.dart';

/// One decorative banner image with caller-owned semantics and optional action.
class ABannerItem {
  const ABannerItem({
    required this.id,
    required this.child,
    required this.semanticsLabel,
    this.onPress,
  });
  final Object id;

  /// Loop mode can mount adjacent instances; do not share GlobalKeys.
  final Widget child;
  final String semanticsLabel;
  final VoidCallback? onPress;
}
