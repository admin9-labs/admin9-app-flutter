enum AppBrightnessPreference { system, light, dark }

enum AppThemePreset { neutral, ocean, forest }

enum AppFontSizePreference { extraSmall, small, standard, large, extraLarge }

enum AppRadiusPreference { small, medium, large }

final class AppAppearancePreference {
  const AppAppearancePreference({
    required this.brightness,
    required this.preset,
    required this.fontSize,
    required this.radius,
  });

  static const defaults = AppAppearancePreference(
    brightness: AppBrightnessPreference.system,
    preset: AppThemePreset.neutral,
    fontSize: AppFontSizePreference.standard,
    radius: AppRadiusPreference.medium,
  );

  final AppBrightnessPreference brightness;
  final AppThemePreset preset;
  final AppFontSizePreference fontSize;
  final AppRadiusPreference radius;

  AppAppearancePreference copyWith({
    AppBrightnessPreference? brightness,
    AppThemePreset? preset,
    AppFontSizePreference? fontSize,
    AppRadiusPreference? radius,
  }) => AppAppearancePreference(
    brightness: brightness ?? this.brightness,
    preset: preset ?? this.preset,
    fontSize: fontSize ?? this.fontSize,
    radius: radius ?? this.radius,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppAppearancePreference &&
          brightness == other.brightness &&
          preset == other.preset &&
          fontSize == other.fontSize &&
          radius == other.radius;

  @override
  int get hashCode => Object.hash(brightness, preset, fontSize, radius);
}
