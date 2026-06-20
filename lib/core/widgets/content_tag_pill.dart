import 'package:flutter/material.dart';

import '../../domain/models/article.dart';
import '../theme/app_appearance.dart';
import '../theme/app_spacing.dart';

class ContentTagPill extends StatelessWidget {
  const ContentTagPill({super.key, required this.tag, this.accentColor});

  final ArticleContentTag tag;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final foreground = accentColor ?? tokens.danger;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: 2,
        ),
        child: Text(
          tag.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.typography.label.copyWith(
            color: foreground,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
