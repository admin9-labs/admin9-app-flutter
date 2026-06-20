import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_appearance.dart';
import '../theme/app_spacing.dart';

class AppSearchEntry extends StatelessWidget {
  const AppSearchEntry({
    super.key,
    required this.placeholder,
    required this.onTap,
    this.trailing,
    this.height,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.foregroundColor,
    this.blurSigma = 0,
  });

  final String placeholder;
  final VoidCallback onTap;
  final Widget? trailing;
  final double? height;
  final BorderRadiusGeometry? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? foregroundColor;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final radius = borderRadius ?? BorderRadius.circular(AppRadius.input);
    final inkRadius = radius.resolve(Directionality.of(context));
    final effectiveBackgroundColor = backgroundColor ?? tokens.softFill;
    final effectiveIconColor = foregroundColor ?? tokens.textTertiary;
    final effectivePlaceholderStyle = foregroundColor == null
        ? context.typography.formHint
        : context.typography.formHint.copyWith(color: foregroundColor);
    final borderSide = borderColor == null
        ? null
        : BorderSide(color: borderColor!);
    final content = Material(
      color: effectiveBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: borderSide ?? BorderSide.none,
      ),
      child: InkWell(
        borderRadius: inkRadius,
        onTap: onTap,
        child: ExcludeSemantics(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: height ?? AppSpacing.minTouchTarget,
              maxHeight: height ?? double.infinity,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: effectiveIconColor,
                    size: AppIconSize.sm,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      placeholder,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: effectivePlaceholderStyle,
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    trailing!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
    final child = blurSigma <= 0
        ? content
        : ClipRRect(
            key: const Key('app-search-entry-blur-clip'),
            borderRadius: inkRadius,
            child: BackdropFilter(
              key: const Key('app-search-entry-blur'),
              filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
              child: content,
            ),
          );

    return Semantics(
      button: true,
      label: placeholder,
      onTap: onTap,
      child: child,
    );
  }
}

class AppSearchTextField extends StatelessWidget {
  const AppSearchTextField({
    super.key,
    required this.controller,
    required this.onSubmitted,
    this.placeholder = '搜索关键词',
    this.autofocus = false,
    this.onClear,
    this.height,
    this.fillColor,
    this.borderRadius,
    this.contentPadding,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final String placeholder;
  final bool autofocus;
  final VoidCallback? onClear;
  final double? height;
  final Color? fillColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final radius = borderRadius ?? BorderRadius.circular(AppRadius.input);

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final canClear = onClear != null && value.text.isNotEmpty;

        return SizedBox(
          height: height,
          child: TextField(
            key: const Key('search-input'),
            controller: controller,
            autofocus: autofocus,
            textAlignVertical: TextAlignVertical.center,
            textInputAction: TextInputAction.search,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              filled: true,
              fillColor: fillColor ?? tokens.cardBackground,
              isDense: true,
              contentPadding:
                  contentPadding ??
                  const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: tokens.textTertiary,
                size: AppIconSize.md,
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 42,
                minHeight: AppSpacing.minTouchTarget,
              ),
              suffixIcon: canClear
                  ? IconButton(
                      tooltip: '清空',
                      onPressed: onClear,
                      icon: Icon(
                        Icons.close_rounded,
                        color: tokens.textTertiary,
                        size: AppIconSize.sm,
                      ),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: radius,
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: onSubmitted,
          ),
        );
      },
    );
  }
}
