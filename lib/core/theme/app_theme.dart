import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light({
    required bool highContrast,
    required bool reduceMotion,
  }) => _build(Brightness.light, highContrast, reduceMotion);

  static ThemeData dark({
    required bool highContrast,
    required bool reduceMotion,
  }) => _build(Brightness.dark, highContrast, reduceMotion);

  static ThemeData _build(
    Brightness brightness,
    bool highContrast,
    bool reduceMotion,
  ) {
    final dark = brightness == Brightness.dark;
    final base = ColorScheme.fromSeed(
      seedColor: const Color(0xff263238),
      brightness: brightness,
      contrastLevel: highContrast ? 1 : 0.2,
    );
    final colors = base.copyWith(
      primary: dark ? const Color(0xfff4f6f7) : const Color(0xff263238),
      onPrimary: dark ? const Color(0xff20272a) : Colors.white,
      secondary: dark ? const Color(0xffff8a7a) : const Color(0xffc83f32),
      tertiary: dark ? const Color(0xff71d8cc) : const Color(0xff08786e),
      surface: dark ? const Color(0xff15191b) : const Color(0xfff8f9fa),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colors,
      scaffoldBackgroundColor: colors.surface,
      dividerTheme: DividerThemeData(color: colors.outlineVariant, space: 1),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 20),
        minTileHeight: 56,
      ),
      navigationBarTheme: const NavigationBarThemeData(height: 72),
      pageTransitionsTheme: reduceMotion
          ? const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: _NoTransitionBuilder(),
                TargetPlatform.iOS: _NoTransitionBuilder(),
              },
            )
          : const PageTransitionsTheme(),
    );
  }
}

class _NoTransitionBuilder extends PageTransitionsBuilder {
  const _NoTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => child;
}
