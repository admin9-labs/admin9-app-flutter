import 'package:flutter/material.dart';

import '../theme/app_appearance.dart';
import '../theme/app_spacing.dart';

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onActionTap,
    this.trailing,
    this.dense = false,
  });

  static const regularHeight = 36.0;
  static const denseHeight = 28.0;

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final Widget? trailing;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final normalizedSubtitle = subtitle?.trim();
    final hasSubtitle =
        normalizedSubtitle != null && normalizedSubtitle.isNotEmpty;
    final normalizedAction = actionLabel?.trim();
    final hasAction = normalizedAction != null && normalizedAction.isNotEmpty;
    final headerHeight = dense ? denseHeight : regularHeight;
    final tokens = context.tokens;

    return Row(
      key: const Key('app-section-header'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: headerHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  key: const Key('app-section-header-title'),
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      (dense
                              ? context.typography.cardSectionTitle
                              : context.typography.sectionTitle)
                          .copyWith(
                            fontWeight: hasSubtitle ? FontWeight.w700 : null,
                          ),
                ),
                if (hasSubtitle) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    normalizedSubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.typography.feedMeta.copyWith(
                      color: tokens.textSecondary,
                      height: 1.25,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.sm),
          trailing!,
        ] else if (hasAction) ...[
          const SizedBox(width: AppSpacing.sm),
          TextButton(
            key: Key('app-section-header-action-$normalizedAction'),
            onPressed: onActionTap,
            style: TextButton.styleFrom(
              minimumSize: Size(44, headerHeight),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              visualDensity: VisualDensity.compact,
              textStyle: context.typography.buttonLabel,
            ),
            child: Text(normalizedAction),
          ),
        ],
      ],
    );
  }
}
