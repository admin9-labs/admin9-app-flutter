import 'package:flutter/widgets.dart';

abstract final class AppSpacing {
  static const xxs = 4.0;
  static const xs = 6.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;

  static const pageX = 16.0;
  static const pageTop = 16.0;
  static const pageBottom = 28.0;
  static const bottomNavHeight = 72.0;
  static const bottomNavPagePadding = 96.0;
  static const topLevelToolbarHeight = 56.0;
  static const topLevelBackdropCanvasHeight = 224.0;
  static const topLevelBackdropHeight = topLevelBackdropCanvasHeight;
  static const topLevelPinnedChannelHeight = 48.0;
  static const topLevelPinnedHomeHeaderHeight =
      topLevelSearchHeight + topLevelPinnedChannelHeight;
  static const homeChannelContentTopGap = 16.0;
  static const homeImmersiveChannelBackdropHeight = 320.0;
  static const homeImmersiveChannelPullExtent = 120.0;
  static const homeImmersiveChannelContentTopInset = 16.0;
  static const topLevelSearchHeight =
      homeSearchTopGap + minTouchTarget + homeSearchBottomGap;
  static const homeSearchTopGap = 8.0;
  static const homeSearchBottomGap = 4.0;
  static const sectionGap = 14.0;
  static const cardGap = 12.0;
  static const cardPadding = 16.0;
  static const cardRadius = 8.0;
  static const largeRadius = 24.0;
  static const chipRadius = 22.0;
  static const pillRadius = 999.0;
  static const rowMinHeight = 56.0;
  static const minTouchTarget = 44.0;
  static const iconSize = 24.0;
  static const actionIconSize = 28.0;
  static const functionIconContainer = 44.0;
  static const dividerThickness = 1.0;
  static const contentMaxWidth = 560.0;
}

abstract final class AppRadius {
  static const xs = 4.0;
  static const sm = 6.0;
  static const card = 8.0;
  static const media = 8.0;
  static const input = 12.0;
  static const sheet = 16.0;
  static const dialog = 20.0;
  static const brand = 24.0;
  static const pill = 999.0;
}

abstract final class AppIconSize {
  static const xs = 14.0;
  static const sm = 18.0;
  static const md = 22.0;
  static const lg = 24.0;
  static const nav = 24.0;
  static const action = 28.0;
  static const feature = 30.0;
  static const empty = 44.0;
}

abstract final class AppMediaSize {
  static const feedSideWidth = 118.0;
  static const feedSideHeight = 106.0;
  static const feedLargeHeight = 172.0;
  static const feedGridHeight = 76.0;
  static const carouselHeight = 168.0;
  static const heroHeight = 220.0;
  static const liveThumbWidth = 92.0;
  static const liveThumbHeight = 72.0;
  static const serviceIconBox = 48.0;
}

abstract final class AppInsets {
  static const page = EdgeInsets.fromLTRB(
    AppSpacing.pageX,
    AppSpacing.pageTop,
    AppSpacing.pageX,
    AppSpacing.pageBottom,
  );

  static const pageWithBottomNav = EdgeInsets.fromLTRB(
    AppSpacing.pageX,
    AppSpacing.pageTop,
    AppSpacing.pageX,
    AppSpacing.bottomNavPagePadding,
  );

  static const card = EdgeInsets.all(AppSpacing.cardPadding);
  static const cardCompact = EdgeInsets.all(AppSpacing.md);
  static const section = EdgeInsets.fromLTRB(
    AppSpacing.cardPadding,
    AppSpacing.sectionGap,
    AppSpacing.cardPadding,
    AppSpacing.sectionGap,
  );
  static const chip = EdgeInsets.symmetric(
    horizontal: AppSpacing.sm,
    vertical: AppSpacing.xxs,
  );
}
