import 'package:flutter/material.dart';

import '../theme/app_appearance.dart';
import '../theme/app_spacing.dart';

enum AppButtonVariant { primary, secondary, text, danger }

class PrimaryPillButton extends StatelessWidget {
  const PrimaryPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.child,
    this.destructive = false,
    this.variant,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? child;
  final bool destructive;
  final AppButtonVariant? variant;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final effectiveVariant =
        variant ??
        (destructive ? AppButtonVariant.danger : AppButtonVariant.primary);
    final content = child ?? Text(label);

    return switch (effectiveVariant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: onPressed,
        child: content,
      ),
      AppButtonVariant.secondary => FilledButton.tonal(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: tokens.softFill,
          foregroundColor: tokens.textPrimary,
          minimumSize: const Size.fromHeight(AppSpacing.minTouchTarget),
          textStyle: context.typography.buttonLabel,
        ),
        child: content,
      ),
      AppButtonVariant.text => TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(textStyle: context.typography.buttonLabel),
        child: content,
      ),
      AppButtonVariant.danger => FilledButton.tonal(
        style: FilledButton.styleFrom(
          backgroundColor: tokens.danger.withValues(alpha: 0.1),
          foregroundColor: tokens.danger,
          minimumSize: const Size.fromHeight(AppSpacing.minTouchTarget),
          textStyle: context.typography.buttonLabel,
        ),
        onPressed: onPressed,
        child: content,
      ),
    };
  }
}
