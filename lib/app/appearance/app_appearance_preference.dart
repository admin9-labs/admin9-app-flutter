enum AppBrightnessPreference { system, light, dark }

enum AppThemePreset { neutral, ocean, forest }

enum AppRadiusPreference { small, medium, large }

final class AppAppearancePreference {
  const AppAppearancePreference({
    required this.brightness,
    required this.preset,
    required this.radius,
  });

  static const defaults = AppAppearancePreference(
    brightness: AppBrightnessPreference.system,
    preset: AppThemePreset.neutral,
    radius: AppRadiusPreference.medium,
  );

  final AppBrightnessPreference brightness;
  final AppThemePreset preset;
  final AppRadiusPreference radius;

  AppAppearancePreference copyWith({
    AppBrightnessPreference? brightness,
    AppThemePreset? preset,
    AppRadiusPreference? radius,
  }) => AppAppearancePreference(
    brightness: brightness ?? this.brightness,
    preset: preset ?? this.preset,
    radius: radius ?? this.radius,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppAppearancePreference &&
          brightness == other.brightness &&
          preset == other.preset &&
          radius == other.radius;

  @override
  int get hashCode => Object.hash(brightness, preset, radius);
}
