import 'dart:math' as math;

import 'package:flutter/material.dart';

enum AppThemePreference {
  system,
  light,
  dark;

  ThemeMode get themeMode => switch (this) {
    AppThemePreference.system => ThemeMode.system,
    AppThemePreference.light => ThemeMode.light,
    AppThemePreference.dark => ThemeMode.dark,
  };

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

@immutable
class AppTextScaler implements TextScaler {
  const AppTextScaler({required this.system, required this.preferenceFactor});

  final TextScaler system;
  final double preferenceFactor;

  @override
  double scale(double fontSize) {
    final scaled = system.scale(fontSize) * preferenceFactor;
    return scaled.clamp(fontSize * 0.8, fontSize * 2).toDouble();
  }

  @override
  double get textScaleFactor => scale(16) / 16;

  @override
  TextScaler clamp({
    double minScaleFactor = 0,
    double maxScaleFactor = double.infinity,
  }) {
    if (minScaleFactor == maxScaleFactor) {
      return TextScaler.linear(minScaleFactor);
    }
    return _BoundedTextScaler(
      delegate: this,
      minScaleFactor: minScaleFactor,
      maxScaleFactor: maxScaleFactor,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AppTextScaler &&
      other.system == system &&
      other.preferenceFactor == preferenceFactor;

  @override
  int get hashCode => Object.hash(system, preferenceFactor);
}

@immutable
class _BoundedTextScaler implements TextScaler {
  const _BoundedTextScaler({
    required this.delegate,
    required this.minScaleFactor,
    required this.maxScaleFactor,
  });

  final TextScaler delegate;
  final double minScaleFactor;
  final double maxScaleFactor;

  @override
  double scale(double fontSize) => delegate
      .scale(fontSize)
      .clamp(fontSize * minScaleFactor, fontSize * maxScaleFactor);

  @override
  double get textScaleFactor => scale(16) / 16;

  @override
  TextScaler clamp({
    double minScaleFactor = 0,
    double maxScaleFactor = double.infinity,
  }) {
    final minimum = math.max(this.minScaleFactor, minScaleFactor);
    final maximum = math.min(this.maxScaleFactor, maxScaleFactor);
    if (maximum <= minimum) return TextScaler.linear(minimum);
    return _BoundedTextScaler(
      delegate: delegate,
      minScaleFactor: minimum,
      maxScaleFactor: maximum,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is _BoundedTextScaler &&
      other.delegate == delegate &&
      other.minScaleFactor == minScaleFactor &&
      other.maxScaleFactor == maxScaleFactor;

  @override
  int get hashCode => Object.hash(delegate, minScaleFactor, maxScaleFactor);
}
