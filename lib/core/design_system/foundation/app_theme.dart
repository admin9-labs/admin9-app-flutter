import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_design_token_data.dart';
import 'app_design_tokens.dart';

@immutable
final class AppResolvedTheme {
  const AppResolvedTheme({required this.material, required this.tokens});

  final ThemeData material;
  final AppDesignTokens tokens;
}

abstract final class AppTheme {
  static AppResolvedTheme resolve({
    required Brightness brightness,
    required bool highContrast,
    required bool reduceMotion,
    required bool boldText,
    required Color brandPrimary,
    required Color brandSecondary,
    String? brandFontFamily,
    int brandRadiusDelta = 0,
    TargetPlatform? platform,
  }) {
    assert(brandRadiusDelta >= -2 && brandRadiusDelta <= 2);
    final dark = brightness == Brightness.dark;
    final effectivePlatform = platform ?? defaultTargetPlatform;
    final primary = brandPrimary;
    final secondary = brandSecondary;
    final background = dark ? const Color(0xff111418) : const Color(0xfff7f8fa);
    final onBackground = dark
        ? const Color(0xfff2f4f7)
        : const Color(0xff171a1f);
    final surface = dark ? const Color(0xff191d22) : const Color(0xffffffff);
    final surfaceContainer = dark
        ? const Color(0xff242a31)
        : const Color(0xffeef1f4);
    final outline = highContrast
        ? (dark ? const Color(0xffd7dde4) : const Color(0xff35404c))
        : (dark ? const Color(0xff929eac) : const Color(0xff687482));
    _validateFocusColor(primary, [background, surface, surfaceContainer]);
    final onPrimary = _resolveOnColor(
      primary,
      dark ? const Color(0xff102a56) : Colors.white,
    );
    final onSecondary = _resolveOnColor(
      secondary,
      dark ? const Color(0xff202830) : Colors.white,
    );
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: primary,
          brightness: brightness,
          contrastLevel: highContrast ? 1 : 0,
        ).copyWith(
          primary: primary,
          onPrimary: onPrimary,
          secondary: secondary,
          onSecondary: onSecondary,
          error: dark ? const Color(0xffffb4ab) : const Color(0xffb3261e),
          onError: dark ? const Color(0xff5f1513) : Colors.white,
          surface: surface,
          onSurface: onBackground,
          surfaceContainer: surfaceContainer,
          outline: outline,
        );
    final baseTheme = ThemeData(
      useMaterial3: true,
      platform: effectivePlatform,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: brandFontFamily,
    );
    var textTheme = _resolveTypography(
      platform: effectivePlatform,
      base: baseTheme.textTheme,
      color: onBackground,
      fontFamily: brandFontFamily,
    );
    if (boldText) textTheme = _resolveBoldText(textTheme);

    final stateDuration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 120);
    final enterDuration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 200);
    final exitDuration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 160);
    final tokens = AppDesignTokenData(
      background: background,
      onBackground: onBackground,
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: onSecondary,
      surface: surface,
      onSurface: onBackground,
      surfaceContainer: surfaceContainer,
      onSurfaceContainer: onBackground,
      outline: outline,
      danger: dark ? const Color(0xffffb4ab) : const Color(0xffb3261e),
      onDanger: dark ? const Color(0xff5f1513) : Colors.white,
      warning: dark ? const Color(0xfff4c06a) : const Color(0xff714b00),
      onWarning: dark ? const Color(0xff3d2800) : Colors.white,
      info: dark ? const Color(0xffa9d1ea) : const Color(0xff245a7a),
      onInfo: dark ? const Color(0xff12384d) : Colors.white,
      success: dark ? const Color(0xff8fd5aa) : const Color(0xff246b45),
      onSuccess: dark ? const Color(0xff123b25) : Colors.white,
      disabledText: dark ? const Color(0xffa1aab4) : const Color(0xff606872),
      disabledContainer: surfaceContainer,
      focus: primary,
      displayTextStyle: textTheme.displaySmall!,
      pageTitleTextStyle: textTheme.titleLarge!,
      sectionTitleTextStyle: textTheme.titleMedium!,
      bodyTextStyle: textTheme.bodyLarge!,
      supportingTextStyle: textTheme.bodyMedium!,
      labelTextStyle: textTheme.labelLarge!,
      captionTextStyle: textTheme.bodySmall!,
      fieldRadius: 6 + brandRadiusDelta.toDouble(),
      controlRadius: 8 + brandRadiusDelta.toDouble(),
      stateMotion: stateDuration,
      enterMotion: enterDuration,
      exitMotion: exitDuration,
    );

    final cupertino = CupertinoThemeData(
      brightness: brightness,
      primaryColor: tokens.primary,
      primaryContrastingColor: tokens.onPrimary,
      scaffoldBackgroundColor: tokens.background,
      barBackgroundColor: tokens.surface,
      selectionHandleColor: tokens.primary,
      textTheme: CupertinoTextThemeData(
        textStyle: tokens.bodyTextStyle,
        actionTextStyle: tokens.labelTextStyle.copyWith(color: tokens.primary),
        navTitleTextStyle: tokens.pageTitleTextStyle,
        navLargeTitleTextStyle: tokens.displayTextStyle,
      ),
    );
    final material = baseTheme.copyWith(
      scaffoldBackgroundColor: tokens.background,
      textTheme: textTheme,
      cupertinoOverrideTheme: cupertino.noDefault(),
      dividerTheme: DividerThemeData(color: tokens.outline, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.fieldRadius),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.controlRadius),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(),
    );
    return AppResolvedTheme(material: material, tokens: tokens);
  }

  static Color _resolveOnColor(Color background, Color preferred) {
    if (_contrastRatio(background, preferred) >= 4.5) return preferred;
    final blackRatio = _contrastRatio(background, Colors.black);
    final whiteRatio = _contrastRatio(background, Colors.white);
    return blackRatio >= whiteRatio ? Colors.black : Colors.white;
  }

  static void _validateFocusColor(Color focus, List<Color> backgrounds) {
    for (final background in backgrounds) {
      if (_contrastRatio(focus, background) < 3) {
        throw ArgumentError.value(
          focus,
          'brandPrimary',
          'must provide at least 3:1 focus contrast against every surface',
        );
      }
    }
  }

  static double _contrastRatio(Color first, Color second) {
    final firstLuminance = first.computeLuminance();
    final secondLuminance = second.computeLuminance();
    final lighter = firstLuminance >= secondLuminance
        ? firstLuminance
        : secondLuminance;
    final darker = firstLuminance >= secondLuminance
        ? secondLuminance
        : firstLuminance;
    return (lighter + 0.05) / (darker + 0.05);
  }

  static TextTheme _resolveBoldText(TextTheme value) => value.copyWith(
    bodyLarge: value.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
    bodyMedium: value.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
    bodySmall: value.bodySmall?.copyWith(fontWeight: FontWeight.w500),
  );

  static TextTheme _resolveTypography({
    required TargetPlatform platform,
    required TextTheme base,
    required Color color,
    required String? fontFamily,
  }) {
    final ios = platform == TargetPlatform.iOS;
    TextStyle role(
      TextStyle? source, {
      required double size,
      required double lineHeight,
      required FontWeight weight,
    }) => (source ?? const TextStyle()).copyWith(
      color: color,
      fontFamily: fontFamily,
      fontSize: size,
      height: lineHeight / size,
      fontWeight: weight,
    );

    return base.copyWith(
      displaySmall: role(
        base.displaySmall,
        size: ios ? 34 : 36,
        lineHeight: ios ? 41 : 44,
        weight: FontWeight.bold,
      ),
      titleLarge: role(
        base.titleLarge,
        size: ios ? 17 : 22,
        lineHeight: ios ? 22 : 28,
        weight: FontWeight.bold,
      ),
      titleMedium: role(
        base.titleMedium,
        size: ios ? 13 : 16,
        lineHeight: ios ? 18 : 24,
        weight: FontWeight.bold,
      ),
      bodyLarge: role(
        base.bodyLarge,
        size: ios ? 17 : 16,
        lineHeight: ios ? 22 : 24,
        weight: FontWeight.normal,
      ),
      bodyMedium: role(
        base.bodyMedium,
        size: ios ? 15 : 14,
        lineHeight: 20,
        weight: FontWeight.normal,
      ),
      labelLarge: role(
        base.labelLarge,
        size: ios ? 17 : 14,
        lineHeight: ios ? 22 : 20,
        weight: FontWeight.w600,
      ),
      bodySmall: role(
        base.bodySmall,
        size: 12,
        lineHeight: 16,
        weight: FontWeight.normal,
      ),
    );
  }
}
