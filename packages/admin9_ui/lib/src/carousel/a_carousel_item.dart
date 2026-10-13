import 'package:flutter/widgets.dart';

/// Caller-owned content with a stable identity and an optional semantic action.
class ACarouselItem {
  const ACarouselItem({
    required this.id,
    required this.child,
    required this.semanticsLabel,
    this.title,
    this.onPress,
  });
  final Object id;

  /// Decorative content; item semantics and activation are owned by the carousel.
  /// Looping reuses this content on virtual pages; do not share GlobalKeys.
  final Widget child;
  final String semanticsLabel;
  final String? title;
  final VoidCallback? onPress;
}
