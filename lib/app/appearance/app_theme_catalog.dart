import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';

import '../../theme/theme.dart';
import 'app_appearance_preference.dart';

final class AppThemePair {
  AppThemePair({required this.light, required this.dark})
    : lightMaterial = light.toApproximateMaterialTheme(),
      darkMaterial = dark.toApproximateMaterialTheme();

  final FThemeData light;
  final FThemeData dark;
  final ThemeData lightMaterial;
  final ThemeData darkMaterial;
}

abstract final class AppThemeCatalog {
  static final Map<
    (AppThemePreset, AppFontSizePreference, AppRadiusPreference),
    AppThemePair
  >
  _themes = {};

  static AppThemePair resolve({
    required AppThemePreset preset,
    required AppFontSizePreference fontSize,
    required AppRadiusPreference radius,
  }) => _themes.putIfAbsent((
    preset,
    fontSize,
    radius,
  ), () => _build(preset, fontSize, radius));

  static AppThemePair _build(
    AppThemePreset preset,
    AppFontSizePreference fontSize,
    AppRadiusPreference radius,
  ) {
    final colors = switch (preset) {
      AppThemePreset.neutral => (
        light: neutralLightColors,
        dark: neutralDarkColors,
      ),
      AppThemePreset.ocean => (light: oceanLightColors, dark: oceanDarkColors),
      AppThemePreset.forest => (
        light: forestLightColors,
        dark: forestDarkColors,
      ),
    };
    final borderRadius = switch (radius) {
      AppRadiusPreference.small => smallAppBorderRadius,
      AppRadiusPreference.medium => mediumAppBorderRadius,
      AppRadiusPreference.large => largeAppBorderRadius,
    };
    final typographyScale = switch (fontSize) {
      AppFontSizePreference.extraSmall => 0.875,
      AppFontSizePreference.small => 0.9375,
      AppFontSizePreference.standard => 1.0,
      AppFontSizePreference.large => 1.125,
      AppFontSizePreference.extraLarge => 1.25,
    };
    return AppThemePair(
      light: buildForuiTheme(
        colors: colors.light,
        typographyScale: typographyScale,
        borderRadius: borderRadius,
      ),
      dark: buildForuiTheme(
        colors: colors.dark,
        typographyScale: typographyScale,
        borderRadius: borderRadius,
      ),
    );
  }
}
