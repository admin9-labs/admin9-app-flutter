import 'package:flutter/material.dart';

import '../theme/app_appearance.dart';
import '../theme/app_spacing.dart';

class AppTabBar extends StatelessWidget {
  const AppTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.isScrollable = true,
    this.tabAlignment = TabAlignment.start,
    this.indicatorPadding = EdgeInsets.zero,
    this.labelColor,
    this.unselectedLabelColor,
    this.indicatorColor,
    this.selectedColor,
    this.indicatorWeight = 2,
    this.labelPadding = const EdgeInsets.symmetric(horizontal: AppSpacing.md),
    this.labelFontWeight = FontWeight.w700,
    this.unselectedFontWeight,
    this.overlayColor,
  });

  final TabController controller;
  final List<Widget> tabs;
  final bool isScrollable;
  final TabAlignment tabAlignment;
  final EdgeInsetsGeometry indicatorPadding;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final Color? indicatorColor;
  final Color? selectedColor;
  final double indicatorWeight;
  final EdgeInsetsGeometry labelPadding;
  final FontWeight labelFontWeight;
  final FontWeight? unselectedFontWeight;
  final WidgetStateProperty<Color?>? overlayColor;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final typography = context.typography;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final effectiveSelectedColor =
        selectedColor ??
        labelColor ??
        (dark ? tokens.textPrimary : tokens.brand.primary);
    final effectiveIndicatorColor = indicatorColor ?? effectiveSelectedColor;
    final effectiveUnselectedLabelColor =
        unselectedLabelColor ?? tokens.textSecondary;
    final effectiveUnselectedLabelStyle = unselectedFontWeight == null
        ? typography.tabLabel
        : typography.tabLabel.copyWith(fontWeight: unselectedFontWeight);

    return TabBar(
      controller: controller,
      isScrollable: isScrollable,
      tabAlignment: isScrollable ? tabAlignment : null,
      dividerColor: Colors.transparent,
      dividerHeight: 0,
      indicatorColor: effectiveIndicatorColor,
      indicatorWeight: indicatorWeight,
      indicatorPadding: indicatorPadding,
      indicatorSize: TabBarIndicatorSize.label,
      labelPadding: labelPadding,
      labelColor: effectiveSelectedColor,
      unselectedLabelColor: effectiveUnselectedLabelColor,
      labelStyle: typography.tabLabel.copyWith(fontWeight: labelFontWeight),
      unselectedLabelStyle: effectiveUnselectedLabelStyle,
      overlayColor: overlayColor ?? WidgetStatePropertyAll(tokens.pressed),
      tabs: tabs,
    );
  }
}
