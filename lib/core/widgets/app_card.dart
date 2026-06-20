import 'package:flutter/material.dart';

import '../theme/app_appearance.dart';
import '../theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = AppInsets.card,
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.enabled = true,
    this.clipBehavior = Clip.antiAlias,
    this.backgroundColor,
    this.borderColor,
    this.showBorder = true,
    this.radius = AppRadius.card,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final bool enabled;
  final Clip clipBehavior;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool showBorder;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final content = Padding(padding: padding, child: child);
    final effectiveOnTap = enabled ? onTap : null;
    final cardContent = effectiveOnTap == null
        ? content
        : InkWell(onTap: effectiveOnTap, child: content);

    return Card(
      margin: margin,
      color: backgroundColor ?? tokens.cardBackground,
      clipBehavior: clipBehavior,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: showBorder
            ? BorderSide(color: borderColor ?? tokens.divider)
            : BorderSide.none,
      ),
      child: enabled
          ? cardContent
          : Opacity(opacity: 0.55, child: IgnorePointer(child: cardContent)),
    );
  }
}
