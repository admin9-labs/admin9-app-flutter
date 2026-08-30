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
  static final Map<(AppThemePreset, AppRadiusPreference), AppThemePair>
  _themes = {
    for (final preset in AppThemePreset.values)
      for (final radius in AppRadiusPreference.values)
        (preset, radius): _build(preset, radius),
  };

  static AppThemePair resolve({
    required AppThemePreset preset,
    required AppRadiusPreference radius,
  }) => _themes[(preset, radius)]!;

  static AppThemePair _build(
    AppThemePreset preset,
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
    return AppThemePair(
      light: buildForuiTheme(colors: colors.light, borderRadius: borderRadius),
      dark: buildForuiTheme(colors: colors.dark, borderRadius: borderRadius),
    );
  }
}
