import 'package:flutter/foundation.dart';

enum AppThemePreference {
  system,
  light,
  dark;

  String get label => switch (this) {
    AppThemePreference.system => '跟随系统',
    AppThemePreference.light => '浅色',
    AppThemePreference.dark => '深色',
  };

  static AppThemePreference parse(String? value) => values.firstWhere(
    (item) => item.name == value,
    orElse: () => AppThemePreference.system,
  );
}

enum AppFontScale {
  standard(1, '标准'),
  large(1.12, '大号'),
  extraLarge(1.24, '特大');

  const AppFontScale(this.factor, this.label);

  final double factor;
  final String label;

  static AppFontScale parse(String? value) => values.firstWhere(
    (item) => item.name == value,
    orElse: () => AppFontScale.standard,
  );
}

class AppAppearance {
  const AppAppearance({
    this.theme = AppThemePreference.system,
    this.fontScale = AppFontScale.standard,
    this.grayscale = false,
    this.highContrast = false,
    this.reduceMotion = false,
  });

  final AppThemePreference theme;
  final AppFontScale fontScale;
  final bool grayscale;
  final bool highContrast;
  final bool reduceMotion;

  AppAppearance copyWith({
    AppThemePreference? theme,
    AppFontScale? fontScale,
    bool? grayscale,
    bool? highContrast,
    bool? reduceMotion,
  }) => AppAppearance(
    theme: theme ?? this.theme,
    fontScale: fontScale ?? this.fontScale,
    grayscale: grayscale ?? this.grayscale,
    highContrast: highContrast ?? this.highContrast,
    reduceMotion: reduceMotion ?? this.reduceMotion,
  );
}

abstract class AppAppearanceController extends ChangeNotifier {
  AppAppearance get appearance;
  bool get persistenceFailed;

  Future<void> setTheme(AppThemePreference value);
  Future<void> setFontScale(AppFontScale value);
  Future<void> setGrayscale(bool value);
  Future<void> setHighContrast(bool value);
  Future<void> setReduceMotion(bool value);
  Future<void> retryPersistence();
}
