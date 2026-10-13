import 'package:flutter/widgets.dart';

/// Caller-owned announcement copy with a stable identity and optional action.
class AAnnouncementItem {
  const AAnnouncementItem({
    required this.id,
    required this.title,
    this.semanticsLabel,
    this.onPress,
  });
  final Object id;
  final String title;

  /// Defaults to the full title. Include additional action context when needed.
  final String? semanticsLabel;
  final VoidCallback? onPress;
}
