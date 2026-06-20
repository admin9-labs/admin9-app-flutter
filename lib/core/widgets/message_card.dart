import 'package:flutter/material.dart';

import '../theme/app_appearance.dart';
import '../theme/app_spacing.dart';

class MessageCard extends StatelessWidget {
  const MessageCard({
    super.key,
    required this.title,
    required this.time,
    this.unread = false,
    this.onTap,
  });

  final String title;
  final String time;
  final bool unread;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Card(
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.cardPadding,
              AppSpacing.cardPadding,
              AppSpacing.cardPadding,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: SizedBox(
                    key: Key(
                      unread
                          ? 'message-card-unread-marker'
                          : 'message-card-read-marker',
                    ),
                    width: AppSpacing.sm,
                    height: AppSpacing.sm,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: unread ? tokens.unread : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: context.typography.feedTitleCompact),
                      const SizedBox(height: AppSpacing.sm),
                      Text(time, style: context.typography.feedMeta),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
