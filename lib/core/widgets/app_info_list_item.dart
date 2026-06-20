import 'package:flutter/material.dart';

import '../theme/app_appearance.dart';
import '../theme/app_spacing.dart';
import 'app_card.dart';

class AppInfoListCard extends StatelessWidget {
  const AppInfoListCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.meta,
    this.iconColor,
    this.onTap,
    this.trailing,
    this.showChevron = true,
    this.unread = false,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? meta;
  final Color? iconColor;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showChevron;
  final bool unread;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      enabled: enabled,
      child: AppInfoListItem(
        icon: icon,
        iconColor: iconColor,
        title: title,
        subtitle: subtitle,
        meta: meta,
        trailing: trailing,
        showChevron: showChevron,
        unread: unread,
        enabled: enabled,
      ),
    );
  }
}

class AppInfoListItem extends StatelessWidget {
  const AppInfoListItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.meta,
    this.iconColor,
    this.onTap,
    this.trailing,
    this.showChevron = false,
    this.unread = false,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? meta;
  final Color? iconColor;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showChevron;
  final bool unread;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final effectiveIconColor = iconColor ?? tokens.brand.primary;
    final normalizedSubtitle = subtitle?.trim();
    final normalizedMeta = meta?.trim();
    final hasSubtitle =
        normalizedSubtitle != null && normalizedSubtitle.isNotEmpty;
    final hasMeta = normalizedMeta != null && normalizedMeta.isNotEmpty;
    final foregroundOpacity = enabled ? 1.0 : 0.55;
    final detailText = hasSubtitle && hasMeta
        ? '$normalizedSubtitle · $normalizedMeta'
        : hasSubtitle
        ? normalizedSubtitle
        : normalizedMeta;

    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSpacing.rowMinHeight),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _InfoIcon(icon: icon, color: effectiveIconColor),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Opacity(
              opacity: foregroundOpacity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.typography.feedTitleCompact,
                        ),
                      ),
                      if (unread) ...[
                        const SizedBox(width: AppSpacing.sm),
                        DecoratedBox(
                          key: const Key('app-info-list-unread-marker'),
                          decoration: BoxDecoration(
                            color: tokens.unread,
                            shape: BoxShape.circle,
                          ),
                          child: const SizedBox(
                            width: AppSpacing.sm,
                            height: AppSpacing.sm,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (hasSubtitle || hasMeta) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      detailText!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.typography.feedMeta,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.sm),
            trailing!,
          ],
          if (showChevron) ...[
            const SizedBox(width: AppSpacing.xs),
            Icon(
              Icons.chevron_right_rounded,
              color: tokens.textTertiary,
              size: AppIconSize.md,
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return row;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.input),
      onTap: enabled ? onTap : null,
      child: row,
    );
  }
}

class _InfoIcon extends StatelessWidget {
  const _InfoIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.input),
      ),
      child: SizedBox(
        width: AppSpacing.functionIconContainer,
        height: AppSpacing.functionIconContainer,
        child: Icon(icon, color: color, size: AppIconSize.md),
      ),
    );
  }
}
