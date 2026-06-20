import 'package:flutter/material.dart';

import '../theme/app_appearance.dart';
import '../theme/app_spacing.dart';
import 'app_card.dart';
import 'app_section_header.dart';
import 'media_badge.dart';

enum QuickActionSectionSurface { card, inline }

class QuickActionSection extends StatelessWidget {
  const QuickActionSection({
    super.key,
    this.title,
    this.subtitle,
    required this.items,
    this.actionLabel,
    this.onActionTap,
    this.maxColumns = 4,
    this.maxItems,
    this.shrinkToItemCount = false,
    this.surface = QuickActionSectionSurface.card,
    this.gridKey,
    this.cardPadding = AppInsets.card,
    this.cardRadius = AppRadius.card,
    this.showCardBorder = true,
  });

  static const headerHeight = 28.0;

  final String? title;
  final String? subtitle;
  final List<QuickActionItem> items;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final int maxColumns;
  final int? maxItems;
  final bool shrinkToItemCount;
  final QuickActionSectionSurface surface;
  final Key? gridKey;
  final EdgeInsetsGeometry cardPadding;
  final double cardRadius;
  final bool showCardBorder;

  @override
  Widget build(BuildContext context) {
    final hasTitle = title != null && title!.trim().isNotEmpty;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasTitle) ...[
          AppSectionHeader(
            key: const Key('quick-action-section-header'),
            title: title!,
            subtitle: subtitle,
            actionLabel: actionLabel,
            onActionTap: onActionTap,
            dense: true,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        QuickActionGrid(
          gridKey: gridKey,
          items: items,
          maxColumns: maxColumns,
          maxItems: maxItems,
          shrinkToItemCount: shrinkToItemCount,
        ),
      ],
    );

    return switch (surface) {
      QuickActionSectionSurface.card => AppCard(
        padding: cardPadding,
        radius: cardRadius,
        showBorder: showCardBorder,
        child: content,
      ),
      QuickActionSectionSurface.inline => content,
    };
  }
}

class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({
    super.key,
    required this.items,
    this.maxColumns = 4,
    this.maxItems,
    this.shrinkToItemCount = false,
    this.gridKey,
  });

  static const tileExtent = 86.0;

  final List<QuickActionItem> items;
  final int maxColumns;
  final int? maxItems;
  final bool shrinkToItemCount;
  final Key? gridKey;

  @override
  Widget build(BuildContext context) {
    final visibleItems = maxItems == null
        ? items
        : items.take(maxItems!).toList(growable: false);
    if (visibleItems.isEmpty) return SizedBox.shrink(key: gridKey);

    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount = _effectiveColumnCount(
          width: constraints.maxWidth,
          itemCount: visibleItems.length,
        );

        return GridView.builder(
          key: gridKey,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: visibleItems.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnCount,
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            mainAxisExtent: tileExtent,
          ),
          itemBuilder: (context, index) =>
              _QuickActionCell(item: visibleItems[index]),
        );
      },
    );
  }

  int _effectiveColumnCount({required double width, required int itemCount}) {
    final requestedColumns = maxColumns < 1 ? 1 : maxColumns;
    var columns = shrinkToItemCount
        ? _clampInt(itemCount, min: 1, max: requestedColumns)
        : requestedColumns;

    if (width < 300 && itemCount > 4) {
      columns = _clampInt(columns, min: 1, max: requestedColumns >= 5 ? 4 : 3);
    }

    return columns;
  }

  int _clampInt(int value, {required int min, required int max}) {
    return value.clamp(min, max);
  }
}

class QuickActionItem {
  const QuickActionItem({
    this.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.imageUrl = '',
    this.badge,
  });

  final Key? key;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final String imageUrl;
  final String? badge;
}

class _QuickActionCell extends StatelessWidget {
  const _QuickActionCell({required this.item});

  final QuickActionItem item;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = dark
        ? tokens.textPrimary
        : item.color ?? tokens.textPrimary;
    final iconBackground = dark
        ? tokens.softFill
        : (item.color ?? tokens.textPrimary).withValues(alpha: 0.1);

    return InkWell(
      key: item.key,
      borderRadius: BorderRadius.circular(AppRadius.input),
      onTap: item.onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: AppSpacing.minTouchTarget,
          minWidth: AppSpacing.minTouchTarget,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: AppSpacing.functionIconContainer,
                    height: AppSpacing.functionIconContainer,
                    decoration: BoxDecoration(
                      color: iconBackground,
                      borderRadius: BorderRadius.circular(AppRadius.sheet),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _QuickActionIcon(item: item, color: iconColor),
                  ),
                  if (item.badge != null)
                    Positioned(
                      right: -AppSpacing.sm,
                      top: -AppSpacing.xs,
                      child: MediaBadge(
                        label: item.badge!,
                        color: tokens.unread,
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Flexible(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: context.typography.actionLabel.copyWith(
                    color: tokens.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionIcon extends StatelessWidget {
  const _QuickActionIcon({required this.item, required this.color});

  final QuickActionItem item;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.imageUrl.trim();
    if (imageUrl.isEmpty) return _fallbackIcon();

    return Image.network(
      imageUrl,
      key: Key('quick-action-image-${item.label}'),
      fit: BoxFit.cover,
      cacheWidth: _cacheDimension(context, AppSpacing.functionIconContainer),
      cacheHeight: _cacheDimension(context, AppSpacing.functionIconContainer),
      filterQuality: FilterQuality.medium,
      errorBuilder: (context, error, stackTrace) => _fallbackIcon(),
    );
  }

  int _cacheDimension(BuildContext context, double logicalSize) {
    return (logicalSize * MediaQuery.devicePixelRatioOf(context)).ceil();
  }

  Widget _fallbackIcon() {
    return Icon(item.icon, color: color, size: AppIconSize.action);
  }
}
