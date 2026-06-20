import 'package:flutter/material.dart';

import '../theme/app_appearance.dart';
import '../theme/app_spacing.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.compact = false,
    this.action,
  });

  final String title;
  final String? message;
  final IconData icon;
  final bool compact;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final normalizedMessage = message?.trim();

    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? AppSpacing.lg : AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: compact ? AppIconSize.action : AppIconSize.empty,
              color: tokens.textTertiary,
            ),
            const SizedBox(height: AppSpacing.sectionGap),
            Text(title, style: context.typography.feedTitleCompact),
            if (normalizedMessage != null && normalizedMessage.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                normalizedMessage,
                textAlign: TextAlign.center,
                style: context.typography.feedMeta,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
