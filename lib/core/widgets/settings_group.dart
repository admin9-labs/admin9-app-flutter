import 'package:flutter/material.dart';

import '../theme/app_appearance.dart';
import '../theme/app_spacing.dart';

class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      color: context.tokens.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index != children.length - 1)
              Divider(
                height: AppSpacing.dividerThickness,
                thickness: AppSpacing.dividerThickness,
                indent: AppSpacing.pageX,
                endIndent: AppSpacing.pageX,
                color: context.tokens.divider,
              ),
          ],
        ],
      ),
    );
  }
}

class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.title,
    this.icon,
    this.value,
    this.trailing,
    this.onTap,
    this.danger = false,
  });

  final String title;
  final IconData? icon;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final foreground = danger ? tokens.danger : tokens.textPrimary;
    final typography = context.typography;
    final hasTrailing = trailing != null || onTap != null;
    final row = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageX,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: foreground, size: AppSpacing.iconSize),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Text(
              title,
              style: typography.settingsTitle.copyWith(color: foreground),
            ),
          ),
          if (value != null || hasTrailing) ...[
            const SizedBox(width: AppSpacing.md),
            Flexible(
              flex: 0,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 220),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (value != null)
                      Flexible(
                        child: Text(
                          value!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                          style: typography.settingsValue.copyWith(
                            color: tokens.textSecondary,
                          ),
                        ),
                      ),
                    if (trailing != null) ...[
                      if (value != null) const SizedBox(width: AppSpacing.sm),
                      trailing!,
                    ] else if (onTap != null) ...[
                      if (value != null) const SizedBox(width: AppSpacing.sm),
                      Icon(
                        Icons.chevron_right,
                        color: tokens.textTertiary,
                        size: AppSpacing.iconSize,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSpacing.rowMinHeight),
      child: onTap == null ? row : InkWell(onTap: onTap, child: row),
    );
  }
}

class SectionGap extends StatelessWidget {
  const SectionGap({super.key, this.height = AppSpacing.sectionGap});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height);
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xxs,
        right: AppSpacing.xxs,
        bottom: AppSpacing.xs,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: context.tokens.textTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
