import 'dart:ui';

import 'package:flutter/material.dart';

enum AppBrandId {
  mainstreamRed,
  newsBlue,
  livelihoodGreen,
  hotOrange,
  cityGold,
  jacarandaBlue;

  static AppBrandId parse(String? value) {
    const compat = {
      'mediaBlue': AppBrandId.newsBlue,
      'civicRed': AppBrandId.mainstreamRed,
      'serviceGreen': AppBrandId.livelihoodGreen,
    };
    if (compat.containsKey(value)) return compat[value]!;
    return AppBrandId.values.firstWhere(
      (id) => id.name == value,
      orElse: () => AppBrandId.jacarandaBlue,
    );
  }
}

enum AppFontLevel {
  standard(1),
  medium(1.08),
  large(1.16);

  const AppFontLevel(this.scale);

  final double scale;

  static AppFontLevel parse(String? value) {
    return AppFontLevel.values.firstWhere(
      (level) => level.name == value,
      orElse: () => AppFontLevel.standard,
    );
  }
}

enum AppThemeMode {
  system,
  light,
  dark;

  ThemeMode get materialMode {
    return switch (this) {
      AppThemeMode.system => ThemeMode.system,
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
    };
  }

  static AppThemeMode parse(String? value) {
    return AppThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => AppThemeMode.light,
    );
  }
}

class AppAppearanceSettings {
  const AppAppearanceSettings({
    this.brandId = AppBrandId.jacarandaBlue,
    this.themeMode = AppThemeMode.light,
    this.fontLevel = AppFontLevel.standard,
    this.grayscale = false,
  });

  final AppBrandId brandId;
  final AppThemeMode themeMode;
  final AppFontLevel fontLevel;
  final bool grayscale;

  AppAppearanceSettings copyWith({
    AppBrandId? brandId,
    AppThemeMode? themeMode,
    AppFontLevel? fontLevel,
    bool? grayscale,
  }) {
    return AppAppearanceSettings(
      brandId: brandId ?? this.brandId,
      themeMode: themeMode ?? this.themeMode,
      fontLevel: fontLevel ?? this.fontLevel,
      grayscale: grayscale ?? this.grayscale,
    );
  }
}

class AppBrand {
  const AppBrand({
    required this.id,
    required this.label,
    required this.primary,
    required this.gradientStart,
    required this.gradientMiddle,
    required this.gradientEnd,
  });

  final AppBrandId id;
  final String label;
  final Color primary;
  final Color gradientStart;
  final Color gradientMiddle;
  final Color gradientEnd;

  static const newsBlueBrand = AppBrand(
    id: AppBrandId.newsBlue,
    label: '西昌蓝',
    primary: Color(0xff0050a0),
    gradientStart: Color(0xfff6fbff),
    gradientMiddle: Color(0xff90d0f8),
    gradientEnd: Color(0xff0050a0),
  );

  static const defaultBrand = AppBrand(
    id: AppBrandId.jacarandaBlue,
    label: '蓝花楹',
    primary: Color(0xff8060c0),
    gradientStart: Color(0xfff9f7ff),
    gradientMiddle: Color(0xffc0a8e8),
    gradientEnd: Color(0xff8060c0),
  );

  static const all = [
    AppBrand(
      id: AppBrandId.mainstreamRed,
      label: '融媒红',
      primary: Color(0xffa00000),
      gradientStart: Color(0xfffff5f2),
      gradientMiddle: Color(0xfff0b0b0),
      gradientEnd: Color(0xffa00000),
    ),
    newsBlueBrand,
    AppBrand(
      id: AppBrandId.livelihoodGreen,
      label: '山水绿',
      primary: Color(0xff008858),
      gradientStart: Color(0xfff8fff9),
      gradientMiddle: Color(0xff80f0b0),
      gradientEnd: Color(0xff008858),
    ),
    AppBrand(
      id: AppBrandId.hotOrange,
      label: '晨曦橙',
      primary: Color(0xffb81800),
      gradientStart: Color(0xfffff8f1),
      gradientMiddle: Color(0xffffa040),
      gradientEnd: Color(0xffb81800),
    ),
    AppBrand(
      id: AppBrandId.cityGold,
      label: '彝火纹',
      primary: Color(0xffd00000),
      gradientStart: Color(0xfffff4e4),
      gradientMiddle: Color(0xfff0a000),
      gradientEnd: Color(0xffd00000),
    ),
    defaultBrand,
  ];

  static AppBrand byId(AppBrandId id) {
    return all.firstWhere(
      (brand) => brand.id == id,
      orElse: () => defaultBrand,
    );
  }
}

class AppThemeTokens extends ThemeExtension<AppThemeTokens> {
  const AppThemeTokens({
    required this.brand,
    required this.accent,
    required this.pageBackground,
    required this.cardBackground,
    required this.elevatedBackground,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.divider,
    required this.softFill,
    required this.tagBackground,
    required this.tagForeground,
    required this.videoScrim,
    required this.buttonBackground,
    required this.buttonForeground,
    required this.navSelected,
    required this.navUnselected,
    required this.danger,
    required this.warning,
    required this.success,
    required this.info,
    required this.pressed,
    required this.selected,
    required this.unread,
    required this.fontScale,
  });

  final AppBrand brand;
  final Color accent;
  final Color pageBackground;
  final Color cardBackground;
  final Color elevatedBackground;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;
  final Color divider;
  final Color softFill;
  final Color tagBackground;
  final Color tagForeground;
  final Color videoScrim;
  final Color buttonBackground;
  final Color buttonForeground;
  final Color navSelected;
  final Color navUnselected;
  final Color danger;
  final Color warning;
  final Color success;
  final Color info;
  final Color pressed;
  final Color selected;
  final Color unread;
  final double fontScale;

  Color get surface => cardBackground;
  Color get textStrong => textPrimary;
  Color get textMedium => textSecondary;
  Color get textWeak => textTertiary;

  @override
  AppThemeTokens copyWith({
    AppBrand? brand,
    Color? accent,
    Color? pageBackground,
    Color? cardBackground,
    Color? elevatedBackground,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
    Color? divider,
    Color? softFill,
    Color? tagBackground,
    Color? tagForeground,
    Color? videoScrim,
    Color? buttonBackground,
    Color? buttonForeground,
    Color? navSelected,
    Color? navUnselected,
    Color? danger,
    Color? warning,
    Color? success,
    Color? info,
    Color? pressed,
    Color? selected,
    Color? unread,
    double? fontScale,
  }) {
    return AppThemeTokens(
      brand: brand ?? this.brand,
      accent: accent ?? this.accent,
      pageBackground: pageBackground ?? this.pageBackground,
      cardBackground: cardBackground ?? this.cardBackground,
      elevatedBackground: elevatedBackground ?? this.elevatedBackground,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textDisabled: textDisabled ?? this.textDisabled,
      divider: divider ?? this.divider,
      softFill: softFill ?? this.softFill,
      tagBackground: tagBackground ?? this.tagBackground,
      tagForeground: tagForeground ?? this.tagForeground,
      videoScrim: videoScrim ?? this.videoScrim,
      buttonBackground: buttonBackground ?? this.buttonBackground,
      buttonForeground: buttonForeground ?? this.buttonForeground,
      navSelected: navSelected ?? this.navSelected,
      navUnselected: navUnselected ?? this.navUnselected,
      danger: danger ?? this.danger,
      warning: warning ?? this.warning,
      success: success ?? this.success,
      info: info ?? this.info,
      pressed: pressed ?? this.pressed,
      selected: selected ?? this.selected,
      unread: unread ?? this.unread,
      fontScale: fontScale ?? this.fontScale,
    );
  }

  @override
  AppThemeTokens lerp(ThemeExtension<AppThemeTokens>? other, double t) {
    if (other is! AppThemeTokens) return this;
    return AppThemeTokens(
      brand: t < 0.5 ? brand : other.brand,
      accent: Color.lerp(accent, other.accent, t)!,
      pageBackground: Color.lerp(pageBackground, other.pageBackground, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      elevatedBackground: Color.lerp(
        elevatedBackground,
        other.elevatedBackground,
        t,
      )!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      softFill: Color.lerp(softFill, other.softFill, t)!,
      tagBackground: Color.lerp(tagBackground, other.tagBackground, t)!,
      tagForeground: Color.lerp(tagForeground, other.tagForeground, t)!,
      videoScrim: Color.lerp(videoScrim, other.videoScrim, t)!,
      buttonBackground: Color.lerp(
        buttonBackground,
        other.buttonBackground,
        t,
      )!,
      buttonForeground: Color.lerp(
        buttonForeground,
        other.buttonForeground,
        t,
      )!,
      navSelected: Color.lerp(navSelected, other.navSelected, t)!,
      navUnselected: Color.lerp(navUnselected, other.navUnselected, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      success: Color.lerp(success, other.success, t)!,
      info: Color.lerp(info, other.info, t)!,
      pressed: Color.lerp(pressed, other.pressed, t)!,
      selected: Color.lerp(selected, other.selected, t)!,
      unread: Color.lerp(unread, other.unread, t)!,
      fontScale: lerpDouble(fontScale, other.fontScale, t) ?? fontScale,
    );
  }
}

class AppTypography extends ThemeExtension<AppTypography> {
  const AppTypography({
    required this.pageTitle,
    required this.sectionTitle,
    required this.cardSectionTitle,
    required this.feedTitle,
    required this.feedTitleCompact,
    required this.feedMeta,
    required this.feedSummary,
    required this.heroTitle,
    required this.coverTitle,
    required this.tabLabel,
    required this.buttonLabel,
    required this.bottomNavLabel,
    required this.formHint,
    required this.snackbar,
    required this.settingsTitle,
    required this.settingsValue,
    required this.bodyText,
    required this.actionLabel,
    required this.label,
  });

  final TextStyle pageTitle;
  final TextStyle sectionTitle;
  final TextStyle cardSectionTitle;
  final TextStyle feedTitle;
  final TextStyle feedTitleCompact;
  final TextStyle feedMeta;
  final TextStyle feedSummary;
  final TextStyle heroTitle;
  final TextStyle coverTitle;
  final TextStyle tabLabel;
  final TextStyle buttonLabel;
  final TextStyle bottomNavLabel;
  final TextStyle formHint;
  final TextStyle snackbar;
  final TextStyle settingsTitle;
  final TextStyle settingsValue;
  final TextStyle bodyText;
  final TextStyle actionLabel;
  final TextStyle label;

  @override
  AppTypography copyWith({
    TextStyle? pageTitle,
    TextStyle? sectionTitle,
    TextStyle? cardSectionTitle,
    TextStyle? feedTitle,
    TextStyle? feedTitleCompact,
    TextStyle? feedMeta,
    TextStyle? feedSummary,
    TextStyle? heroTitle,
    TextStyle? coverTitle,
    TextStyle? tabLabel,
    TextStyle? buttonLabel,
    TextStyle? bottomNavLabel,
    TextStyle? formHint,
    TextStyle? snackbar,
    TextStyle? settingsTitle,
    TextStyle? settingsValue,
    TextStyle? bodyText,
    TextStyle? actionLabel,
    TextStyle? label,
  }) {
    return AppTypography(
      pageTitle: pageTitle ?? this.pageTitle,
      sectionTitle: sectionTitle ?? this.sectionTitle,
      cardSectionTitle: cardSectionTitle ?? this.cardSectionTitle,
      feedTitle: feedTitle ?? this.feedTitle,
      feedTitleCompact: feedTitleCompact ?? this.feedTitleCompact,
      feedMeta: feedMeta ?? this.feedMeta,
      feedSummary: feedSummary ?? this.feedSummary,
      heroTitle: heroTitle ?? this.heroTitle,
      coverTitle: coverTitle ?? this.coverTitle,
      tabLabel: tabLabel ?? this.tabLabel,
      buttonLabel: buttonLabel ?? this.buttonLabel,
      bottomNavLabel: bottomNavLabel ?? this.bottomNavLabel,
      formHint: formHint ?? this.formHint,
      snackbar: snackbar ?? this.snackbar,
      settingsTitle: settingsTitle ?? this.settingsTitle,
      settingsValue: settingsValue ?? this.settingsValue,
      bodyText: bodyText ?? this.bodyText,
      actionLabel: actionLabel ?? this.actionLabel,
      label: label ?? this.label,
    );
  }

  @override
  AppTypography lerp(ThemeExtension<AppTypography>? other, double t) {
    if (other is! AppTypography) return this;
    return AppTypography(
      pageTitle: TextStyle.lerp(pageTitle, other.pageTitle, t)!,
      sectionTitle: TextStyle.lerp(sectionTitle, other.sectionTitle, t)!,
      cardSectionTitle: TextStyle.lerp(
        cardSectionTitle,
        other.cardSectionTitle,
        t,
      )!,
      feedTitle: TextStyle.lerp(feedTitle, other.feedTitle, t)!,
      feedTitleCompact: TextStyle.lerp(
        feedTitleCompact,
        other.feedTitleCompact,
        t,
      )!,
      feedMeta: TextStyle.lerp(feedMeta, other.feedMeta, t)!,
      feedSummary: TextStyle.lerp(feedSummary, other.feedSummary, t)!,
      heroTitle: TextStyle.lerp(heroTitle, other.heroTitle, t)!,
      coverTitle: TextStyle.lerp(coverTitle, other.coverTitle, t)!,
      tabLabel: TextStyle.lerp(tabLabel, other.tabLabel, t)!,
      buttonLabel: TextStyle.lerp(buttonLabel, other.buttonLabel, t)!,
      bottomNavLabel: TextStyle.lerp(bottomNavLabel, other.bottomNavLabel, t)!,
      formHint: TextStyle.lerp(formHint, other.formHint, t)!,
      snackbar: TextStyle.lerp(snackbar, other.snackbar, t)!,
      settingsTitle: TextStyle.lerp(settingsTitle, other.settingsTitle, t)!,
      settingsValue: TextStyle.lerp(settingsValue, other.settingsValue, t)!,
      bodyText: TextStyle.lerp(bodyText, other.bodyText, t)!,
      actionLabel: TextStyle.lerp(actionLabel, other.actionLabel, t)!,
      label: TextStyle.lerp(label, other.label, t)!,
    );
  }
}

extension AppThemeTokensLookup on BuildContext {
  AppThemeTokens get tokens {
    return Theme.of(this).extension<AppThemeTokens>()!;
  }

  AppTypography get typography {
    return Theme.of(this).extension<AppTypography>()!;
  }
}
