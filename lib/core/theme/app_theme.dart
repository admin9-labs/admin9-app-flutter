import 'package:flutter/material.dart';

import 'app_appearance.dart';
import 'app_spacing.dart';

abstract final class AppTheme {
  static const primaryBlue = Color(0xff1fa4f5);
  static const pageBackground = Color(0xfff3f6f8);
  static const textPrimary = Color(0xff262a2f);
  static const textSecondary = Color(0xff8b9198);

  static ThemeData light({
    AppBrand brand = AppBrand.defaultBrand,
    AppFontLevel fontLevel = AppFontLevel.standard,
  }) {
    return _build(
      brand: brand,
      brightness: Brightness.light,
      fontScale: fontLevel.scale,
    );
  }

  static ThemeData dark({
    AppBrand brand = AppBrand.defaultBrand,
    AppFontLevel fontLevel = AppFontLevel.standard,
  }) {
    return _build(
      brand: brand,
      brightness: Brightness.dark,
      fontScale: fontLevel.scale,
    );
  }

  static ThemeData _build({
    required AppBrand brand,
    required Brightness brightness,
    required double fontScale,
  }) {
    final dark = brightness == Brightness.dark;
    final colors = _ThemePalette(
      pageBackground: dark ? const Color(0xff11161b) : pageBackground,
      cardBackground: dark ? const Color(0xff1a2027) : Colors.white,
      elevatedBackground: dark ? const Color(0xff202832) : Colors.white,
      textPrimary: dark ? const Color(0xfff2f5f7) : const Color(0xff2d3135),
      textSecondary: dark ? const Color(0xffaab2bb) : const Color(0xff8f969d),
      textTertiary: dark ? const Color(0xff7f8994) : const Color(0xffa9afb6),
      textDisabled: dark ? const Color(0xff626c77) : const Color(0xffc1c6cc),
      divider: dark ? const Color(0xff2a323b) : const Color(0xffedf0f2),
      softFill: dark ? const Color(0xff222a33) : const Color(0xffeef2f5),
      danger: dark ? const Color(0xffff6b76) : const Color(0xffff2d55),
      warning: dark ? const Color(0xffffc066) : const Color(0xffffad3d),
      success: dark ? const Color(0xff58d68d) : const Color(0xff18b66a),
      info: dark ? const Color(0xff72c7ff) : const Color(0xff1f8bd8),
    );

    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: brand.primary,
          brightness: brightness,
        ).copyWith(
          primary: brand.primary,
          surface: colors.cardBackground,
          error: colors.danger,
        );
    final accent = Color.lerp(colors.warning, colors.info, 0.5)!;

    final tokens = AppThemeTokens(
      brand: brand,
      accent: accent,
      pageBackground: colors.pageBackground,
      cardBackground: colors.cardBackground,
      elevatedBackground: colors.elevatedBackground,
      textPrimary: colors.textPrimary,
      textSecondary: colors.textSecondary,
      textTertiary: colors.textTertiary,
      textDisabled: colors.textDisabled,
      divider: colors.divider,
      softFill: colors.softFill,
      tagBackground: dark
          ? brand.primary.withValues(alpha: 0.18)
          : brand.primary.withValues(alpha: 0.1),
      tagForeground: dark ? colors.textPrimary : brand.primary,
      videoScrim: Colors.black.withValues(alpha: dark ? 0.52 : 0.42),
      buttonBackground: brand.primary,
      buttonForeground: Colors.white,
      navSelected: dark ? colors.textPrimary : brand.primary,
      navUnselected: colors.textSecondary,
      danger: colors.danger,
      warning: colors.warning,
      success: colors.success,
      info: colors.info,
      pressed: dark
          ? colors.textPrimary.withValues(alpha: 0.1)
          : brand.primary.withValues(alpha: 0.1),
      selected: dark
          ? colors.textPrimary.withValues(alpha: 0.16)
          : brand.primary.withValues(alpha: 0.14),
      unread: colors.danger,
      fontScale: fontScale,
    );

    final textTheme = _textTheme(colors, fontScale);
    final typography = _typography(textTheme, colors, fontScale);

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.pageBackground,
      useMaterial3: true,
      brightness: brightness,
      fontFamily: '.AppleSystemUIFont',
      extensions: [tokens, typography],
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: colors.cardBackground,
        surfaceTintColor: colors.cardBackground,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.pageBackground,
        surfaceTintColor: colors.pageBackground,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 18 * fontScale,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
        iconTheme: IconThemeData(color: colors.textPrimary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.cardBackground,
        indicatorColor: Colors.transparent,
        surfaceTintColor: colors.cardBackground,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected
                ? (dark ? colors.textPrimary : brand.primary)
                : colors.textSecondary,
            size: AppIconSize.nav,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return typography.bottomNavLabel.copyWith(
            color: selected
                ? (dark ? colors.textPrimary : brand.primary)
                : colors.textSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: dark ? colors.cardBackground : const Color(0xff2f3439),
        contentTextStyle: typography.snackbar.copyWith(
          color: dark ? colors.textPrimary : Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.cardBackground,
        hintStyle: typography.formHint,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.input)),
          borderSide: BorderSide.none,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: brand.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: const StadiumBorder(),
          textStyle: typography.buttonLabel,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: dark ? colors.textPrimary : brand.primary,
          side: BorderSide(color: dark ? colors.textPrimary : brand.primary),
          shape: const StadiumBorder(),
          textStyle: typography.buttonLabel,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return colors.textDisabled;
          if (states.contains(WidgetState.selected)) {
            return dark ? colors.success : colors.info;
          }
          return dark ? colors.textTertiary : Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return colors.textDisabled.withValues(alpha: 0.16);
          }
          if (states.contains(WidgetState.selected)) {
            return (dark ? colors.success : colors.info).withValues(
              alpha: dark ? 0.38 : 0.28,
            );
          }
          return colors.softFill;
        }),
      ),
    );
  }

  static TextTheme _textTheme(_ThemePalette colors, double scale) {
    return TextTheme(
      headlineMedium: TextStyle(
        fontSize: 26 * scale,
        fontWeight: FontWeight.w700,
        color: colors.textPrimary,
        height: 1.2,
      ),
      headlineSmall: TextStyle(
        fontSize: 22 * scale,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
        height: 1.25,
      ),
      titleLarge: TextStyle(
        fontSize: 20 * scale,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
        height: 1.28,
      ),
      titleMedium: TextStyle(
        fontSize: 17 * scale,
        fontWeight: FontWeight.w500,
        color: colors.textPrimary,
        height: 1.35,
      ),
      bodyLarge: TextStyle(
        fontSize: 17 * scale,
        fontWeight: FontWeight.w400,
        color: colors.textPrimary,
        height: 1.65,
      ),
      bodyMedium: TextStyle(
        fontSize: 15 * scale,
        fontWeight: FontWeight.w400,
        color: colors.textSecondary,
        height: 1.45,
      ),
      labelLarge: TextStyle(
        fontSize: 15 * scale,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      labelMedium: TextStyle(
        fontSize: 13 * scale,
        fontWeight: FontWeight.w400,
        color: colors.textSecondary,
      ),
    );
  }

  static AppTypography _typography(
    TextTheme textTheme,
    _ThemePalette colors,
    double scale,
  ) {
    return AppTypography(
      pageTitle: textTheme.headlineMedium!,
      sectionTitle: textTheme.titleLarge!.copyWith(
        color: colors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      cardSectionTitle: TextStyle(
        fontSize: 18 * scale,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
        height: 1.28,
      ),
      feedTitle: TextStyle(
        fontSize: 19 * scale,
        fontWeight: FontWeight.w400,
        color: colors.textPrimary,
        height: 1.42,
      ),
      feedTitleCompact: TextStyle(
        fontSize: 17 * scale,
        fontWeight: FontWeight.w400,
        color: colors.textPrimary,
        height: 1.4,
      ),
      feedMeta: TextStyle(
        fontSize: 14 * scale,
        fontWeight: FontWeight.w400,
        color: colors.textTertiary,
        height: 1.25,
      ),
      feedSummary: textTheme.bodyLarge!.copyWith(
        color: colors.textPrimary,
        fontWeight: FontWeight.w400,
      ),
      heroTitle: textTheme.headlineSmall!.copyWith(
        color: colors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      coverTitle: TextStyle(
        fontSize: 22 * scale,
        fontWeight: FontWeight.w700,
        color: colors.textPrimary,
        height: 1.22,
      ),
      tabLabel: TextStyle(
        fontSize: 17 * scale,
        fontWeight: FontWeight.w500,
        color: colors.textPrimary,
        height: 1.2,
      ),
      buttonLabel: TextStyle(
        fontSize: 15 * scale,
        fontWeight: FontWeight.w700,
        color: colors.textPrimary,
        height: 1.2,
      ),
      bottomNavLabel: TextStyle(
        fontSize: 11 * scale,
        fontWeight: FontWeight.w500,
        color: colors.textSecondary,
        height: 1.18,
      ),
      formHint: TextStyle(
        fontSize: 16 * scale,
        fontWeight: FontWeight.w400,
        color: colors.textTertiary,
        height: 1.25,
      ),
      snackbar: TextStyle(
        fontSize: 14 * scale,
        fontWeight: FontWeight.w500,
        height: 1.35,
      ),
      settingsTitle: TextStyle(
        fontSize: 17 * scale,
        fontWeight: FontWeight.w500,
        color: colors.textPrimary,
        height: 1.35,
      ),
      settingsValue: TextStyle(
        fontSize: 17 * scale,
        fontWeight: FontWeight.w400,
        color: colors.textSecondary,
        height: 1.35,
      ),
      bodyText: textTheme.bodyLarge!.copyWith(
        color: colors.textPrimary,
        fontWeight: FontWeight.w400,
      ),
      actionLabel: TextStyle(
        fontSize: 15 * scale,
        fontWeight: FontWeight.w500,
        color: colors.textPrimary,
        height: 1.2,
      ),
      label: textTheme.labelMedium!.copyWith(
        color: colors.textSecondary,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _ThemePalette {
  const _ThemePalette({
    required this.pageBackground,
    required this.cardBackground,
    required this.elevatedBackground,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.divider,
    required this.softFill,
    required this.danger,
    required this.warning,
    required this.success,
    required this.info,
  });

  final Color pageBackground;
  final Color cardBackground;
  final Color elevatedBackground;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;
  final Color divider;
  final Color softFill;
  final Color danger;
  final Color warning;
  final Color success;
  final Color info;
}
